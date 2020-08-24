//
//  BrandStoryViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/8/20.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import WebKit

class BrandStoryViewController: UIViewController {
    var webView: WKWebView? = nil
    var brandBackgroundColor: UIColor!
    var brandTextTintColor: UIColor!
    var brandProfile: DetailBrandProfile = DetailBrandProfile()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("BrandStoryViewController viewDidLoad")
        
        //let url = "http://www.shangyulin.com.tw/about.php"
        //loadWebURL(url_string: url)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "品牌故事"
        self.navigationController?.title = "品牌故事"
        self.tabBarController?.title = "品牌故事"

        let url = self.brandProfile.brandStoryURL
        print("BrandStoryViewController brand story url = \(String(describing: url))")
        loadWebURL(url_string: url)
    }
    //override func viewWillAppear(_ animated: Bool) {
    //    navigationController?.navigationBar.backItem?.setHidesBackButton(true, animated: false)
    //}

    func loadWebURL(url_string: String?) {
        if url_string == nil {
            print("url_string is nil")
            return
        }
        
        let url = URL(string: url_string!)
        
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

extension BrandStoryViewController: WKNavigationDelegate {
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
