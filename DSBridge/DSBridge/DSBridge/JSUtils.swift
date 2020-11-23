//
//  JSUtils.swift
//  DSBridge
//
//  Created by boye on 2020/11/9.
//  Copyright © 2020 boye. All rights reserved.
//

import UIKit

class JSUtils {
    enum BridgeAPI {
        case hasNativeMethod
        case closePage
        case returnValue
        case dsinit
        case disableSafetyAlertBox
    }
    
    static func objToJsonString(_ dict: Any) -> String {
        let defaultJsonString: String = "{}"
        if !JSONSerialization.isValidJSONObject(dict) {
            return defaultJsonString
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.init(rawValue: 0)),
            let jsonString = String(data: jsonData, encoding: .utf8) else {
            return defaultJsonString
        }
        
        return jsonString
    }
    
    static func jsonStringToObject(_ jsonString: String?) -> [AnyHashable: Any]? {
        guard let jsonString = jsonString,
            let jsonData = jsonString.data(using: .utf8),
            let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [AnyHashable: Any] else {
            return nil
        }
        return dict
    }
    
    static func allMethodFromClass(_ clazz: AnyClass?) -> [String] {
        var methods = [String]()
        var tmpClazz: AnyClass? = clazz
        while tmpClazz != nil {
            var count: UInt32 = 0
            let method = class_copyMethodList(tmpClazz, &count)
            var i: UInt32 = 0
            while i < count {
                let name1 = method_getName((method?[Int(i)])!)
                let selName = sel_getName(name1)
                if let strName = String(cString: selName, encoding: .utf8) {
                    methods.append(strName)
                }
                i += 1
            }
            free(method)
            guard let cls = class_getSuperclass(tmpClazz) else {
                return methods
            }
            tmpClazz = NSStringFromClass(cls) == NSStringFromClass(NSObject.self) ? nil : cls
            
        }
        
        return methods
    }
    
    static func methodByName(argNum: Int, selName: String, clazz: AnyClass) -> String? {
        var result: String?
        
        let array = JSUtils.allMethodFromClass(clazz)
        
        for method in array {
            let tmpArray = method.components(separatedBy: ":")
            let range = (method as NSString).range(of: ":")
            if range.length > 0 {
                let methodName = (method as NSString).substring(with: NSRange(location: 0, length: range.location))
                if methodName == selName && tmpArray.count == argNum + 1 {
                    result = method
                    return result
                }
            }
        }
        
        return result
    }

    static func parseNamespace(_ method: String) -> [Any] {
        let range = (method as NSString).range(of: ".", options: .backwards)
        var namespace = ""
        var result = method
        if range.location != NSNotFound {
            namespace = (method as NSString).substring(to: range.location)
            result = (method as NSString).substring(to: range.location + 1)
        }
        
        return [namespace, result]
    }
}
