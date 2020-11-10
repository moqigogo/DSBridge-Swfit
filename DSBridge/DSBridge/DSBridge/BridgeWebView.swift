//
//  BridgeWebView.swift
//  DSBridge
//
//  Created by boye on 2020/11/9.
//  Copyright © 2020 boye. All rights reserved.
//

import UIKit
import WebKit

class BridgeWebView: WKWebView {
    typealias JSCallback = (_ result: String, _ complete: Bool)->Void
    
    weak var bridgeUIDelegate: WKUIDelegate?
    
    func loadURL(_ url: String) {
        
    }
    
    func callHandler(methodName: String, arguments: [Any]? = nil, completionHandler: ((_ value: Any)->Void)? = nil) {
        
    }
    
    func setJavascriptCloseWindowListener(_ callBack: (()->Void)?) {
        
    }
    
    func addJavascriptObject(_ handlerName: String, methodExistCallback: ((_ exist: Bool)->Void)) {
        
    }
    
    func setDebugMode(_ isDebug: Bool) {
        
    }
    
    func disableJavascriptDialogBlock(_ isDisable: Bool) {
        
    }
    
    func customJavascriptDialogLabelTitles(dict: [String: Any]?) {
        
    }
    
    func onMessage(_ msg: [String: Any]?, type: JSUtils.BridgeAPI) -> Any? {
        return nil
    }
}
