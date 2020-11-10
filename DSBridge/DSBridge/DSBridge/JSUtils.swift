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
    
    static func objToJsonString(_ dict: AnyObject?) -> String? {
        return nil
    }
    
    static func jsonStringToObject(_ jsonString: String) -> AnyObject? {
        return nil
    }
    
    static func methodByName(arg: Int, selName: String?, clazz: AnyClass) -> String? {
        return nil
    }

    static func parseNamespace(_ method: String) -> [Any] {
        return [Any]()
    }
}
