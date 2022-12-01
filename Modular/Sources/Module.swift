//
//  Modular.swift
//  Modular
//
//  Created by 顾钱想 on 2022/11/22.
//

import UIKit

class Module: NSObject {
    
    static let share = Module()
    
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
    ///   - selectorName:   方法名
    ///   - params:  参数
    ///   - callback: 回调
    @objc public func invokeWithModuleName(_ moduleName: String,
                                 selectorName: String,
                                 params: [String: Any]? = nil,
                                 callback: Any? = nil) {
        let moduleDescription = Module.moduleCache[moduleName]
        let method = moduleDescription?.moduleMethods[selectorName]
        if ((method) != nil) {
            method?.performWithParams(params: params, callback: callback)
        }
    }
    
    ///  通过url调用
    /// - Parameters:
    ///   - url: 协议  scheme://selectorName/moduleName?params   ->  scheme://open/myWallet?code=1111
    ///   - callback: 回调
    @objc public func invokeWithUrl(_ url: String,
                                    callback: Any? = nil) {
        guard let url = URL.init(string: url) else {
            return
        }
        var module_name = ""
        if url.pathComponents.count > 0 {
            assert(url.pathComponents.count == 2, "❌❌❌❌❌❌ 请检查这个协议\(url)的moduleName设置是否正确")
            var names = url.pathComponents
            names.remove(at: 0)
            module_name = names.first ?? ""
        }
        let selectorName = url.host ?? ""
        var module_params: [String: Any] = [:]
        if ((url.query) != nil) {
            for pair in url.query!.components(separatedBy: "&") {
                let key = pair.components(separatedBy: "=")[0]
                let value = pair
                    .components(separatedBy:"=")[1]
                    .replacingOccurrences(of: "+", with: " ")
                    .removingPercentEncoding ?? ""
                module_params[key] = value
            }
        }
        self.invokeWithModuleName(module_name, selectorName: selectorName, params: module_params, callback: callback)
    }
}

