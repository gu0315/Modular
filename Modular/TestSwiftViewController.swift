//
//  TestSwiftViewController.swift
//  Modular
//
//  Created by 顾钱想 on 2022/11/22.
//

import UIKit

class TestSwiftViewController: UIViewController, ModuleProtocol {
    
    lazy var lab: UILabel = {
        let lab = UILabel.init(frame: self.view.frame)
        lab.textAlignment = .center
        self.view.addSubview(lab)
        return lab
    }()
    
    var str: String = ""
    
    /* 参数回调 */
    private var callBackParameters: (([String : Any]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.lab.text = str
    }
    
    deinit {
        print("TestSwiftViewController->deinit")
    }
    
    static func moduleDescription(description: ModuleDescription) {
        description.moduleName("testSwift")
            .method { method in
                method.isClassMethod(true)
                method.name("push")
                    .selector(selector: #selector(push(dic:callback:)))
            }
            .method { method in
                method.name("present")
                    .selector(selector: #selector(present(dic:callback:)))
            }
            .method { method in
                method.name("log")
                    .selector(selector: #selector(printLog(logString:callback:)))
            }
            .method { method in
                method.name("testNorm")
                    .selector(selector: #selector(testNorm(value:callback:)))
            }
            .method { method in
                method.name("multiparameter")
                    .selector(selector: #selector(multiparams(params1: params2: params3: params4: callback:)))
            }
    }
    
    
    @objc func printLog(logString: Dictionary<String, Any>, callback: ([String: Any]) -> Void) {
        print(logString)
    }

    @objc func printLog1(dic: Dictionary<String, Any>, callback: ([String: Any]) -> Void) {
        let data = try? JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
        let alert = UIAlertController(title: "", message: jsonStr as String? ?? "", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "知道了", style:.default, handler: { _ in

        }))
        guard let topVc = TestSwiftViewController.applicationTopVC() else {
            return
        }
        topVc.present(alert, animated: true)
    }
    
    @objc class func push(dic: Dictionary<String, Any> = [:], callback: ([String: Any]) -> Void) {
        let vc = TestSwiftViewController()
        let data = try? JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
        vc.str = jsonStr! as String
        guard let topVc = TestSwiftViewController.applicationTopVC() else {
            return 
        }
        callback(dic)
        topVc.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func present(dic: Dictionary<String, Any> = [:], callback: ([String: Any]) -> Void) {
        let vc = TestSwiftViewController()
        let data = try? JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
        vc.str = jsonStr! as String
        guard let topVc = TestSwiftViewController.applicationTopVC() else {
            return
        }
        topVc.present(vc, animated: true, completion: {})
    }
    
    @objc func testNorm(value: TestModel, callback: ([String: Any]) -> Void) {
        guard value.isKind(of: TestModel.self) else {
            print("参数有误")
            return
        }
    }
    
    /// 多参数吊用
    @objc func multiparams(params1: String, params2: Array<String>, params3: Dictionary<String, Any> = [:], params4: Int , callback: ([String: Any]) -> Void) {
        print("多参数", params1, params2, params3, params4)
    }
    
}
