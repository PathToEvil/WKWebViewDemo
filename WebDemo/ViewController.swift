//
//  ViewController.swift
//  WebDemo
//
//  Created by rayootech on 16/8/30.
//  Copyright © 2016年 demon. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate {

    private var wkWebView: WKWebView?
    
    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configWebView()
        configNav()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - WKScriptMessageHandler
    //收到web消息回调
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        print("app收到信息：\(message.body)")
    }
    
    //MARK: - WKNavigationDelegate
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        navigationItem.title = webView.title
    }
    
    //MARK: - WKUIDelegate
    /*
     js调用alert、confirm和prompt这三种弹窗时，不会弹窗，而是会触发下面对应的代理方法，可以由app做出对应的弹窗
     */
    //对应web界面警告框(alert)
    func webView(webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: () -> Void) {
        let alertView = UIAlertController(title: "alert", message: message, preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "确定", style: .Cancel, handler: { (action) in
            completionHandler()
        }))
        presentViewController(alertView, animated: true, completion: nil)
    }
    
    //对应web界面确认框(confirm)
    func webView(webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: (Bool) -> Void) {
        let alertView = UIAlertController(title: "confirm", message: message, preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "确定", style: .Default, handler: { (action) in
            completionHandler(true)
        }))
        alertView.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: { (action) in
            completionHandler(false)
        }))
        presentViewController(alertView, animated: true, completion: nil)
    }
    
    //对应web界面输入框(prompt）
    func webView(webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: (String?) -> Void) {
        let alertView = UIAlertController(title: "alert", message: defaultText, preferredStyle: .Alert)
        alertView.addTextFieldWithConfigurationHandler { (textField) in
            textField.textColor = UIColor.redColor()
        }
        alertView.addAction(UIAlertAction(title: "确定", style: .Cancel, handler: { (action) in
            completionHandler(alertView.textFields?.last?.text)
        }))
        presentViewController(alertView, animated: true, completion: nil)
    }
    
    //MARK: - event
    //右侧导航栏按钮触发的方法
    @objc func rightBarButtonItemAction() {
        //调用js方法
        wkWebView?.evaluateJavaScript("appMethod(\"app调用web方法\")", completionHandler: { (obj, error) in
            print("app调用web回调:\(obj)")
        })
    }
    
    //MARK: - private method
    //配置wkwebview
    private func configWebView() {
        let configuration = WKWebViewConfiguration()
        let userController = WKUserContentController()
        //注入js
        let jsString = "alert(\"shiihqohqdhowdoq\")"
        let js = WKUserScript(source: jsString, injectionTime: .AtDocumentStart, forMainFrameOnly: true)
        userController.addUserScript(js)
        
        //添加messageHandler用于接受h5消息
        userController.addScriptMessageHandler(self, name: "iOS")
        configuration.userContentController = userController
        
        //创建wkwebview
        wkWebView = WKWebView(frame: view.bounds, configuration: configuration)
        wkWebView?.navigationDelegate = self
        wkWebView?.UIDelegate = self
        
        //加载本地html
        let path = NSBundle.mainBundle().pathForResource("LocalHTML", ofType: "html")
        let htmlStr = try! String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
        wkWebView?.loadHTMLString(htmlStr, baseURL: nil)
        view.addSubview(wkWebView!)
    }
    //配置导航栏
    private func configNav() {
        //设置导航栏右侧item
        let rightbarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(rightBarButtonItemAction))
        navigationItem.rightBarButtonItem = rightbarButtonItem
    }
}

