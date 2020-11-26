//
//  BridgeWebViewDelegate.swift
//  DSBridge
//
//  Created by boye on 2020/11/25.
//  Copyright © 2020 boye. All rights reserved.
//

import UIKit

protocol BridgeWebViewProtocol {
    
    @discardableResult
    func handleMethod(_ method: String, arg: Any?, completionHandler: BridgeWebView.BridgeCompletionHandler?) -> Any?
    
    func checkMethodType(_ method: String) -> BridgeMethodTypes
}

