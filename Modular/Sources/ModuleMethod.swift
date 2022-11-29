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
    // true表示是类方法，false表示是实例方法，默认false
    var isClassMethod = false
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
    @objc func isClassMethod(_ isClassMethod: Bool) -> ModuleMethod {
        self.isClassMethod = isClassMethod
        return self
    }
    
    // 调用
    @objc func performWithParams(param: Any? = nil,
                                 callback: Any? = nil) {
        let cls: AnyClass = self.module!.moduleClass
        guard let objcet = cls as? NSObject.Type else {
            return
        }
        guard let selector = self.methodSelector else {
            return
        }
        if (self.isClassMethod) {
            objcet.perform(selector, with: param, with: callback)
        } else {
            let controller = objcet.init()
            controller.perform(selector, with: param, with: callback)
        }
    }
}
