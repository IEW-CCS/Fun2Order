//
//  ProductDetailTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/16.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class ProductDetailTableViewController: UITableViewController {

    let productImages: [[UIImage]] =
        [[UIImage(named: "紅茶@3x.png")!,
            UIImage(named: "綠茶@3x.png")!,
            UIImage(named: "青茶@3x.png")!,
            UIImage(named: "百香愛玉@3x.png")!,
            UIImage(named: "金桔檸檬@3x.png")!,
            UIImage(named: "新鮮水果茶@3x.png")!,
            UIImage(named: "蜂蜜檸檬@3x.png")!,
            UIImage(named: "檸檬愛玉@3x.png")!,
            UIImage(named: "纖活綠茶@3x.png")!],
        [UIImage(named: "仙草凍奶茶@3x.png")!,
            UIImage(named: "奶茶@3x.png")!,
            UIImage(named: "珍珠奶茶@3x.png")!,
            UIImage(named: "珍珠鮮奶茶@3x.png")!,
            UIImage(named: "珍珠觀音拿鐵@3x.png")!,
            UIImage(named: "鮮奶冬瓜@3x.png")!,
            UIImage(named: "觀音拿鐵@3x.png")!]]

    let productTitles: [[String]] = [["紅茶", "綠茶", "青茶", "百香愛玉", "金桔檸檬", "新鮮水果茶", "蜂蜜檸檬" ,"檸檬愛玉", "纖活綠茶"],
                                  ["仙草凍奶茶", "奶茶", "珍珠奶茶", "珍珠鮮奶茶", "珍珠觀音拿鐵", "鮮奶冬瓜", "觀音拿鐵"]]
    let productSubTitles: [[String]] = [["紅茶_描述文字", "綠茶_描述文字", "青茶_描述文字", "百香愛玉_描述文字", "金桔檸檬_描述文字", "新鮮水果茶_描述文字", "蜂蜜檸檬_描述文字" ,"檸檬愛玉_描述文字", "纖活綠茶_描述文字"],
                                  ["仙草凍奶茶_描述文字", "奶茶_描述文字", "珍珠奶茶_描述文字", "珍珠鮮奶茶_描述文字", "珍珠觀音拿鐵_描述文字", "鮮奶冬瓜_描述文字", "觀音拿鐵_描述文字"]]
    let productPrice: [[String]] = [["25元", "25元", "30元", "50元", "50元", "70元", "60元", "60元", "50元"],
                                 ["75元", "60元", "70元", "70元", "75元", "70元", "75元"]]
    
    let productFavoriteFlag: [[Bool]] = [[false, false, true, false, false, false, false, true, false],
                                     [true, false, false, false, true, false, true]]

    var selectedCategory: Int = 0
    var detailProductFlag: Bool = true
    var menuImages: [UIImage] = [UIImage(imageLiteralResourceName: "ToolBar_ProductDetail"), UIImage(imageLiteralResourceName: "ToolBar_ProductBrief")]
    
    @IBOutlet weak var categorySegment: UISegmentedControl!
    @IBOutlet weak var productListBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let detailCellViewNib: UINib = UINib(nibName: "ProductDetailCell", bundle: nil)
        self.tableView.register(detailCellViewNib, forCellReuseIdentifier: "ProductDetailCell")
        
        let briefCellViewNib: UINib = UINib(nibName: "ProductBriefCell", bundle: nil)
        self.tableView.register(briefCellViewNib, forCellReuseIdentifier: "ProductBriefCell")
        
        let sectionViewNib: UINib = UINib(nibName: "CategorySectionView", bundle: nil)
        self.tableView.register(sectionViewNib, forHeaderFooterViewReuseIdentifier: "CategorySectionView")
    }

    @IBAction func changeProductListView(_ sender: UIBarButtonItem) {
        self.detailProductFlag = !self.detailProductFlag
        if self.detailProductFlag {
            self.productListBarButton.image = UIImage(imageLiteralResourceName: "ToolBar_ProductDetail")
            self.categorySegment.isHidden = false
            self.categorySegment.isEnabled = true
        } else {
            self.productListBarButton.image = UIImage(imageLiteralResourceName: "ToolBar_ProductBrief")
            self.categorySegment.isHidden = true
            self.categorySegment.isEnabled = false
        }
        
        self.tableView.reloadData()
    }
    
    @IBAction func displayCartView(_ sender: UIBarButtonItem) {
        print("Click displayCartView menu item")
    }
    
    @IBAction func selectCategory(_ sender: UISegmentedControl) {
        self.selectedCategory = self.categorySegment.selectedSegmentIndex
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.detailProductFlag {
            return 1
        } else {
            return 2
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.detailProductFlag {
            return self.productTitles[self.selectedCategory].count
        } else {
            return self.productTitles[section].count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.detailProductFlag {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductDetailCell", for: indexPath) as! ProductDetailCell

            cell.setData(favorite: self.productFavoriteFlag[self.selectedCategory][indexPath.row],
                         image: self.productImages[self.selectedCategory][indexPath.row],
                         title: self.productTitles[self.selectedCategory][indexPath.row],
                         sub_title: self.productSubTitles[self.selectedCategory][indexPath.row],
                         price: self.productPrice[self.selectedCategory][indexPath.row])
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductBriefCell", for: indexPath) as! ProductBriefCell
            cell.setData(favorite: self.productFavoriteFlag[indexPath.section][indexPath.row],
                         product_name: self.productTitles[indexPath.section][indexPath.row])
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.detailProductFlag {
            return 100
        } else {
            return 44
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if !self.detailProductFlag {
            let sectionView: CategorySectionView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CategorySectionView") as! CategorySectionView
            
            if section == 0 {
                sectionView.setData(catetory: "Tea")
            } else {
                sectionView.setData(catetory: "Milk Tea")
            }
            
            return sectionView
        } else {
            let sectionView = super.tableView(tableView, viewForHeaderInSection: section) as! CategorySectionView
            
            return sectionView
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.detailProductFlag {
            return 0
        } else {
            return 44
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "Recipe_VC") as? RecipeTableViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: pickerStoryboard can't find!! (ViewController)")
            return
        }
        show(vc, sender: self)
    }

}
