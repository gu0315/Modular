//
//  ViewController.swift
//  Modular
//
//  Created by 顾钱想 on 2022/11/22.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: self.view.frame)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }()
    
    let data:Array = ["Swift语言push", "Swift语言present", "Swift语言调用方法", "调用OC->push", "调用OC->present"]
    
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
            Module.share.moduleName(moduleName: "testSwift", performSelectorName: "push", param: [:])
        } else if (indexPath.row == 1) {
            Module.share.moduleName(moduleName: "testSwift", performSelectorName: "present", param: [:])
        } else if (indexPath.row == 2) {
            Module.share.moduleName(moduleName: "testSwift", performSelectorName: "log", param: [
                "key": "value"
            ])
        } else if (indexPath.row == 3) {
            Module.share.moduleName(moduleName: "testOC", performSelectorName: "push", param: [:])
        } else if (indexPath.row == 4) {
            Module.share.moduleName(moduleName: "testOC", performSelectorName: "present", param: [:])
        }
    }
}

