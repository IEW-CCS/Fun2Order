//
//  BrandDetailEventTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/8/20.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import Kingfisher
import WebKit

class BrandDetailEventTableViewController: UITableViewController {
    @IBOutlet weak var imageEvent: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    
    var eventData: DetailBrandEvent = DetailBrandEvent()
    var webContentHeight: CGFloat = 0.0
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadEventContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.title = "活動內容"
        self.navigationController?.title = "活動內容"
        self.tabBarController?.title = "活動內容"
    }

    func loadEventContent() {
        self.labelTitle.text = self.eventData.eventTitle
        if self.eventData.eventImageURL != nil {
            let url = URL(string: self.eventData.eventImageURL!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            if url == nil {
                print("downloadURL returns nil")
                return
            }
            
            self.imageEvent.kf.setImage(with: url)
        }
        
        if self.eventData.eventContentURL != nil {
            let url = URL(string: self.eventData.eventContentURL!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            
            if let url = url {
                let request = URLRequest(url: url)
                // init and load request in webview.
                self.webView = WKWebView(frame: self.view.frame)
                self.webView.navigationDelegate = self
                self.webView.load(request)
            }
        }

    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 2 {
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            if self.eventData.eventContentURL != nil {
                self.webView.frame = CGRect(x: 0, y: 0, width: cell.frame.size.width, height: self.webContentHeight)
                cell.contentView.addSubview(self.webView)
                cell.contentView.sendSubviewToBack(self.webView)
            }

            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 2 {
            return self.webContentHeight
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
}

extension BrandDetailEventTableViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Strat to load")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finish to load")
        self.webContentHeight = self.webView.scrollView.contentSize.height
        print("self.webContentHeight = \(self.webContentHeight)")
        //self.tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
        self.tableView.reloadData()
    }
}
