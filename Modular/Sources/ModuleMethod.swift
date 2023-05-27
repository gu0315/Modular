//
//  ModuleMethod.swift
//  Modular
//
//  Created by 顾钱想 on 2022/11/23.
//

import UIKit

public class ModuleMethod: NSObject {
    // 模块方法对应的selector
    @objc var methodSelector: Selector?
    // 模块方法对应的别名
    var methodName: String?
    // true表示是类方法，false表示是实例方法，默认false
    var isClassMethod = false
    
    override init() {
        super.init()
    }
   
    @discardableResult
    @objc public  func name(_ name: String) ->ModuleMethod {
        self.methodName = name
        return self
    }
    
    @discardableResult
    @objc public func selector(selector: Selector) -> ModuleMethod {
        self.methodSelector = selector
        return self
    }
    
    @discardableResult
    @objc public func isClassMethod(_ isClassMethod: Bool) -> ModuleMethod {
        self.isClassMethod = isClassMethod
        return self
    }
}

