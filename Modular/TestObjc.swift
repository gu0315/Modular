//
//  TestClass.swift
//  Modular
//
//  Created by 顾钱想 on 2022/11/28.
//

import UIKit

class TestObjc: NSObject, ModuleProtocol {
    static func moduleDescription(description: ModuleDescription) {
        description.moduleName("TestObjc")
            .method { method in
                method.name("alert")
                    .selector(selector: #selector(testAlert(dic:)))
            }
    }
    
    @objc func testAlert(dic: Dictionary<String, Any> = [:]) {
        let data = try? JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
        let alert = UIAlertController.init(title: "", message: jsonStr as String?, preferredStyle: .alert)
        guard let topVc = UIViewController.applicationTopVC() else {
            return
        }
        alert.addAction(UIAlertAction.init(title: "知道了", style:.default, handler: { _ in

        }))
        topVc.present(alert, animated: true, completion: nil)
    }

}
