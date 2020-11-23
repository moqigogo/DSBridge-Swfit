//
//  InternalApis.swift
//  DSBridge
//
//  Created by boye on 2020/11/9.
//  Copyright © 2020 boye. All rights reserved.
//

import UIKit

class InternalApis: NSObject {
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
