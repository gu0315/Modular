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
        self.perform(moduleName: module_name, selectorName: module_method, params: url.module_params, callback: callback)
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
                              isDefault404: Bool = false) {
        // 获取模块描述和方法
        guard let moduleDescription = Module.moduleCache[moduleName],
              let moduleMethod = moduleDescription.moduleMethods[selectorName],
              let sel = moduleMethod.methodSelector else {
            open404IfNeeded(isDefault404)
            return
        }
        let cls: AnyClass = moduleDescription.moduleClass
        let paramsTypes = moduleMethod.parameterDes.parameters
        // 根据是类方法还是实例方法创建对象
        let obj: AnyObject
        if moduleMethod.isClassMethod {
            obj = cls
        } else {
            guard let objType = cls as? NSObject.Type else { return }
            obj = objType.init()
        }
        guard obj.responds(to: sel) else {
            open404IfNeeded(isDefault404)
            return
        }
        // 获取方法并检查参数数量
        if let method = moduleMethod.isClassMethod ? class_getClassMethod(cls, sel) : class_getInstanceMethod(cls, sel) {
            let argumentsCount = method_getNumberOfArguments(method)
            let expectedParamsCount = argumentsCount - 2
            // 参数数量断言
            assert(expectedParamsCount <= paramsTypes.count, "请描述所有参数，实际参数数量不足")
            assert(expectedParamsCount <= 2, "方法的参数个数大于2，不符合预期")
        }
        // 调用安全执行函数
        safePerformWithNSObject(obj: obj, sel: sel, params: params, paramsTypes: paramsTypes, callback: callback)
    }
    
    private func safePerformWithNSObject(obj: AnyObject,
                                         sel: Selector,
                                         params: [String: Any],
                                         paramsTypes: [ModuleParameter],
                                         callback: (@convention(block) ([AnyHashable: AnyObject]) -> Void)? = nil) {
        // 无参数的情况
        guard paramsTypes.count > 0 else {
            _ = obj.perform(sel)
            return
        }
        // 提取第一个参数信息
        let firstParamName = paramsTypes[0].paramName
        let firstParamType = paramsTypes[0].paramType
        let firstParamValue = params[firstParamName]
        // 处理单个参数
        if paramsTypes.count == 1 {
            // 如果是 Block 且存在回调，直接调用
            if firstParamType == .Block, let callback = callback {
                _ = obj.perform(sel, with: callback)
            } else if checkType(value: firstParamValue as Any, type: firstParamType) {
                _ = obj.perform(sel, with: firstParamValue)
            } else {
                assert(false, "\(firstParamName)参数类型不匹配")
            }
            return
        }
        // 提取第二个参数信息
        let secondParamName = paramsTypes[1].paramName
        let secondParamType = paramsTypes[1].paramType
        let secondParamValue = params[secondParamName]
        // 处理两个参数的情况
        if paramsTypes.count == 2 {
            let firstCheck = checkType(value: firstParamValue as Any, type: firstParamType)
            let secondCheck = checkType(value: secondParamValue as Any, type: secondParamType)
            // 如果第一个参数匹配且回调为 Block，进行相应调用
            if secondParamType == .Block, let callback = callback {
                if firstCheck {
                    _ = obj.perform(sel, with: firstParamValue, with: callback)
                } else {
                    assert(false, "\(firstParamName)参数类型不匹配")
                }
            }
            // 如果两个参数都匹配，执行两个参数的调用
            else if firstCheck && secondCheck {
                _ = obj.perform(sel, with: firstParamValue, with: secondParamValue)
            } else {
                assert(false, "类型不匹配")
            }
        }
    }
    
    func checkType(value: Any, type: ModuleParameterType) -> Bool {
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

    private func open404IfNeeded(_ isDefault404: Bool) {
        if !isDefault404 {
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
        self.perform(moduleName: module_name, selectorName: module_method, params: url.module_params, callback: nil, isDefault404: true)
    }
}
