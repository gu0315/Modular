//
//  ModuleMethod.swift
//  Modular
//
//  Created by 顾钱想 on 2022/11/23.
//

import UIKit

public class ModuleMethod: NSObject {
    // 模块方法对应的selector
    @objc private(set) var methodSelector: Selector?
    // 模块方法对应的别名
    private(set) var methodName: String?
    // true表示是类方法，false表示是实例方法，默认false
    private(set) var isClassMethod = false
    // 是否开启类型检查
    private(set) var isCheckingType = false
    
    override init() {
        super.init()
    }
   
    @discardableResult
    @objc public func setName(_ name: String) -> ModuleMethod {
        self.methodName = name
        return self
    }
    
    @discardableResult
    @objc public func setSelector(selector: Selector) -> ModuleMethod {
        self.methodSelector = selector
        return self
    }
    
    @discardableResult
    @objc public func setIsClassMethod(_ isClassMethod: Bool) -> ModuleMethod {
        self.isClassMethod = isClassMethod
        return self
    }
    
    @discardableResult
    @objc public func setIsOpenTypeChecking(_ isCheckingType: Bool) -> ModuleMethod {
        self.isCheckingType = isCheckingType
        return self
    }
}

