//
//  Modular.swift
//  Modular
//  核心类
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
                let moduleDes: ModuleDescription
                if cls.responds(to: Selector.init(("moduleDescriptionWithDescription:"))) {
                    print(String(cString: class_getName(cls)))
                    moduleDes = ModuleDescription.init(moduleClass: cls)
                    cls.moduleDescription?(description: moduleDes)
                } else {
                    moduleDes = compatibleModuleWithClass(cls: cls)
                }
                assert(((moduleDes.moduleName?.isEmpty) != nil), "moduleName is nil")
                assert((tmpCache[moduleDes.moduleName ?? ""] == nil), "in \(String(cString: class_getName(cls))), module \(moduleDes.moduleName ?? "") has defined, please check!")
                tmpCache[moduleDes.moduleName ?? ""] = moduleDes
            }
        }
        Module.moduleCache = tmpCache
    }
    
    private func compatibleModuleWithClass(cls: AnyClass) -> ModuleDescription {
        // TODO
        return ModuleDescription.init(moduleClass: cls)
    }
    
    @objc public func moduleName(moduleName: String,
                                 performSelectorName: String,
                                 param: Any? = nil,
                                 otherParam: Any? = nil) {
        let moduleDescription = Module.moduleCache[moduleName]
        let method = moduleDescription?.moduleMethods[performSelectorName]
        if ((method) != nil) {
            method?.performWithParams(param: param, otherParam: otherParam)
        }
    }
}


extension UIViewController {
    
    @objc static func applicationTopVC() -> UIViewController? {
        var window: UIWindow? = UIApplication.shared.keyWindow
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
            print("xxxxxxxx无根控制器xxxxxxxx")
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
