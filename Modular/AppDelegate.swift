//
//  AppDelegate.swift
//  Modular
//
//  Created by 顾钱想 on 2022/11/22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        _ = Module.share
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return handleOpenUrl(url)
    }

    func handleOpenUrl(_ url: URL, _ application: UIApplication? = nil) -> Bool {
        Module.share.invoke(url: url.absoluteString, callback: nil)
        return true
    }
}




extension NSObject {
    // 获取最顶层的控制器
    @objc class func applicationTopVC() -> UIViewController? {
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
