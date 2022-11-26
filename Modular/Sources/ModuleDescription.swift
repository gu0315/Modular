//
//  ModuleDescription.swift
//  Modular
//
//  Created by 顾钱想 on 2022/11/22.
//

import UIKit

public class ModuleDescription: NSObject {
    // 协议的类做绑定
    var moduleClass: AnyClass
    // 为类设置别名
    public var moduleName: String?
    // 模块和方法绑定
    var moduleMethods: Dictionary<String, ModuleMethod> = [:]
    
    // 为兼容Objcet-C链式调用
    @objc var moduleNameClosure: ((String) -> ModuleDescription)?

    @objc var methodClosure: (((ModuleMethod)->()) -> ModuleDescription)?
    
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
                moduleMethod.module = self
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
    @objc func moduleName(_ name: String) ->ModuleDescription {
        moduleName = name
        return self
    }
   
    @discardableResult
    @objc func method(methodDescriptionClosure:(ModuleMethod)->())-> ModuleDescription {
        let moduleMethod = ModuleMethod()
        moduleMethod.module = self
        methodDescriptionClosure(moduleMethod)
        self.moduleMethods[moduleMethod.methodName ?? ""] = moduleMethod
        return self
    }
}

