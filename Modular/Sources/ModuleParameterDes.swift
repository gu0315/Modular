//
//  ModuleParameterIterator.swift
//  Modular
//
//  Created by 顾钱想 on 2023/6/1.
//

import UIKit
import ObjectiveC

@objc public enum ModuleParameterType: Int, Equatable {
    /// 字符串类型,参数会被转为NSString
    case String = 0
    /// 数字类型，参数会被转为NSNumber
    case Number
    /// 字典类型，参数对应的name如果无法找到或者参数不是字典类型，模块接收到的所有参数组成的字典会被传入该参数，map支持strict模式
    case Map
    /// 数组类型
    case Array
    /// block类型，模块接收的block会被传入该类型对应的参数
    case Block
    /// 其他对象类型，比如UIImage
    case Object
    /// 参数初始化类型
    case Unknown
    /// 函数返回空值类型，默认的函数返回值类型
    case Empty
    
    var type: AnyObject {
        switch self {
        case .String:
            return NSString.self
        case .Number:
            return NSNumber.self
        case .Map:
            return NSDictionary.self
        case .Array:
            return NSArray.self
        case .Block:
            return NSObject.self
        case .Object:
            return NSObject.self
        case .Unknown:
            return NSObject.self
        case .Empty:
            return NSObject.self
        }
    }
    
    public static func ==(lhs: ModuleParameterType, rhs: ModuleParameterType) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}


@objc public class ModuleParameter: NSObject {
    // 参数别名
    var paramName: String
    // 参数类型
    var paramType: ModuleParameterType

    init(paramName: String, paramType: ModuleParameterType) {
        self.paramName = paramName
        self.paramType = paramType
    }
    
    func name(_ paramName: String) -> ModuleParameter {
        self.paramName = paramName
        return self
    }
    
    func type(_ paramType: ModuleParameterType) -> ModuleParameter {
        self.paramType = paramType
        return self
    }
    
    @discardableResult
    @objc func add(paramName: String,  paramType: ModuleParameterType, isStrict: Bool = false) -> ModuleParameter {
        self.paramName = paramName
        self.paramType = paramType
        return self
    }
    
}

public class ModuleParameterDes: NSObject {
    var parameters: [ModuleParameter]
    private var currentIndex = 0
    
    init(parameters: [ModuleParameter], currentIndex: Int = 0) {
        self.parameters = parameters
        self.currentIndex = currentIndex
    }
    
    @objc func next() -> ModuleParameter? {
        if currentIndex <= parameters.count {
            // 初始化parameters为[], 自动添加
            parameters.append(ModuleParameter.init(paramName: "", paramType: .Unknown))
        }
        let parameter = parameters[currentIndex]
        currentIndex += 1
        return parameter
    }
    
    func reset() {
        currentIndex = 0
        parameters = []
    }
}
