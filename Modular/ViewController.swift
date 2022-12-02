//
//  ViewController.swift
//  Modular
//
//  Created by 顾钱想 on 2022/11/22.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var callback: (Dictionary<String, Any>) -> Void = { dic in
        print(dic)
    }

    lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: self.view.frame)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }()
    
    let data:Array = ["push界面(Swift模块)",
                      "present界面(Swift模块)",
                      "组件调用Objc（Swift模块）",
                      "push界面(OC模块)",
                      "present界面(OC模块)",
                      "Url调用"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "组件化"
        self.view.addSubview(tableView)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "Cell")
        cell?.textLabel?.text = data[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 0) {
            Module.share.invokeWithModuleNameCallback("testSwift", selectorName: "push", params: [
                "id": "1",
                "name": "顾钱想",
                "sex": 20,
                "str": "1"
            ]) { parameters in
                //页面参数回调
                print("调用模块方法的回调-》", parameters)
            }
        } else if (indexPath.row == 1) {
            Module.share.invokeWithModuleName("testSwift", selectorName: "present", params: [
                "id": "1",
                "name": "顾钱想",
                "sex": 20,
                "str": "1"
            ])
        } else if (indexPath.row == 2) {
            Module.share.invokeWithModuleName("testSwift", selectorName: "alert", params: [
                "id": "1",
                "name": "顾钱想",
                "sex": 20
            ])
        } else if (indexPath.row == 3) {
            Module.share.invokeWithModuleName("testOC", selectorName: "push", params: [
                "id": "1",
                "name": "顾钱想",
                "sex": 20,
                "str": "1"
            ])
        } else if (indexPath.row == 4) {
            Module.share.invokeWithModuleName("testOC", selectorName: "present", params: [
                "id": "1",
                "name": "顾钱想",
                "sex": 20,
                "str": "1"
            ])
        } else if (indexPath.row == 5) {
            Module.share.invokeWithUrlCallback("scheme://push/testSwift?code=1111"){ parameters in
                //页面参数回调
                print("调用模块方法的回调-》", parameters)
            }
        }
    }
}

