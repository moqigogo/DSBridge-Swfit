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
    
    func hasNativeMethod(args: Any?) -> Any {
        return webView?.onMessage(args as? [String: Any], type: .hasNativeMethod) as Any
    }
}
