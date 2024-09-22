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
                      "调用方法",
                      "Url调用",
                      "push界面(OC模块)",
                      "present界面(OC模块)","404", "otherParam"]
    
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
            Module.share.perform(moduleName:"testSwift", selectorName: "push", param: ["key":"value"]) { parameters in
                //页面参数回调
                print("调用模块方法的回调-》", parameters)
            }
        } else if (indexPath.row == 1) {
            Module.share.perform(moduleName:"testSwift", selectorName: "present", param: "hello") { parameters in
                //页面参数回调
                print("调用模块方法的回调-》", parameters)
            }
        } else if (indexPath.row == 2) {
            Module.share.perform(moduleName: "testOC", selectorName: "log", param: ["key":"value1"]) { parameters in
                //页面参数回调
                print("调用模块方法的回调-》", parameters)
            }
        } else if (indexPath.row == 3) {
            Module.share.performWithUrl(url:"scheme://push/testSwift?str=1111"){ parameters in
                //页面参数回调
                print("调用模块方法的回调-》", parameters)
            }
        } else if (indexPath.row == 4) {
            Module.share.perform(moduleName: "testOC", selectorName: "push", param:  "22") { parameters in
                //页面参数回调
                print("调用模块方法的回调-》", parameters)
            }
        } else if (indexPath.row == 5) {
            Module.share.perform(moduleName: "testOC", selectorName: "present", param:  ["key":"value2"]) { parameters in
                //页面参数回调
                print("调用模块方法的回调-》", parameters)
            }
        } else if (indexPath.row == 6) {
            Module.share.perform(moduleName: "xxxx", selectorName: "otherParam", param: [:]) { parameters in
                //页面参数回调
                print("调用模块方法的回调-》", parameters)
            }
        } else if (indexPath.row == 7) {
            Module.share.perform(moduleName: "testSwift", selectorName: "otherParam", param: [:], otherParam: "222")
        }
    }
}

