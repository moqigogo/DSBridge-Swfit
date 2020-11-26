//
//  JSUtils.swift
//  DSBridge
//
//  Created by boye on 2020/11/9.
//  Copyright © 2020 boye. All rights reserved.
//

import UIKit

enum BridgeMethodTypes {
    case canCallAsyn
    case canCallSyn
    case cantCall
}

class JSUtils {
    enum BridgeAPI: String, CaseIterable {
        case hasNativeMethod = "hasNativeMethod"
        case closePage = "closePage"
        case returnValue = "returnValue"
        case dsinit = "dsinit"
        case disableSafetyAlertBox = "disableJavascriptDialogBlock"
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

    static func parseNamespace(_ method: String) -> [Any] {
        let range = (method as NSString).range(of: ".", options: .backwards)
        var namespace = ""
        var result = method
        if range.location != NSNotFound {
            namespace = (method as NSString).substring(to: range.location)
            result = (method as NSString).substring(from: range.location + 1)
        }
        
        return [namespace, result]
    }
    
    static func getCurShowingViewController(base: UIViewController? = UIApplication.shared.currentWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return getCurShowingViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return getCurShowingViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return getCurShowingViewController(base: presented)
        }
        if let split = base as? UISplitViewController{
            return getCurShowingViewController(base: split.presentingViewController)
        }
        return base
    }
}

extension UIApplication {
    var currentWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            if let window = connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?.windows
                .filter({$0.isKeyWindow}).first{
                return window
            }else if let window = UIApplication.shared.delegate?.window{
                return window
            }else{
                return nil
            }
        } else {
            if let window = UIApplication.shared.delegate?.window{
                return window
            }else{
                return nil
            }
        }
    }
}
