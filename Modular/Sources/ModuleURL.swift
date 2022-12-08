//
//  ModuleURL.swift
//  Modular
//
//  Created by 顾钱想 on 2022/12/5.
//

import UIKit
//eg: scheme://module/page?param0=xxx&param1=xxx
public class ModuleURL: NSObject {

    //URL中的模块名
    @objc public var module_name: String?

    //URL中的模块方法
    @objc public var module_method: String?

    //URL中的参数
    @objc public var module_params: Dictionary<String, Any> = [:]
    
    init(url: String) {
        super.init()
        // 验证合法性
        assert(URL(string: url) != nil, "❌❌❌❌❌❌ 请检查这个URL\(url)是否正确, 设置不合法")
        let moduleUrl: URL = URL(string: url)!
        self.module_name = moduleName(url: moduleUrl)
        self.module_method = moduleUrl.host ?? ""
        self.module_params = moduleParams(url: moduleUrl)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func moduleName(url:URL) -> String{
        if url.pathComponents.count > 0 {
            var names = url.pathComponents
            names.remove(at: 0)
            return  names.first ?? ""
        } else {
            return ""
        }
    }

    func moduleParams(url:URL) -> Dictionary<String, Any> {
        var module_params: [String: Any] = [:]
        if ((url.query) != nil) {
            for pair in url.query!.components(separatedBy: "&") {
                let key = pair.components(separatedBy: "=")[0]
                let value = pair
                    .components(separatedBy:"=")[1]
                    .replacingOccurrences(of: "+", with: " ")
                    .removingPercentEncoding ?? ""
                module_params[key] = value
            }
        }
        return module_params
    }
}
