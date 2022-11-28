//
//  ModuleURL.swift
//  Modular
//
//  Created by 顾钱想 on 2022/11/28.
//

import UIKit
public extension URL {
    
    // URL中的模块方法
    var module_method: String {
        return self.host ?? ""
    }
    
    // URL中的模块名
    var module_name: String {
        if self.pathComponents.count > 0 {
            var names = self.pathComponents
            names.remove(at: 0)
            return names.first ?? ""
        } else {
            return ""
        }
    }
    
    // URL中的参数
    var module_param: [String: Any]? {
        guard let query = self.query else { return nil}
        var queryStrings = [String: String]()
        for pair in query.components(separatedBy: "&") {
            let key = pair.components(separatedBy: "=")[0]
            let value = pair
                .components(separatedBy:"=")[1]
                .replacingOccurrences(of: "+", with: " ")
                .removingPercentEncoding ?? ""
            
            queryStrings[key] = value
        }
        return queryStrings
    }
}
