//
//  ModuleMethod.swift
//  Modular
//
//  Created by 顾钱想 on 2022/11/23.
//

import UIKit

public class ModuleMethod: NSObject {
    // 模块方法对应的selector
    var methodSelector: Selector?
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
    
    // 执行方法
    @objc public func performCallbackWithParams(params: Any? = nil,
                                        callback: @escaping @convention(block) ([String: Any]) -> Void) {
        let cls: AnyClass = self.module!.moduleClass
        guard let objcet = cls as? NSObject.Type else { return }
        guard let sel = self.methodSelector else { return }
        if (self.isClassMethod) {
            // 类方法调用
            objcet.perform(sel, with: params, with: callback)
        } else {
            // 实列方法调用
            objcet.init().perform(sel, with: params, with: callback)
        }
    }
    
    @objc public func performWithParams(params: Any? = nil) {
        let cls: AnyClass = self.module!.moduleClass
        guard let objcet = cls as? NSObject.Type else { return }
        guard let sel = self.methodSelector else { return }
        if (self.isClassMethod) {
            // 类方法调用
            objcet.perform(sel, with: params)
        } else {
            // 实列方法调用
            objcet.init().perform(sel, with: params)
        }
    }
}
