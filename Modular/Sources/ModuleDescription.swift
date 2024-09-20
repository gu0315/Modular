//
//  ModuleDescription.swift
//  Modular
//
//  Created by 顾钱想 on 2022/11/22.
//

import UIKit

@objc(ModuleProtocol)

public protocol ModuleProtocol: NSObjectProtocol {
    /// 模块描述协议
    @objc static func moduleDescription(description: ModuleDescription)
}

public class ModuleDescription: NSObject {
    // 实现协议的类做绑定
    var moduleClass: AnyClass
    // 模块名称
    var moduleName: String = ""
    // 模块关联的方法
    var moduleMethods: Dictionary<String, ModuleMethod> = [:]

    // Objcet-C链式调用设置moduleName
    @objc public var moduleNameClosure: ((String) -> ModuleDescription)?
    // Objcet-C链式调用设置method
    @objc public var methodClosure: (((ModuleMethod)->()) -> ModuleDescription)?
    
    init(moduleClass: AnyClass) {
        self.moduleClass = moduleClass
        super.init()
        if (self.moduleNameClosure == nil) {
            self.moduleNameClosure = { name  in
                self.moduleName = name
                return self
            }
        }
        if (self.methodClosure == nil) {
            self.methodClosure = { methodDescriptionClosure in
                let moduleMethod = ModuleMethod()
                methodDescriptionClosure(moduleMethod)
                self.moduleMethods[moduleMethod.methodName ?? ""] = moduleMethod
                return self
            }
        }
    }
   
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    @objc public func moduleName(_ name: String) ->ModuleDescription {
        moduleName = name
        return self
    }
   
    @discardableResult
    @objc public func method(methodDescriptionClosure:(ModuleMethod)->())-> ModuleDescription {
        let moduleMethod = ModuleMethod()
        methodDescriptionClosure(moduleMethod)
        self.moduleMethods[moduleMethod.methodName ?? ""] = moduleMethod
        return self
    }
}

