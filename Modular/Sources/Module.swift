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
        self.perform(moduleName: module_name, selectorName: module_method, param: url.module_params, callback: callback)
    }
    
    
    /// - Parameters:
    ///   - moduleName: 模块名
    ///   - selectorName: 模块方法
    ///   - param: 参数1
    ///   - otherParam: 参数2
    @objc public func perform(moduleName: String,
                              selectorName: String,
                              param: Any? = nil,
                              otherParam: Any? = nil) {
        guard let (moduleDescription, moduleMethod, obj, sel, paramsTypes) = getModuleObjectAndMethod(moduleName: moduleName, selectorName: selectorName) else {
            open404IfNeeded()
            return
        }
        if checkParams(moduleMethod: moduleMethod, cls: moduleDescription.moduleClass, sel: sel, paramsTypes: paramsTypes) {
            safePerformWithNSObject(obj: obj, sel: sel, param: param, otherParam: otherParam, paramsTypes: paramsTypes)
        }
    }
    
    
    /// - Parameters:
    ///   - moduleName: 模块名
    ///   - selectorName: 模块方法
    ///   - params: 模块参数
    ///   - callback: 模块回调
    @objc public func perform(moduleName: String,
                              selectorName: String,
                              param: Any? = nil,
                              callback: (@convention(block) ([AnyHashable: AnyObject]) -> Void)? = nil) {
        guard let (moduleDescription, moduleMethod, obj, sel, paramsTypes) = getModuleObjectAndMethod(moduleName: moduleName, selectorName: selectorName) else {
            open404IfNeeded()
            return
        }
        if checkParams(moduleMethod: moduleMethod, cls: moduleDescription.moduleClass, sel: sel, paramsTypes: paramsTypes) {
            safePerformWithNSObject(obj: obj, sel: sel, param: param, otherParam: callback, paramsTypes: paramsTypes)
        }
    }
    
    
    /// 私有方法：提取公共逻辑，获取模块对象和方法选择器
    private func getModuleObjectAndMethod(moduleName: String,
                                          selectorName: String) -> (ModuleDescription, ModuleMethod, AnyObject, Selector, [ModuleParameter])? {
        guard let moduleDescription = Module.moduleCache[moduleName],
              let moduleMethod = moduleDescription.moduleMethods[selectorName],
              let sel = moduleMethod.methodSelector else {
            return nil
        }
        let cls: AnyClass = moduleDescription.moduleClass
        let paramsTypes = moduleMethod.parameterDes.parameters
        let obj: AnyObject
        if moduleMethod.isClassMethod {
            obj = cls
        } else {
            guard let objType = cls as? NSObject.Type else { return nil }
            obj = objType.init()
        }
        guard obj.responds(to: sel) else {
            return nil
        }
        return (moduleDescription, moduleMethod, obj, sel, paramsTypes)
    }
    
    private func safePerformWithNSObject(obj: AnyObject,
                                         sel: Selector,
                                         param: Any? = nil,
                                         otherParam: Any? = nil,
                                         paramsTypes: [ModuleParameter]) {
        guard paramsTypes.count > 0 else {
            _ = obj.perform(sel)
            return
        }
        // 处理单个参数
        if paramsTypes.count == 1 {
            let firstParamType = paramsTypes[0].paramType
            let firstCheck = !paramsTypes[0].isStrict || checkType(value: param, type: firstParamType)
            // 如果是 Block 且存在回调，直接调用
            if firstParamType == .Block, let callback = otherParam {
                _ = obj.perform(sel, with: callback)
            } else if firstCheck {
                _ = obj.perform(sel, with: param)
            } else {
                assert(false, "\(sel)参数类型不匹配")
            }
            return
        }
        // 处理两个参数的情况
        if paramsTypes.count == 2 {
            let firstParamType = paramsTypes[0].paramType
            let secondParamType = paramsTypes[1].paramType
            let firstCheck = !paramsTypes[0].isStrict || checkType(value: param, type: firstParamType)
            let secondCheck = !paramsTypes[1].isStrict || checkType(value: otherParam, type: secondParamType)
            if secondParamType == .Block, let callback = otherParam {
                if firstCheck {
                    _ = obj.perform(sel, with: param, with: callback)
                } else {
                    assert(false, "\(sel)参数类型不匹配")
                }
            }
            else if firstCheck && secondCheck {
                _ = obj.perform(sel, with: param, with: otherParam)
            } else {
                assert(false, "\(sel)参数类型不匹配")
            }
        }
    }
    
    func checkType(value: Any?, type: ModuleParameterType) -> Bool {
        switch type {
        case .String: return value is String
        case .Number: return value is NSNumber
        case .Map: return value is NSDictionary
        case .Array: return value is NSArray
        case .Block, .Object, .Unknown, .Empty: return true
        }
    }
    
    /// RN 使用，动态注册模块描述, 优先级较高，可以覆盖原来的模块描述
    /// - Parameter modules: 模块描述数组
    public func registerModules(modules: Array<ModuleDescription>) {
        var tmpCache: Dictionary<String, ModuleDescription> = Module.moduleCache
        for (_, moduleDes) in modules.enumerated() {
            tmpCache[moduleDes.moduleName] = moduleDes
        }
        Module.moduleCache = tmpCache
    }
}

extension Module {
    
    /// 校验参数
    private func checkParams(moduleMethod: ModuleMethod, cls: AnyClass, sel: Selector, paramsTypes: [ModuleParameter]) -> Bool {
        // 获取方法并检查参数数量
        if let method = moduleMethod.isClassMethod ? class_getClassMethod(cls, sel) : class_getInstanceMethod(cls, sel) {
            let argumentsCount = method_getNumberOfArguments(method)
            let expectedParamsCount = argumentsCount - 2
            assert(expectedParamsCount <= paramsTypes.count, "请描述\(method)所有参数")
            assert(expectedParamsCount <= 2, "\(method)方法的参数个数大于2，不符合预期")
        }
        return true
    }
}

extension Module {

    private func open404IfNeeded(_ isDefault404: Bool = true) {
        if isDefault404 {
            open404()
        }
    }
    
    private func open404() {
        guard let s = ModuleConfig.share.default404ModuleURL else {
            return
        }
        let url = ModuleURL.init(url: s)
        guard let module_name = url.module_name, let module_method = url.module_method else {
            return
        }
        self.perform(moduleName: module_name, selectorName: module_method, param: url.module_params, callback: nil)
    }
}
