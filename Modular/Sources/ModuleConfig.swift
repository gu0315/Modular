//
//  ModuleConfig.swift
//  Modular
//
//  Created by 顾钱想 on 2023/8/22.
//

import UIKit

class ModuleConfig: NSObject {
    
    private var default404ModuleURL: String?
    
    public static let share = ModuleConfig()
    
    private override init() {
        super.init()
    }
    
    public func override404ModuleURL(_ url: String) {
        default404ModuleURL = url
    }
}
