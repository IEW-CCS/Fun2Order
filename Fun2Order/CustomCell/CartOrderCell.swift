//
//  CartOrderCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/12/5.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit
import CoreData

class CartOrderCell: UITableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var basicInfoView: UIView!
    @IBOutlet weak var payBackView: UIView!
    @IBOutlet weak var productTableView: UITableView!
    
    @IBOutlet weak var labelBrandTitle: UILabel!
    @IBOutlet weak var imageBrandImage: UIImageView!
    @IBOutlet weak var labelTotalQuantity: UILabel!
    @IBOutlet weak var labelTotalPrice: UILabel!
    @IBOutlet weak var labelDeliveryWay: UILabel!
    @IBOutlet weak var labelAddress: UILabel!
    @IBOutlet weak var buttonTakeOut: UIButton!
    @IBOutlet weak var buttonDelivery: UIButton!
    
    var orderInformation: OrderInformation = OrderInformation()
    var serialNumberList: OrderSerialList!
    var favoriteAddr: [FavoriteAddress] = [FavoriteAddress]()

    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backView.layer.borderWidth = CGFloat(1.0)
        self.backView.layer.borderColor = BASIC_FRAME_BORDER_COLOR_GREEN.cgColor
        self.backView.layer.cornerRadius = 4

        self.basicInfoView.layer.borderWidth = CGFloat(1.0)
        self.basicInfoView.layer.borderColor = UIColor.lightGray.cgColor
        self.basicInfoView.layer.cornerRadius = 4

        self.buttonTakeOut.layer.borderWidth = 1.0
        self.buttonTakeOut.layer.borderColor = CUSTOM_COLOR_EMERALD_GREEN.cgColor
        self.buttonTakeOut.layer.cornerRadius = 4
        self.buttonTakeOut.setTitleColor(CUSTOM_COLOR_EMERALD_GREEN, for: .normal)
        self.buttonTakeOut.setTitleColor(.white, for: .selected)

        self.buttonDelivery.layer.borderWidth = 1.0
        self.buttonDelivery.layer.borderColor = CUSTOM_COLOR_EMERALD_GREEN.cgColor
        self.buttonDelivery.layer.cornerRadius = 4
        self.buttonDelivery.setTitleColor(CUSTOM_COLOR_EMERALD_GREEN, for: .normal)
        self.buttonDelivery.setTitleColor(.white, for: .selected)

        self.payBackView.layer.borderWidth = CGFloat(1.0)
        self.payBackView.layer.borderColor = UIColor.lightGray.cgColor
        self.payBackView.layer.cornerRadius = 4

        let nib = UINib(nibName: "CartOrderItemCell", bundle: nil)
        self.productTableView.register(nib, forCellReuseIdentifier: "CartOrderItemCell")
        self.productTableView.delegate = self
        self.productTableView.dataSource = self
        self.productTableView.layer.borderWidth = 0

        vc = app.persistentContainer.viewContext
        
        self.favoriteAddr = retrieveFavoriteAddress()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setData(order_info: OrderInformation) {
        self.orderInformation = order_info
        /*
         var totalQuantity: Int = 0
         var totalPrice: Int = 0
         
         for i in 0...order_info.contentList.count - 1 {
             totalQuantity = totalQuantity + order_info.contentList[i].itemQuantity
             totalPrice = totalPrice + order_info.contentList[i].itemFinalPrice
         }
         self.orderInformation.orderTotalPrice = totalPrice
         */

        self.labelBrandTitle.text = "\(self.orderInformation.brandName)  \(self.orderInformation.storeName)"
        self.imageBrandImage.image = retrieveBrandImage(brand_id: order_info.brandID)
        self.labelTotalQuantity.text = String(self.orderInformation.orderTotalQuantity)
        self.labelTotalPrice.text = String(self.orderInformation.orderTotalPrice)
        self.labelAddress.text = order_info.deliveryAddress
        if order_info.deliveryType == DELIVERY_TYPE_TAKEOUT {
            self.labelDeliveryWay.text = "自取"
            updateButtonState(takeout_flag: true)
        } else if order_info.deliveryType == DELIVERY_TYPE_DELIVERY {
            self.labelDeliveryWay.text = "外送地址"
            self.labelAddress.text = order_info.deliveryAddress
            updateButtonState(takeout_flag: false)
        } else {
            self.labelDeliveryWay.text = "自取"
            updateButtonState(takeout_flag: true)
        }
        
        self.productTableView.reloadData()
    }
    
    func retrieveBrandImage(brand_id: Int) -> UIImage {
        let fetchProduct: NSFetchRequest<BRAND_PROFILE> = BRAND_PROFILE.fetchRequest()
        let pString = "brandID == \(brand_id)"
        print("retrieveBrandImage pString = \(pString)")
        let predicate = NSPredicate(format: pString)
        fetchProduct.predicate = predicate

        do {
            let brand_data = try vc.fetch(fetchProduct).first
            return UIImage(data: brand_data!.brandIconImage!)!
        } catch {
            print(error.localizedDescription)
            return UIImage()
        }
    }

    /*
    func retrieveFavoriteAddress() {
        self.favoriteAddr.removeAll()
        
        let fetchAddress: NSFetchRequest<FAVORITE_ADDRESS> = FAVORITE_ADDRESS.fetchRequest()

        do {
            let address_list = try vc.fetch(fetchAddress)
            for address_data in address_list {
                var tmpAddress = FavoriteAddress()
                tmpAddress.createTime = address_data.createTime!
                tmpAddress.favoriteAddress = address_data.favoriteAddress!
                self.favoriteAddr.append(tmpAddress)
            }
        } catch {
            print(error.localizedDescription)
        }
    }*/
    
    @IBAction func takeOut(_ sender: UIButton) {
        self.labelDeliveryWay.text = "自取"
        self.labelAddress.isEnabled = false
        self.labelAddress.isHidden = true
        self.labelAddress.text = ""
        
        updateButtonState(takeout_flag: true)

        self.orderInformation.deliveryType = DELIVERY_TYPE_TAKEOUT
        self.orderInformation.deliveryAddress = ""
        self.updateOrderAddress()
    }
    
    @IBAction func deliveryByStore(_ sender: UIButton) {
        self.labelDeliveryWay.text = "外送地址"
        self.labelAddress.isEnabled = true
        self.labelAddress.isHidden = false
        self.orderInformation.deliveryType = DELIVERY_TYPE_DELIVERY

        updateButtonState(takeout_flag: false)
        self.favoriteAddr.removeAll()
        self.favoriteAddr = retrieveFavoriteAddress()
        
        if !self.favoriteAddr.isEmpty {
            let controller = UIAlertController(title: "請選擇外送地址", message: nil, preferredStyle: .alert)
            controller.view.tintColor = CUSTOM_COLOR_EMERALD_GREEN
            for addr_data in self.favoriteAddr {
                let action = UIAlertAction(title: addr_data.favoriteAddress, style: .default) { (action) in
                    print("title = \(action.title!)")
                    self.labelAddress.text = action.title!
                    self.orderInformation.deliveryAddress = action.title!
                    self.updateOrderAddress()
               }
               controller.addAction(action)
            }
            
            controller.addTextField { (textField) in
                textField.placeholder = "新增地址"
            }
            
            let cancelAction = UIAlertAction(title: "取消", style: .default) { (_) in
                print("Cancel to select favorite address!")
            }
            cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
            controller.addAction(cancelAction)
            
            let addAction = UIAlertAction(title: "加入我的最愛地址", style: .default) { (_) in
                print("Add to favorite address!")
                let address_string = controller.textFields?[0].text
                print("New added favorite address = \(address_string!)")
                insertFavoriteAddress(favorite_address: address_string!)
                self.labelAddress.text = address_string!
                self.orderInformation.deliveryAddress = address_string!
                self.updateOrderAddress()
            }
            addAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
            controller.addAction(addAction)
            
            app.window?.rootViewController!.present(controller, animated: true, completion: nil)
            return
        }
        
        let textController = UIAlertController(title: "新增 我的最愛地址", message: nil, preferredStyle: .alert)
            textController.addTextField { (textField) in
                textField.placeholder = "新增地址"
        }
        
        let addAction = UIAlertAction(title: "加入我的最愛地址", style: .default) { (_) in
            print("Add to favorite address!")
            let address_string = textController.textFields?[0].text
            print("New added favorite address = \(address_string!)")
            insertFavoriteAddress(favorite_address: address_string!)
            self.labelAddress.text = address_string!
            self.orderInformation.deliveryAddress = address_string!
            self.updateOrderAddress()
        }
        textController.addAction(addAction)
        app.window?.rootViewController!.present(textController, animated: true, completion: nil)
    }
    
    func updateButtonState(takeout_flag: Bool) {
        if takeout_flag {
            self.buttonTakeOut.backgroundColor = CUSTOM_COLOR_EMERALD_GREEN
            self.buttonTakeOut.isSelected = true
            self.buttonDelivery.backgroundColor = .white
            self.buttonDelivery.isSelected = false
        } else {
            self.buttonTakeOut.backgroundColor = .white
            self.buttonTakeOut.isSelected = false
            self.buttonDelivery.backgroundColor = CUSTOM_COLOR_EMERALD_GREEN
            self.buttonDelivery.isSelected = true
        }
    }
    
    func updateOrderAddress() {
        let fetchOrder: NSFetchRequest<ORDER_INFORMATION> = ORDER_INFORMATION.fetchRequest()
        let pString = "orderNumber == \"\(self.orderInformation.orderNumber)\""
        print("updateOrderAddress pString = \(pString)")
        let predicate = NSPredicate(format: pString)
        fetchOrder.predicate = predicate

        do {
            let order_data = try vc.fetch(fetchOrder).first
            order_data?.setValue(self.orderInformation.deliveryType, forKey: "deliveryType")
            order_data?.setValue(self.orderInformation.deliveryAddress, forKey: "deliveryAddress")
            app.saveContext()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func requestOrderSerialNumber() {
        let sessionConf = URLSessionConfiguration.default
        sessionConf.timeoutIntervalForRequest = HTTP_REQUEST_TIMEOUT
        sessionConf.timeoutIntervalForResource = HTTP_REQUEST_TIMEOUT
        let sessionHttp = URLSession(configuration: sessionConf)

        let temp = getFirebaseUrlForRequest(uri: "ORDER_SERIAL")
        let urlString = temp.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlRequest = URLRequest(url: URL(string: urlString)!)

        print("requestOrderSerialNumber")
        let task = sessionHttp.dataTask(with: urlRequest) {(data, response, error) in
            do {
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    guard let httpResponse = response as? HTTPURLResponse,
                        (200...299).contains(httpResponse.statusCode) else {
                            let errorResponse = response as? HTTPURLResponse
                            let message: String = String(errorResponse!.statusCode) + " - " + HTTPURLResponse.localizedString(forStatusCode: errorResponse!.statusCode)
                            print("Http Error: \(message)")
                            return
                    }

                    let outputStr  = String(data: data!, encoding: String.Encoding.utf8) as String?
                    let jsonData = outputStr!.data(using: String.Encoding.utf8, allowLossyConversion: true)
                    let decoder = JSONDecoder()
                    self.serialNumberList = try decoder.decode(OrderSerialList.self, from: jsonData!)

                    if self.serialNumberList.ORDER_SERIAL.count > 0 {
                        self.updateOrderInformationToCoreData()
                    }
                }
            } catch {
                print(error.localizedDescription)
                return
            }
        }
        task.resume()
        
        return
    }
    
    func updateOrderInformationToCoreData() {
        var todayCode: String = ""
        var serial_number: Int = 0
        var isFoundSerial: Bool = false
        
        let timeZone = TimeZone.init(identifier: "UTC")
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.locale = Locale.init(identifier: "zh_TW")
        formatter.dateFormat = DATETIME_FORMATTER
          
        let date = formatter.string(from: Date())
        let start = date.index(date.startIndex, offsetBy: 2)
        let end = date.index(date.startIndex, offsetBy: 7)
        let range = start...end
        todayCode = String(date[range])
        
        for i in 0...self.serialNumberList.ORDER_SERIAL.count - 1 {
            if self.serialNumberList.ORDER_SERIAL[i].orderType == self.orderInformation.orderType &&
                self.serialNumberList.ORDER_SERIAL[i].brandID == self.orderInformation.brandID &&
                self.serialNumberList.ORDER_SERIAL[i].storeID == self.orderInformation.storeID &&
                self.serialNumberList.ORDER_SERIAL[i].dayCode == todayCode {
                serial_number = self.serialNumberList.ORDER_SERIAL[i].serialNumber
                isFoundSerial = true
                break
            }
        }
        
        if !isFoundSerial {
            print("Serial number not found for Brand[\(self.orderInformation.brandID)] and Store[\(self.orderInformation.storeID)]")
            return
        }
        
        let newOrderNumber = generateOrderNumber(type: self.orderInformation.orderType, day_code: todayCode, brand_id: self.orderInformation.brandID, store_id: self.orderInformation.storeID, serial: serial_number)
       
        let oldOrderNumber = self.orderInformation.orderNumber
        
        let fetchOrder: NSFetchRequest<ORDER_INFORMATION> = ORDER_INFORMATION.fetchRequest()
        let pOrderString = "orderNumber == \"\(oldOrderNumber)\" AND orderStatus == \"\(ORDER_STATUS_INIT)\""
        print("updateOrderInformationToCoreData pOrderString = \(pOrderString)")
        let predicate1 = NSPredicate(format: pOrderString)
        fetchOrder.predicate = predicate1
        do {
            let order_data = try vc.fetch(fetchOrder).first
            order_data?.setValue(newOrderNumber, forKey: "orderNumber")
            order_data?.setValue(ORDER_STATUS_CREATE, forKey: "orderStatus")
            
            //app.saveContext()
        } catch {
            print(error.localizedDescription)
            return
        }
        
        let fetchProductItem: NSFetchRequest<ORDER_CONTENT_ITEM> = ORDER_CONTENT_ITEM.fetchRequest()
        let pProductString = "orderNumber == \"\(oldOrderNumber)\""
        print("updateOrderInformationToCoreData pProductString = \(pProductString)")
        let predicate2 = NSPredicate(format: pProductString)
        fetchProductItem.predicate = predicate2
        do {
            let product_list = try vc.fetch(fetchProductItem)
            for product_data in product_list {
                product_data.setValue(newOrderNumber, forKey: "orderNumber")
            }
            
            //app.saveContext()
        } catch {
            print(error.localizedDescription)
            return
        }
        
        let fetchRecipeItem: NSFetchRequest<ORDER_PRODUCT_RECIPE> = ORDER_PRODUCT_RECIPE.fetchRequest()
        let pRecipeString = "orderNumber == \"\(oldOrderNumber)\""
        print("updateOrderInformationToCoreData pRecipeString = \(pRecipeString)")
        let predicate3 = NSPredicate(format: pRecipeString)
        fetchRecipeItem.predicate = predicate3
        do {
            let recipe_list = try vc.fetch(fetchRecipeItem)
            for recipe_data in recipe_list {
                recipe_data.setValue(newOrderNumber, forKey: "orderNumber")
            }
            
            //app.saveContext()
        } catch {
            print(error.localizedDescription)
            return
        }
        
        app.saveContext()
        
        let messageString: String = "訂單已成功送出"
        let alertMessage = UIAlertController(title: messageString, message: nil, preferredStyle: .alert)
        DispatchQueue.main.async {
            self.app.window?.rootViewController!.present(alertMessage, animated: true, completion: nil)
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            self.app.window?.rootViewController!.dismiss(animated: true, completion: nil)
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("EditDeleteOrderProduct"), object: nil)
    }
    
    @IBAction func sendOrder(_ sender: UIButton) {
        requestOrderSerialNumber()
    }
    
    @IBAction func payByApple(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name("PayByApplePay"), object: nil)
    }
    
    @IBAction func payByGoogle(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name("PayByGooglePay"), object: nil)
    }
    
    @IBAction func payByLine(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name("PayByLinePay"), object: nil)
    }
    
    @IBAction func payByCash(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name("PayByCash"), object: nil)
    }
    
}

extension CartOrderCell: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberofSections section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.orderInformation.contentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartOrderItemCell", for: indexPath) as! CartOrderItemCell
        //cell.setData(order_type: self.orderInformation.orderType, brand_id: self.orderInformation.brandID, prod_item: self.orderInformation.contentList[indexPath.row])
        cell.setData(order_info: self.orderInformation, index: indexPath.row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
}
