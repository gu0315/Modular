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
                    // 如果实现了moduleDescription协议为设置moduleName
                    assert(!moduleDes.moduleName.isEmpty, "❌❌❌❌❌❌ in \(String(cString: class_getName(cls))), moduleName is undefined, please check!")
                    // 是否重复设置了模块名
                    assert((tmpCache[moduleDes.moduleName] == nil), "❌❌❌❌❌❌ in \(String(cString: class_getName(cls))), module \(moduleDes.moduleName) has defined, please check!")
                    tmpCache[moduleDes.moduleName] = moduleDes
                }
            }
        }
        Module.moduleCache = tmpCache
    }
    
    @objc public func invokeWithModuleName(_ moduleName: String,
                                 selectorName: String,
                                 params: Any? = nil,
                                 callback: Any? = nil) {
        let moduleDescription = Module.moduleCache[moduleName]
        let method = moduleDescription?.moduleMethods[selectorName]
        if ((method) != nil) {
            method?.performWithParams(param: params, callback: callback)
        }
    }
    
    
    @objc public func invokeWithUrl(_ url: String,
                                    params: Any? = nil,
                                    callback: Any? = nil) {
        // TODO 解析URL
        
    }
}


extension UIViewController {
    // 获取最顶层的控制器
    @objc static func applicationTopVC() -> UIViewController? {
        var window: UIWindow? = UIApplication.shared.windows[0]
        if window?.windowLevel != UIWindow.Level.normal {
            let windows = UIApplication.shared.windows
            for tmpWin: UIWindow in windows {
                if tmpWin.windowLevel == UIWindow.Level.normal {
                    window = tmpWin
                    break
                }
            }
        }
        return self.topViewControllerWithRootViewController(rootViewController: window?.rootViewController)
    }
    
    static func topViewControllerWithRootViewController(rootViewController: UIViewController?) -> UIViewController? {
        if rootViewController == nil {
            print("❌❌❌❌❌❌无根控制器❌❌❌❌❌❌")
            return nil
        }
        if let vc = rootViewController as? UITabBarController {
            if vc.viewControllers != nil {
                return topViewControllerWithRootViewController(rootViewController: vc.selectedViewController)
            } else {
                return vc
            }
        } else if let vc = rootViewController as? UINavigationController {
            if vc.viewControllers.count > 0 {
                return topViewControllerWithRootViewController(rootViewController: vc.visibleViewController)
            } else {
                return vc
            }
        } else if let vc = rootViewController as? UISplitViewController {
            if vc.viewControllers.count > 0 {
                return topViewControllerWithRootViewController(rootViewController: vc.viewControllers.last)
            } else {
                return vc
            }
        } else if let vc = rootViewController?.presentedViewController {
            return topViewControllerWithRootViewController(rootViewController: vc)
        } else {
            return rootViewController
        }
    }
}
