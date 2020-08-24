//
//  BrandProductDescriptionViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/8/20.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import WebKit

class BrandProductDescriptionViewController: UIViewController {
    var webView: WKWebView!
    var productURL: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        loadProductWebContent(url_string: self.productURL)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "產品描述"
        self.navigationController?.title = "產品描述"
        self.tabBarController?.title = "產品描述"
    }

    func loadProductWebContent(url_string: String) {
        let url = URL(string: url_string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        
        if let url = url {
            let request = URLRequest(url: url)
            // init and load request in webview.
            self.webView = WKWebView(frame: self.view.frame)
            if self.webView != nil {
                self.webView!.navigationDelegate = self
                print("self.webView is not nil")
                self.webView!.load(request)
                self.view.addSubview(self.webView!)
                self.view.sendSubviewToBack(self.webView!)
            }
        }
    }
}

extension BrandProductDescriptionViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Strat to load")
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finish to load")
    }
}
