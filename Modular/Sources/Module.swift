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
                    assert(!moduleDes.moduleName.isEmpty, "in \(String(cString: class_getName(cls))), moduleName is undefined, please check!")
                    // 重复设置了模块名
                    assert((tmpCache[moduleDes.moduleName] == nil), "in \(String(cString: class_getName(cls))), module \(moduleDes.moduleName) has defined, please check!")
                    tmpCache[moduleDes.moduleName] = moduleDes
                }
            }
        }
        Module.moduleCache = tmpCache
    }

    ///  通过url调用
    /// - Parameters:
    ///   - url: 协议  scheme://selectorName/moduleName?params   ->  scheme://open/myWallet?code=1111
    ///   - callback: 模块回调
    @objc public func performWithUrl(url: String,
                                callback:(@convention(block) ([AnyHashable: Any]) -> Void)?){
        let url = ModuleURL.init(url: url)
        guard let module_name = url.module_name, let module_method = url.module_method else {
            return
        }
        self.performWithModuleName(moduleName: module_name, selectorName: module_method, params: url.module_params, callback: callback, isUrl: true)
    }
    
    /// 通过moduleName调用
    /// - Parameters:
    ///   - moduleName: 模块名
    ///   - selectorName: 模块方法
    ///   - params:  模块参数
    ///   - callback: 模块回调
    @objc public func performWithModuleName(moduleName: String,
                                          selectorName: String,
                                                params: [String: Any],
                                              callback: (@convention(block) ([AnyHashable: Any]) -> Void)?,
                                                 isUrl: Bool = false){
        let moduleDescription = Module.moduleCache[moduleName]
        let moduleMethod = moduleDescription?.moduleMethods[selectorName]
        if ((moduleMethod) != nil) {
            let cls: AnyClass = moduleDescription!.moduleClass
            guard let obj = cls as? NSObject.Type else { return }
            guard let sel = moduleMethod!.methodSelector else { return }
            if (moduleMethod!.isClassMethod) {
                guard obj.responds(to: sel) else { return }
                let ivar_Method = class_getClassMethod(cls, sel)
                if ((ivar_Method) != nil) {
                    let argumentsCount = method_getNumberOfArguments(ivar_Method!)
                    if (argumentsCount - 2 > 2) {
                        print("参数大于2")
                        invocationWithClass(cls: cls, sel: sel, isClassMethod: moduleMethod!.isClassMethod, params: params, callback: callback)
                        return
                    }
                }
                obj.perform(sel, with: params, with: callback ?? nil)
            } else {
                let ivar_Method = class_getInstanceMethod(cls, sel)
                if ((ivar_Method) != nil) {
                    let argumentsCount = method_getNumberOfArguments(ivar_Method!)
                    if (argumentsCount - 2 > 2) {
                        print("参数大于2")
                        invocationWithClass(cls: cls, sel: sel, isClassMethod: moduleMethod!.isClassMethod, params: params, callback: callback)
                        return
                    }
                }
                let _class = obj.init()
                guard _class.responds(to: sel) else { return }
                _class.perform(sel, with: params, with: callback ?? nil)
            }
        } else {
            // TODO 自定义404页面
            if (isUrl) {
                print("未找到模块方法-----404")
            }
        }
    }
    
    /// RN 使用，动态注册模块描述, 优先级较高，可以覆盖原来的模块描述
    /// - Parameter modules: 模块描述数组
    @objc public func registerModules(modules: Array<ModuleDescription>) {
        var tmpCache: Dictionary<String, ModuleDescription> = Module.moduleCache
        for (_, moduleDes) in modules.enumerated() {
            tmpCache[moduleDes.moduleName] = moduleDes
        }
        Module.moduleCache = tmpCache
    }
    
    /// Invocation调用
    /// 通过func perform(_ aSelector: Selector!, with object1: Any!, with object2: Any!) -> Unmanaged<AnyObject>! 最多只能传两个参数, 可以用Invocation传多个参数
    @objc public func invocationWithClass(cls: AnyClass,
                                          sel: Selector,
                                isClassMethod: Bool,
                                       params: [String: Any],
                               callback: (@convention(block) ([AnyHashable: Any]) -> Void)?) {
        invocation(with: cls, sel: sel, isClassMethod: isClassMethod, params: params) { dic in
            if ((callback) != nil) {
                callback!(dic ?? [:])
            }
        }
    }
}

