//
//  TestSwiftViewController.swift
//  Modular
//
//  Created by 顾钱想 on 2022/11/22.
//

import UIKit

class TestSwiftViewController: UIViewController, ModuleProtocol {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    }
    
    static func moduleDescription(description: ModuleDescription) {
        description.moduleName("testSwift")
            .method { method in
                method.name("push")
                    .selector(selector: #selector(push))
            }
            .method { method in
                method.name("present")
                    .selector(selector: #selector(present(dic:)))
            }
            .method { method in
                method.name("log")
                    .selector(selector: #selector(printLog(logString:)))
            }
    }
    
    
    @objc func printLog(logString: Dictionary<String, Any>) {
        print(logString)
    }

    @objc func push() {
        let vc = TestSwiftViewController()
        guard let topVc = UIViewController.applicationTopVC() else {
            return
        }
        topVc.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func present(dic: Dictionary<String, Any>) {
        let vc = TestSwiftViewController()
        guard let topVc = UIViewController.applicationTopVC() else {
            return
        }
        topVc.present(vc, animated: true, completion: nil)
    }
}
