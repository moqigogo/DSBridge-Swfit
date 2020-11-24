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
    typealias BridgeCompletionHandler = (_ value: Any)->Void
    
    weak var bridgeUIDelegate: WKUIDelegate?
    
    private var javaScriptNamespaceInterfaces = [String: AnyObject]()
    private var handerMap = [AnyHashable: BridgeCompletionHandler]()
    private var callInfoList = [CallInfo]()
    private var dialogTextDic = [String: String]()
    private var txtName: UITextField?
    private var lastCallTime: TimeInterval = 0
    private var jsCache = ""
    private var isPending = false
    private var isDebug = false
    private var dialogType = 0
    private var callID = 0
    private var isJsDialogBlock = true
    private var alertHandler: (()->Void)?
    private var confirmHandler: ((Bool) -> Void)?
    private var promptHandler: ((String?) -> Void)?
    private var javascriptCloseWindowListener: (()->Void)?
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        let script = WKUserScript(source: "window._dswk=true;",
                                  injectionTime: .atDocumentStart,
                                  forMainFrameOnly: true)
        configuration.userContentController.addUserScript(script)
        super.init(frame: frame, configuration: configuration)
        super.uiDelegate = self
        let interalApis = InternalApis()
        interalApis.webView = self
        addJavascriptObject(interalApis, namespace: "_dsb")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadURL(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        let request = URLRequest(url: url)
        load(request)
    }
    
    func callHandler(methodName: String, arguments: [Any]? = nil, completionHandler: BridgeCompletionHandler? = nil) {
        let callInfo = CallInfo()
        callInfo.id = callID + 1
        callInfo.args = arguments ?? []
        callInfo.method = methodName
        if completionHandler != nil {
            handerMap[callInfo.id!] = completionHandler
        }
        if callInfoList.count > 0 {
            callInfoList.append(callInfo)
        } else {
            dispatchJavascriptCall(callInfo)
        }
    }
    
    func setJavascriptCloseWindowListener(_ callBack: (()->Void)?) {
        javascriptCloseWindowListener = callBack
    }
    
    func addJavascriptObject(_ object: Any?, namespace: String) {
        guard let object = object else {
            return
        }
        javaScriptNamespaceInterfaces[namespace] = object as AnyObject
    }
    
    func removeJavascriptObject(_ namespace: String) {
        javaScriptNamespaceInterfaces.removeValue(forKey: namespace)
    }
    
    func hasJavascriptMethod(_ handlerName: String, methodExistCallback: @escaping ((_ exist: Bool)->Void)) {
        callHandler(methodName: "_hasJavascriptMethod", arguments: [handlerName]) { (value) in
            methodExistCallback((value as? Bool) ?? false)
        }
    }
    
    func setDebugMode(_ isDebug: Bool) {
        self.isDebug = isDebug
    }
    
    func disableJavascriptDialogBlock(_ isDisable: Bool) {
        isJsDialogBlock = isDisable
    }
    
    func customJavascriptDialogLabelTitles(dict: [String: String]?) {
        if dict != nil {
            dialogTextDic = dict!
        }
    }
    
    func onMessage(_ msg: [String: Any]?, type: JSUtils.BridgeAPI) -> Any? {
        var ret: Any?
        switch type {
        case .hasNativeMethod:
            ret = hasNativeMethod(args: msg)
        case .closePage:
            ret = closePage(args: msg)
        case .returnValue:
            ret = returnValue(args: msg)
        case .dsinit:
            ret = dsinit(args: msg)
        case .disableSafetyAlertBox:
            ret = disableJavascriptDialogBlock((msg?["disable"] as? Bool) ?? false)
        }
        
        return ret
    }
}

extension BridgeWebView: WKUIDelegate {
    func webView(_ webView: WKWebView,
                 runJavaScriptTextInputPanelWithPrompt prompt: String,
                 defaultText: String?,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {
        
        let prefix = "_dsbridge="
        if prompt.hasPrefix(prefix) {
            let method = (prompt as NSString).substring(from: prefix.count)
            let result = call(method, argStr: defaultText)
            completionHandler(result)
        } else {
            if isJsDialogBlock == false {
                completionHandler(nil)
            }

            if let bridgeUIDelegate = bridgeUIDelegate,
                bridgeUIDelegate.responds(to: #selector(webView(_:runJavaScriptTextInputPanelWithPrompt:defaultText:initiatedByFrame:completionHandler:))) {
                
                bridgeUIDelegate.webView?(webView,
                                           runJavaScriptTextInputPanelWithPrompt: prompt,
                                           defaultText: defaultText,
                                           initiatedByFrame: frame,
                                           completionHandler: completionHandler)
                return
            } else {
                dialogType = 3
                if isJsDialogBlock {
                    promptHandler = completionHandler
                }
                // todo alert
                completionHandler(nil)
            }
        }
    }
    
    func webView(_ webView: WKWebView,
                 runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        if isJsDialogBlock == false {
            completionHandler()
        }
        
        if let bridgeUIDelegate = bridgeUIDelegate,
            bridgeUIDelegate.responds(to: #selector(webView(_:runJavaScriptAlertPanelWithMessage:initiatedByFrame:completionHandler:))) {
            
            bridgeUIDelegate.webView?(webView,
                                       runJavaScriptAlertPanelWithMessage: message,
                                       initiatedByFrame: frame,
                                       completionHandler: completionHandler)
            return
        } else {
            dialogType = 1
            if isJsDialogBlock {
                alertHandler = completionHandler
            }
            completionHandler()
        }
    }
    
    func webView(_ webView: WKWebView,
                 runJavaScriptConfirmPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
        if isJsDialogBlock == false {
            completionHandler(true)
        }
        if bridgeUIDelegate != nil {
            bridgeUIDelegate?.webView?(webView,
                                       runJavaScriptConfirmPanelWithMessage: message,
                                       initiatedByFrame: frame,
                                       completionHandler: completionHandler)
            return
        } else {
            dialogType = 2
            if isJsDialogBlock {
                confirmHandler = completionHandler
            }
            // todo alert
        }
    }
    
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        return bridgeUIDelegate?.webView?(webView,
                                          createWebViewWith: configuration,
                                          for: navigationAction,
                                          windowFeatures: windowFeatures)
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        bridgeUIDelegate?.webViewDidClose?(webView)
    }
}

extension BridgeWebView {
    private func evalJavascript(_ delay: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(delay)) {
            objc_sync_enter(self)
            if self.jsCache.count >= 0 {
                self.evaluateJavaScript(self.jsCache, completionHandler: nil)
                self.isPending = false
                self.jsCache = ""
                self.lastCallTime = Date().timeIntervalSince1970 * 100
            }
            objc_sync_exit(self)
        }
    }
    
    private func call(_ method: String, argStr: String?) -> String {
        var result = ["code": -1, "data": ""] as [String : Any]
        let nameStrings = JSUtils.parseNamespace(method.trimmingCharacters(in: .whitespaces))
        guard let nameString = nameStrings.first as? String,
            let JavascriptInterfaceObject = javaScriptNamespaceInterfaces[nameString],
            nameStrings.count > 1,
            let methodString = nameStrings[1] as? String else {
            
            debugPrint("Js bridge  called, but can't find a corresponded JavascriptObject , please check your code!")
            return JSUtils.objToJsonString(result)
        }
        
        let errorString = String(format: "Error! \n Method %@ is not invoked, since there is not a implementation for it", method)
        
        let methodOne = JSUtils.methodByName(argNum: 1, selName: methodString, clazz: JavascriptInterfaceObject.classForCoder!)
        let methodTwo = JSUtils.methodByName(argNum: 2, selName: methodString, clazz:  JavascriptInterfaceObject.classForCoder!)
        
        let sel = NSSelectorFromString(methodOne ?? "")
        let selasyn = NSSelectorFromString(methodTwo ?? "")
        
        guard let args = JSUtils.jsonStringToObject(argStr) else {
            return JSUtils.objToJsonString(result)
        }
        let arg = args["data"]
        
        let cb = args["_dscbstub"] as? String
        
        repeat {
            if cb != nil {
                if JavascriptInterfaceObject.responds(to: selasyn) {
                    let completionHandler: (Any?, Bool)->() = { value, complete in
                        var del = ""
                        result["code"] = 0
                        if value != nil {
                            result["data"] = value
                        }
                        var value1 = JSUtils.objToJsonString(result)
                        value1 = value1.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "{}"
                        if complete {
                            del = "delete window." + cb!
                        }
                        let js = String(format: "try {%@(JSON.parse(decodeURIComponent(\"%@\")).data);%@; } catch(e){};", cb!, ((value as? String) ?? ""), del)
                        objc_sync_enter(self)
                        
                        let t = Date().timeIntervalSince1970 * 1000
                        self.jsCache = self.jsCache + js
                        if t - self.lastCallTime < 50 {
                            if !self.isPending {
                                self.evalJavascript(50)
                                self.isPending = true
                            }
                        } else {
                            self.evalJavascript(0)
                        }
                        objc_sync_exit(self)
                    }
                    
                    // todo
                    _ = JavascriptInterfaceObject.perform(selasyn, with: arg, with: completionHandler)
                    break
                }
            } else if JavascriptInterfaceObject.responds(to: sel) {
                let ret = JavascriptInterfaceObject.perform(sel, with: arg)
                result["code"] = 0
                if ret != nil {
                    result["data"] = ret!.takeRetainedValue()
                }
                break
            }
            var js = errorString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            if isDebug {
                js = String(format: "window.alert(decodeURIComponent(\"%@\"));", js)
                evaluateJavaScript(js, completionHandler: nil)
            }
            debugPrint(errorString)
        } while false
        
        return JSUtils.objToJsonString(result)
    }
    
    private func dispatchStartupQueue() {
        if callInfoList.count <= 0 { return }
        for callInfo in callInfoList {
            dispatchJavascriptCall(callInfo)
        }
        callInfoList.removeAll()
    }
    
    private func dispatchJavascriptCall(_ info: CallInfo) {
        guard let method = info.method,
            let id = info.id else {
            return
        }
        let jsonDict = ["method": method, "callbackId": id, "data": JSUtils.objToJsonString(info.args as Any)] as [String : Any]
        let json = JSUtils.objToJsonString(jsonDict)
        
        evaluateJavaScript(String(format: "window._handleMessageFromNative(%@)", json), completionHandler: nil)
    }
    
    private func hasNativeMethod(args: [String: Any]?) -> Bool {
        guard let argsName = args?["name"] as? String,
            let argsType = args?["type"] as? String else {
            return false
        }
        let nameStrings = JSUtils.parseNamespace(argsName.trimmingCharacters(in: .whitespaces))
        let type = argsType.trimmingCharacters(in: .whitespaces)
        guard let nameString = nameStrings.first as? String,
            let JavascriptInterfaceObject = javaScriptNamespaceInterfaces[nameString] else {
            return false
        }
        
        if nameString.count <= 1 {
            return false
        }
        
        guard let nameString1 = nameStrings[1] as? String else {
            return false
        }
        
        let syn = JSUtils.methodByName(argNum: 1, selName: nameString1, clazz: JavascriptInterfaceObject.classForCoder!) != nil
        let asyn = JSUtils.methodByName(argNum: 2, selName: nameString1, clazz: JavascriptInterfaceObject.classForCoder!) != nil
        if ("all" == type && (syn || asyn))
            || ("asyn" == type && asyn)
            || ("syn" == type && syn) {
            return true
        }
        
        return false
    }
    
    private func closePage(args: [String: Any]?) -> Any? {
        javascriptCloseWindowListener?()
        return nil
    }
    
    private func returnValue(args: [String: Any]?) -> Any? {
        guard let argsID = args?["id"] as? AnyHashable,
            let completionHandler = handerMap[argsID] else {
            return nil
        }
        completionHandler(args?["data"] as Any)
        if let isComplete = args?["complete"] as? Bool,
            isComplete {
            handerMap.removeValue(forKey: argsID)
        }
        return nil
    }
    
    private func dsinit(args: [String: Any]?) -> Any? {
        dispatchStartupQueue()
        return nil
    }
}
