//
//  InternalApis.swift
//  DSBridge
//
//  Created by boye on 2020/11/9.
//  Copyright © 2020 boye. All rights reserved.
//

import UIKit

class InternalApis {
    weak var webView: BridgeWebView?
    
    func hasNativeMethod(args: [String: Any]?) -> Any {
        return webView?.onMessage(args, type: .hasNativeMethod) as Any
    }
    
    func closePage(args: [String: Any]?) -> Any {
        return webView?.onMessage(args, type: .closePage) as Any
    }
    
    func returnValue(args: [String: Any]?) -> Any {
        return webView?.onMessage(args, type: .returnValue) as Any
    }
    
    func dsinit(args: [String: Any]?) -> Any {
        return webView?.onMessage(args, type: .dsinit) as Any
    }
    
    func disableJavascriptDialogBlock(args: [String: Any]?) -> Any {
        return webView?.onMessage(args, type: .disableSafetyAlertBox) as Any
    }
}

extension InternalApis: BridgeWebViewProtocol {
    func checkMethodType(_ method: String) -> BridgeMethodTypes {
        guard let method = JSUtils.BridgeAPI(rawValue: method) else {
            return .cantCall
        }
        switch method {
        case .closePage,
             .hasNativeMethod,
             .returnValue,
             .disableSafetyAlertBox,
             .dsinit:
            return.canCallSyn
        }
    }
    
    func handleMethod(_ method: String, arg: Any?, completionHandler: BridgeWebView.BridgeCompletionHandler?) -> Any? {
        guard let method = JSUtils.BridgeAPI(rawValue: method) else {
            return nil
        }
        switch method {
        case .closePage:
            return closePage(args: arg as? [String: Any])
        case .hasNativeMethod:
            return hasNativeMethod(args: arg as? [String: Any])
        case .returnValue:
            return returnValue(args: arg as? [String: Any])
        case .dsinit:
            return dsinit(args: arg as? [String: Any])
        case .disableSafetyAlertBox:
            return disableJavascriptDialogBlock(args: arg as? [String: Any])
        }
    }
}
