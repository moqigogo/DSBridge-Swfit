//
//  PaylaterJSBridge.swift
//  DSBridge
//
//  Created by boye on 2020/11/24.
//  Copyright © 2020 boye. All rights reserved.
//

import UIKit

class PaylaterJSBridge {
    enum PaylaterJSBridgeMethods: String, CaseIterable {
        case close = "close"
        case loadCompleted = "loadCompleted"
        case deviceInfo = "deviceInfo"
        case mediaQuery = "mediaQuery"
        case goBack = "goBack"
        case setBackHook = "setBackHook"
        case share = "share"
    }
    
    @objc func close(_ arg: [String: String]?) {
        print("close")
    }
    
    @objc func loadCompleted(_ arg: Any?) {
        print("loadCompleted")
    }
    
    @objc func deviceInfo(_ arg: Any?, handler: BridgeWebView.BridgeCompletionHandler?) {
        print("deviceInfo")
        handler?(["sdasdas": "hahahah"], true)
    }
    
    @objc func mediaQuery(_ arg: Any?, handler: BridgeWebView.BridgeCompletionHandler?) {
        print("mediaQuery")
        handler?(["sdasdas": "hahahah"], true)
    }
    
    @objc func goBack(_ arg: Any?) {
        print("goBack")
    }
    
    @objc func setBackHook(_ arg: Any?, handler: BridgeWebView.BridgeCompletionHandler?) {
        print("setBackHook")
        handler?(["sdasdas": "hahahah"], true)
    }
    
    @objc func share(_ arg: Any?, handler: BridgeWebView.BridgeCompletionHandler?) {
        print("share")
    }
}

extension PaylaterJSBridge: BridgeWebViewProtocol {
    func checkMethodType(_ method: String) -> BridgeMethodTypes {
        guard let method = PaylaterJSBridgeMethods(rawValue: method) else {
            return .cantCall
        }
        switch method {
        case .close,
             .loadCompleted,
             .goBack:
            return .canCallSyn
        case .deviceInfo,
             .mediaQuery,
             .setBackHook,
             .share:
            return .canCallAsyn
        }
    }
    
    func handleMethod(_ method: String, arg: Any?, completionHandler: BridgeWebView.BridgeCompletionHandler?) -> Any? {
        guard let method = PaylaterJSBridgeMethods(rawValue: method) else {
            return nil
        }
        switch method {
        case .close:
            self.close(arg as? [String : String])
        case .loadCompleted:
            loadCompleted(arg as? [String: Any])
        case .deviceInfo:
            deviceInfo(arg as? [String: Any], handler: completionHandler)
        case .mediaQuery:
            mediaQuery(arg as? [String: Any], handler: completionHandler)
        case .goBack:
            goBack(arg as? [String: Any])
        case .setBackHook:
            setBackHook(arg as? [String: Any], handler: completionHandler)
        case .share:
            share(arg as? [String: Any], handler: completionHandler)
        }
        return nil
    }
}
