//
//  ModuleMethod.swift
//  Modular
//
//  Created by 顾钱想 on 2022/11/23.
//

import UIKit

class ModuleMethod: NSObject {
    // 模块方法对应的selector
    private var methodSelector: Selector?
    // 模块方法对应的别名
    var methodName: String?
    // true表示方法只能被native方式调用，false表示可以使用URL方式调用，默认false
    private var isNativeMethod = false
    // true表示是类方法，false表示是实例方法，默认false
    private var isClassMethod = false
    // 对所属module的弱引用
    weak var module: ModuleDescription?
    
    override init() {
        super.init()
    }
   
    @discardableResult
    @objc func name(_ name: String) ->ModuleMethod {
        self.methodName = name
        return self
    }
    
    @discardableResult
    @objc func selector(selector: Selector) -> ModuleMethod {
        self.methodSelector = selector
        return self
    }
    
    @discardableResult
    @objc func isNativeMethod(isNativeMethod: Bool) -> ModuleMethod {
        self.isNativeMethod = isNativeMethod
        return self
    }
    
    @discardableResult
    @objc func isClassMethod(isClassMethod: Bool) -> ModuleMethod {
        self.isClassMethod = isClassMethod
        return self
    }
    
    @objc func performWithParams(param: Any? = nil,
                                 otherParam: Any? = nil) {
        let cls: AnyClass = self.module!.moduleClass
        guard let objcet = cls as? NSObject.Type else {
            return
        }
        let controller = objcet.init()
        guard let selector = self.methodSelector else {
            return
        }
        controller.perform(selector, with: param, with: otherParam)
    }
    
    @objc func performWithUrl(url: String? = nil,
                              otherParam: Any? = nil) {
        if (self.isNativeMethod) {
            return
        }
        let cls: AnyClass = self.module!.moduleClass
        guard let objcet = cls as? NSObject.Type else {
            return
        }
        let controller = objcet.init()
        guard let selector = self.methodSelector else {
            return
        }
        controller.perform(selector, with: url, with: otherParam)
    }
}
