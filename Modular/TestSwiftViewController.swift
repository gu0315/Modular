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
                      .selector(selector: #selector(present(dic:)))
            }
            .method { method in
                method.name("log")
                       .selector(selector: #selector(printLog(logString:)))
            }
            .method { method in
                method.name("log")
                       .selector(selector: #selector(printLog1(dic:)))
            }
    }
    
    
    @objc func printLog(logString: Dictionary<String, Any>) {
        print(logString)
    }

    @objc func printLog1(dic: Dictionary<String, Any>) {
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
    
    @objc func present(dic: Dictionary<String, Any> = [:]) {
        let vc = TestSwiftViewController()
        let data = try? JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
        vc.str = jsonStr! as String
        guard let topVc = TestSwiftViewController.applicationTopVC() else {
            return
        }
        topVc.present(vc, animated: true, completion: {})
    }
    
    // 范形类型约束
    func testNorm<T: TestModel>(value: T) {
        
    }
}
