//
//  PaylaterJSBridge.swift
//  DSBridge
//
//  Created by boye on 2020/11/24.
//  Copyright © 2020 boye. All rights reserved.
//

import UIKit

class PaylaterJSBridge: NSObject {
    
    @objc func close(_ arg: [String: String]?) {
        print("close")
    }
    
    @objc func loadCompleted(_ arg: Any?) {
        print("loadCompleted")
    }
    
    @objc func deviceInfo(_ arg: Any?, handler: (Dictionary<String, Any>)->Void) {
        print("deviceInfo")
    }
    
    @objc func mediaQuery(_ arg: Any?, handler: (Dictionary<String, Any>)->Void) {
        print("mediaQuery")
    }
    
    @objc func goBack(_ arg: Any?) {
        print("goBack")
    }
    
    @objc func setBackHook(_ arg: Any?, handler: (Dictionary<String, Any>)->Void) {
        print("setBackHook")
    }
    
    @objc func share(_ arg: Any?, handler: (Any?, Error?) -> Void) {
        print("share")
    }

    deinit {
        print("deinit")
    }
}
