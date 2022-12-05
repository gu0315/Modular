//
//  Modular.swift
//  Modular
//
//  Created by 顾钱想 on 2022/11/22.
//

import UIKit

public class Module: NSObject {
    
    public static let share = Module()
    
    static var moduleCache: Dictionary<String, ModuleDescription> = [:]
    
    
    private override init() {
        super.init()
        self.cacheModuleProtocolClasses()
    }
    
    private func cacheModuleProtocolClasses() {
        if ((Module.moduleCache.count) != 0) {
            return
        }
        var count: UInt32 = 0
        let classList = objc_copyClassList(&count)!
        defer { free(UnsafeMutableRawPointer(classList)) }
        let classes = UnsafeBufferPointer(start: classList, count: Int(count))
        var tmpCache: Dictionary<String, ModuleDescription> = [:]
        for cls in classes {
            if (class_conformsToProtocol(cls, ModuleProtocol.self)) {
                if cls.responds(to: Selector.init(("moduleDescriptionWithDescription:"))) {
                    let moduleDes: ModuleDescription
                    // 关联
                    moduleDes = ModuleDescription.init(moduleClass: cls)
                    cls.moduleDescription?(description: moduleDes)
                    // 实现了moduleDescription协议未设置moduleName
                    assert(!moduleDes.moduleName.isEmpty, "❌❌❌❌❌❌ in \(String(cString: class_getName(cls))), moduleName is undefined, please check!")
                    // 重复设置了模块名
                    assert((tmpCache[moduleDes.moduleName] == nil), "❌❌❌❌❌❌ in \(String(cString: class_getName(cls))), module \(moduleDes.moduleName) has defined, please check!")
                    tmpCache[moduleDes.moduleName] = moduleDes
                }
            }
        }
        Module.moduleCache = tmpCache
    }

    /// 通过moduleName调用
    /// - Parameters:
    ///   - moduleName: 模块名
    ///   - selectorName: 模块方法
    ///   - params:  模块参数
    ///   - callback: 模块回调
    @objc public func invokeWithModuleNameCallback(_ moduleName: String,
                                 selectorName: String,
                                 params: [String: Any]? = nil,
                                 callback: @escaping @convention(block) ([String: Any]) -> Void) {
        let moduleDescription = Module.moduleCache[moduleName]
        let method = moduleDescription?.moduleMethods[selectorName]
        if ((method) != nil) {
            method?.performCallbackWithParams(params: params, callback: callback)
        }
    }
    
    /// 通过moduleName调用
    /// - Parameters:
    ///   - moduleName: 模块名
    ///   - selectorName: 模块方法
    ///   - params:  模块参数
    @objc public func invokeWithModuleName(_ moduleName: String,
                                 selectorName: String,
                                 params: [String: Any]? = nil){
        let moduleDescription = Module.moduleCache[moduleName]
        let method = moduleDescription?.moduleMethods[selectorName]
        if ((method) != nil) {
            method?.performWithParams(params: params)
        }
    }
    
    ///  通过url调用
    /// - Parameters:
    ///   - url: 协议  scheme://selectorName/moduleName?params   ->  scheme://open/myWallet?code=1111
    @objc public func invokeWithUrl(_ url: String){
        let url = ModuleURL.init(url: url)
        self.invokeWithModuleName(url.module_name, selectorName: url.module_method, params: url.module_params)
    }
    
    ///  通过url调用
    /// - Parameters:
    ///   - url: 协议  scheme://selectorName/moduleName?params   ->  scheme://open/myWallet?code=1111
    @objc public func invokeWithUrlCallback(_ url: String,
                                            callback: @escaping @convention(block) ([String: Any]) -> Void){
        let url = ModuleURL.init(url: url)
        self.invokeWithModuleNameCallback(url.module_name, selectorName: url.module_method, params: url.module_params, callback: callback)
    }
}


