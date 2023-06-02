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
                                callback:(@convention(block) ([AnyHashable: AnyObject]) -> Void)?){
        let url = ModuleURL.init(url: url)
        guard let module_name = url.module_name, let module_method = url.module_method else {
            return
        }
        self.perform(moduleName: module_name, selectorName: module_method, params: url.module_params, callback: callback, isUrl: true)
    }
    
    /// 通过moduleName调用
    /// - Parameters:
    ///   - moduleName: 模块名
    ///   - selectorName: 模块方法
    ///   - params:  模块参数
    ///   - callback: 模块回调
    @objc public func perform(moduleName: String,
                                          selectorName: String,
                                                params: [String: Any],
                                              callback: (@convention(block) ([AnyHashable: AnyObject]) -> Void)? = nil,
                                                 isUrl: Bool = false){
        let moduleDescription = Module.moduleCache[moduleName]
        let moduleMethod = moduleDescription?.moduleMethods[selectorName]
        if ((moduleMethod) != nil) {
            let cls: AnyClass = moduleDescription!.moduleClass
            guard let obj = cls as? NSObject.Type else { return }
            guard let sel = moduleMethod!.methodSelector else { return }
            let paramsTypes = moduleMethod?.parameterDes.parameters
            // TODO 构造校验参数
            if (moduleMethod!.isClassMethod) {
                guard obj.responds(to: sel) else { return }
                let ivar_Method = class_getClassMethod(cls, sel)
                if ((ivar_Method) != nil) {
                    let argumentsCount = method_getNumberOfArguments(ivar_Method!)
                    assert(!(argumentsCount - 2 > paramsTypes?.count ?? 0),"请描述所有参数")
                    assert(!(argumentsCount - 2 > 2),"参数大于2异常")
                }
                safePerformWithNSObject(obj: obj, sel: sel, params: params, paramsTypes: paramsTypes ?? [], callback: callback)
            } else {
                guard obj.init().responds(to: sel) else {
                    // TODO 处理无响应请求, 自定义404页面
                    return
                }
                let ivar_Method = class_getInstanceMethod(cls, sel)
                if ((ivar_Method) != nil) {
                    let argumentsCount = method_getNumberOfArguments(ivar_Method!)
                    assert(!(argumentsCount - 2 > paramsTypes?.count ?? 0),"请描述所有参数")
                    assert(!(argumentsCount - 2 > 2),"参数大于2异常")
                }
                safePerformWithNSObject(obj: obj.init(), sel: sel, params: params, paramsTypes: paramsTypes ?? [], callback: callback)
            }
        } else {
            // TODO 处理无响应请求, 自定义404页面
            if (isUrl) {
                print("未找到模块方法-----404")
            }
        }
    }
    
    
    private func safePerformWithNSObject(obj: AnyObject,
                                         sel: Selector,
                                         params: [String: Any],
                                         paramsTypes: [ModuleParameter],
                                         callback: (@convention(block) ([AnyHashable: AnyObject]) -> Void)? = nil) {
        if (paramsTypes.count == 0) {
            _ = obj.perform(sel)
        } else {
            let paramsName = paramsTypes[0].paramName
            // TODO 检验参数类型
            // let paramsType = paramsTypes[0].paramType
            let paramValue = params[paramsName]
            if (paramsTypes.count == 1 ) {
                // TODO
                _ = obj.perform(sel, with: paramValue)
            } else {
                // TODO
                _ = obj.perform(sel, with: paramValue, with: callback)
            }
        }
    }
    

    func checkType<T>(_ value: T, isType expectedType: T.Type) -> Bool {
        return type(of: value) == expectedType
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
}

