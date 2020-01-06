//
//  CartOrderItemCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/12/6.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit
import CoreData

class CartOrderItemCell: UITableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var labelProductName: UILabel!
    @IBOutlet weak var imageProductImage: UIImageView!
    @IBOutlet weak var labelOwnerName: UILabel!
    @IBOutlet weak var imageOwnerImage: UIImageView!
    @IBOutlet weak var labelQuantity: UILabel!
    @IBOutlet weak var labelSinglePrice: UILabel!
    @IBOutlet weak var labelRecipe: UILabel!
    @IBOutlet weak var labelTotalPrice: UILabel!
    @IBOutlet weak var buttonEdit: UIButton!
    @IBOutlet weak var buttonDelete: UIButton!

    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!

    var productItem: OrderContentItem = OrderContentItem()
    var orderInformation: OrderInformation = OrderInformation()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backView.layer.borderWidth = CGFloat(1.0)
        self.backView.layer.borderColor = BASIC_FRAME_BORDER_COLOR_ORANGE.cgColor
        self.backView.layer.cornerRadius = 4
        
        self.buttonEdit.layer.cornerRadius = 4
        self.buttonDelete.layer.cornerRadius = 4
        
        vc = app.persistentContainer.viewContext
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    func setData(order_info: OrderInformation, index: Int) {
        self.orderInformation = order_info
        self.productItem = order_info.contentList[index]
        self.labelProductName.text = order_info.contentList[index].productName
        self.imageProductImage.image = retrieveProductImage(brand_id: order_info.brandID, product_id: order_info.contentList[index].productID)
        if order_info.orderType == ORDER_TYPE_SINGLE {
            self.labelOwnerName.isHidden = true
            self.imageOwnerImage.isHidden = true
        } else {
            self.labelOwnerName.isHidden = false
            self.imageOwnerImage.isHidden = false
            self.labelOwnerName.text = order_info.contentList[index].itemOwnerName
            self.imageOwnerImage.image = order_info.contentList[index].itemOwnerImage
        }
        self.labelQuantity.text = String(order_info.contentList[index].itemQuantity)
        self.labelSinglePrice.text = String(order_info.contentList[index].itemSinglePrice)
        self.labelTotalPrice.text = String(order_info.contentList[index].itemFinalPrice)
        self.labelRecipe.text = getRecipeString()
    }
    
    func retrieveProductImage(brand_id: Int, product_id: Int) -> UIImage {
        let fetchProduct: NSFetchRequest<PRODUCT_INFORMATION> = PRODUCT_INFORMATION.fetchRequest()
        let pString = "brandID == \(brand_id) AND productID == \(product_id)"
        print("retrieveProductImage pOrderpStringString = \(pString)")
        let predicate = NSPredicate(format: pString)
        fetchProduct.predicate = predicate

        do {
            let product_data = try vc.fetch(fetchProduct).first
            return UIImage(data: product_data!.productImage!)!
        } catch {
            print(error.localizedDescription)
            return UIImage()
        }
    }
    
    func getRecipeString() -> String {
        var recipeString: String = ""
        for i in 0...self.productItem.itemRecipe.count - 1 {
            recipeString = recipeString + self.productItem.itemRecipe[i].recipeSubCode
            if i != self.productItem.itemRecipe.count - 1 {
                recipeString = recipeString + " \\ "
            }
        }
        
        return recipeString
    }
    
    @IBAction func editOrderProductItem(_ sender: UIButton) {
        var tmpOrderInfo: OrderInformation = OrderInformation()

        tmpOrderInfo = self.orderInformation
        tmpOrderInfo.contentList.removeAll()
        tmpOrderInfo.contentList.append(self.productItem)

        //Send notofication to CartTableViewController
        NotificationCenter.default.post(name: NSNotification.Name("EditProductRecipe"), object: tmpOrderInfo)
    }
    
    @IBAction func deleteOrderProductItem(_ sender: UIButton) {
        let controller = UIAlertController(title: "刪除訂單產品", message: "確定要刪除此產品的訂單嗎？", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
            print("Confirm to delete this product")
            if deleteOrderProduct(brand_id: self.orderInformation.brandID, store_id: self.orderInformation.storeID, order_number: self.productItem.orderNumber, item_number: self.productItem.itemNumber) {
                print("Delete successful!")
                
                //Send notofication to CartTableViewController
                NotificationCenter.default.post(name: NSNotification.Name("EditDeleteOrderProduct"), object: nil)
            }
        }
        
        controller.addAction(okAction)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        app.window?.rootViewController!.present(controller, animated: true, completion: nil)
    }
}
