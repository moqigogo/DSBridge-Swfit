//
//  ViewController.swift
//  DSBridge
//
//  Created by boye on 2020/11/9.
//  Copyright © 2020 boye. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    private(set) var webView: BridgeWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
    }

    private func setupWebView () {
        view.backgroundColor = .white
        let configuration = WKWebViewConfiguration()
        webView = BridgeWebView(frame: .zero, configuration: configuration)
        #if DEBUG
            webView.setDebugMode(true)
        #endif
        webView.loadURL("https://app.apaylater.net/debug")
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = self
        webView.bridgeUIDelegate = self
        webView.customUserAgent = {
            var isEnd =  false
            var originalUA: String = "Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Mobile/15A372" + "; APaylateriOS"
            
            webView.evaluateJavaScript("navigator.userAgent") { (result:Any?, error:Error?) in
                if error != nil {
                    debugPrint("\(error!)")
                }else {
                    if let uaStr = result as? String {
                        originalUA = uaStr + "; APaylateriOS"
                    }
                }
                isEnd = true
            }
            while isEnd == false {
                RunLoop.current.run(mode: RunLoop.Mode.default, before: Date.distantFuture)
            }
            return originalUA
        }()

//        webView.scrollView.contentInsetAdjustmentBehavior = .never
        view.addSubview(webView)
        webView.frame = view.bounds
    }
}

extension ViewController: WKNavigationDelegate, WKUIDelegate {
    
}
