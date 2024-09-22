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
                method.classMethod(true)
                      .name("push")
                      .selector(selector: #selector(push(dic:callback:)))
                      .parameterDescription { enumerator in
                          enumerator.next()?.add(paramName: "dic", paramType: .Map)
                          enumerator.next()?.add(paramName: "callback", paramType: .Block)
                      }
            }
            .method { method in
                method.name("present")
                      .selector(selector: #selector(present(str:callback:)))
                      .parameterDescription { enumerator in
                          enumerator.next()?.add(paramName: "str", paramType: .String)
                          enumerator.next()?.add(paramName: "callback", paramType: .Block)
                      }
            }
            .method { method in
                method.name("log")
                      .selector(selector: #selector(printLog(logString:callback:)))
                      .parameterDescription { enumerator in
                          enumerator.next()?.add(paramName: "logString", paramType: .String)
                          enumerator.next()?.add(paramName: "callback", paramType: .Block)
                      }
            }
            .method { method in
                method.name("testNorm")
                      .selector(selector: #selector(testNorm(value:callback:)))
                      .parameterDescription { enumerator in
                          enumerator.next()?.add(paramName: "value", paramType: .String)
                          enumerator.next()?.add(paramName: "callback", paramType: .Block)
                      }
            }
            .method { method in
                method.name("otherParam")
                    .selector(selector: #selector(otherParam1(dic: str:)))
                    .parameterDescription { enumerator in
                        enumerator.next()?.add(paramName: "Map", paramType: .Map)
                        enumerator.next()?.add(paramName: "String", paramType: .String)
                    }
            }
            .method { method in
                method.name("multiparameter")
                      .selector(selector: #selector(multiparams(params1: params2: params3: params4: callback:)))
                      .parameterDescription { enumerator in
                          enumerator.next()?.add(paramName: "params1", paramType: .String)
                          enumerator.next()?.add(paramName: "params2", paramType: .Array)
                          enumerator.next()?.add(paramName: "params3", paramType: .Map)
                          enumerator.next()?.add(paramName: "params4", paramType: .Number)
                          enumerator.next()?.add(paramName: "callback", paramType: .Block)
                      }
            }
    }
    
    @objc func otherParam1(dic: [String: Any], str: String) {
        print("-----", str)
    }
    
    
    @objc func printLog(logString: String, callback: ([String: Any]) -> Void) {
        print(logString)
    }
    
    @objc class func push(dic: [String: Any], callback: ([String: Any]) -> Void) {
        let vc = TestSwiftViewController()
        vc.str = dic.description
        callback(["key": "我已经push啦"])
        guard let topVc = TestSwiftViewController.applicationTopVC() else {
            return
        }
        topVc.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func present(str: String, callback: ([String: Any]) -> Void) {
        let vc = TestSwiftViewController()
        vc.str = str
        callback(["key": "我已经present啦"])
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
    
    @objc func multiparams(params1: String, params2: Array<String>, params3: Dictionary<String, Any> = [:], params4: Int , callback: ([String: Any]) -> Void) {
        print("多参数", params1, params2, params3, params4)
    }
    
}
