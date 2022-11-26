//
//  ModuleProtocol.swift
//  Modular
//
//  Created by 顾钱想 on 2022/11/22.
//

import UIKit

@objc (ModuleProtocol)

public protocol ModuleProtocol: NSObjectProtocol {
    /// 模块描述协议
    @objc static func moduleDescription(description: ModuleDescription)
}
