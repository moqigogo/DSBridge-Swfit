//
//  BridgeWebViewDelegate.swift
//  DSBridge
//
//  Created by boye on 2020/11/25.
//  Copyright © 2020 boye. All rights reserved.
//

import UIKit

protocol BridgeWebViewProtocol {
    
    func handleMethod(_ method: String, arg: Any?, completionHandler: ((Any?, Bool)->Void)?) -> Any?
    
    func checkMethodType(_ method: String) -> BridgeMethodTypes
}

