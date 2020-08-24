//
//  BrandEventTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/8/20.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import Kingfisher
import Firebase

class BrandEventTableViewController: UITableViewController {
    @IBOutlet weak var imageEventTitle: UIImageView!
    
    var brandBackgroundColor: UIColor!
    var brandTextTintColor: UIColor!
    var brandProfile: DetailBrandProfile = DetailBrandProfile()
    var eventList: [DetailBrandEvent] = [DetailBrandEvent]()
    //let url_string: String = "http://www.shangyulin.com.tw/images/index/pic_02.jpg"
    var url_string: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("BrandEventTableViewController viewDidLoad")
        
        let friendNib: UINib = UINib(nibName: "BrandEventCell", bundle: nil)
        self.tableView.register(friendNib, forCellReuseIdentifier: "BrandEventCell")
        //self.tableView.backgroundColor = TEST_BACKGROUND_COLOR
        self.tableView.backgroundColor = self.brandBackgroundColor
        
        if self.brandProfile.brandEventBannerURL != nil {
            self.url_string = self.brandProfile.brandEventBannerURL!
        }
        
        loadEventList()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.title = "活動訊息"
        self.navigationController?.title = "活動訊息"
        self.tabBarController?.title = "活動訊息"
    }

    func loadEventList() {
        let url = URL(string: self.url_string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        if url == nil {
            print("URL returns nil")
            return
        }
        
        self.imageEventTitle.kf.setImage(with: url)
        
        //testUploadBrandEvent()
        downloadFBBrandEventList(brand_name: "上宇林", completion: receiveEventList)
    }
    
    func receiveEventList(items: [DetailBrandEvent]?) {
        if items == nil {
            print("No events exist on the server, just return")
            return
        }
        
        self.eventList = items!.sorted(by: { $0.publishDate > $1.publishDate })
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        if section == 1 {
            if self.eventList.isEmpty {
                return 0
            } else {
                return self.eventList.count
            }
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BrandEventCell", for: indexPath) as! BrandEventCell
            //cell.backgroundColor = TEST_BACKGROUND_COLOR
            cell.backgroundColor = self.brandBackgroundColor
            cell.setData(event_data: self.eventList[indexPath.row])
            cell.tag = indexPath.row

            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        //cell.backgroundColor = TEST_BACKGROUND_COLOR
        cell.backgroundColor = self.brandBackgroundColor
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }

    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if indexPath.section == 1 {
            let newIndexPath = IndexPath(row: 0, section: indexPath.section)
            return super.tableView(tableView, indentationLevelForRowAt: newIndexPath)
        } else {
            return super.tableView(tableView, indentationLevelForRowAt: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 90
        }

        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            guard let eventDetailController = storyBoard.instantiateViewController(withIdentifier: "EVENT_DETAIL_VC") as? BrandDetailEventTableViewController else{
                assertionFailure("[AssertionFailure] StoryBoard: EVENT_DETAIL_VC can't find!! (BrandDetailEventTableViewController)")
                return
            }
            
            eventDetailController.eventData = self.eventList[indexPath.row]
            
            navigationController?.show(eventDetailController, sender: self)
        }
    }
}
