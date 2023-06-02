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
    // 参数描述
    private(set) var parameterDes: ModuleParameterDes = {
        return ModuleParameterDes.init(parameters: [])
    }()
    
    override init() {
        super.init()
    }
   
    @discardableResult
    @objc public func name(_ name: String) -> ModuleMethod {
        self.methodName = name
        return self
    }
    
    @discardableResult
    @objc public func selector(selector: Selector) -> ModuleMethod {
        self.methodSelector = selector
        return self
    }
    
    @discardableResult
    @objc public func classMethod(_ isClassMethod: Bool) -> ModuleMethod {
        self.isClassMethod = isClassMethod
        return self
    }
    
    /// 参数说明
    /// - Parameter parameterDescriptionClosure: 设置参数的类型，参数的名称
    @discardableResult
    @objc public func parameterDescription(_ parameterDescriptionClosure:@escaping (_ enumerator: ModuleParameterDes) -> ()) -> ModuleMethod {
        if ((self.methodSelector) != nil) {
            parameterDes.reset()
            parameterDescriptionClosure(parameterDes)
        }
        return self
    }
}

