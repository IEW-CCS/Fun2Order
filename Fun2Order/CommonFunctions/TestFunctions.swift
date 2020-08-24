//
//  TestFunctions.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/4/30.
//  Copyright © 2020 JStudio. All rights reserved.
//

import Foundation
import Firebase

func testResetCreateMenuToolTip() {
    let path = NSHomeDirectory() + "/Documents/GuideToolTip.plist"

    if let writePlist = NSMutableDictionary(contentsOfFile: path) {
        writePlist["showedCreateMenuToolTip"] = false
        if writePlist.write(toFile: path, atomically: true) {
            print("Write showedCreateMenuToolTip to GuideToolTip.plist successfule.")
        } else {
            print("Write showedCreateMenuToolTip to GuideToolTip.plist failed.")
        }
    }
}


func testResetMyProfileToolTip() {
    let path = NSHomeDirectory() + "/Documents/GuideToolTip.plist"

    if let writePlist = NSMutableDictionary(contentsOfFile: path) {
        writePlist["showedMyProfileToolTip"] = false
        if writePlist.write(toFile: path, atomically: true) {
            print("Write showedMyProfileToolTip to GuideToolTip.plist successfule.")
        } else {
            print("Write showedMyProfileToolTip to GuideToolTip.plist failed.")
        }
    }
}

func testResetMyFriendToolTip() {
    let path = NSHomeDirectory() + "/Documents/GuideToolTip.plist"

    if let writePlist = NSMutableDictionary(contentsOfFile: path) {
        writePlist["showedMyFriendToolTip"] = false
        if writePlist.write(toFile: path, atomically: true) {
            print("Write showedMyFriendToolTip to GuideToolTip.plist successfule.")
        } else {
            print("Write showedMyFriendToolTip to GuideToolTip.plist failed.")
        }
    }
}


func testResetMyGroupToolTip() {
    let path = NSHomeDirectory() + "/Documents/GuideToolTip.plist"

    if let writePlist = NSMutableDictionary(contentsOfFile: path) {
        writePlist["showedMyGroupToolTip"] = false
        if writePlist.write(toFile: path, atomically: true) {
            print("Write showedMyGroupToolTip to GuideToolTip.plist successfule.")
        } else {
            print("Write showedMyGroupToolTip to GuideToolTip.plist failed.")
        }
    }
}

func testResetGroupOrderToolTip() {
    let path = NSHomeDirectory() + "/Documents/GuideToolTip.plist"

    if let writePlist = NSMutableDictionary(contentsOfFile: path) {
        writePlist["showedGroupOrderToolTip"] = false
        if writePlist.write(toFile: path, atomically: true) {
            print("Write showedGroupOrderToolTip to GuideToolTip.plist successfule.")
        } else {
            print("Write showedGroupOrderToolTip to GuideToolTip.plist failed.")
        }
    }
}

func testFirebaseJSONUpload() {
    var tmpData: TestStruct = TestStruct()
    
    let databaseRef = Database.database().reference()
    let pathString = "USER_TEST"
    
    tmpData.messageID = "TTTTTTT"
    
    databaseRef.child(pathString).childByAutoId().setValue(tmpData.toAnyObject())
    print("tmpData.toAnyObject = \(tmpData.toAnyObject())")
}

func testFirebaseJSONDownload() {
    let databaseRef = Database.database().reference()
    let pathString = "USER_TEST"

    databaseRef.child(pathString).observeSingleEvent(of: .value, with: { (snapshot) in
        if snapshot.exists() {
            let itemRawData = snapshot.value
            let jsonData = try? JSONSerialization.data(withJSONObject: itemRawData as Any, options: [])

            let decoder: JSONDecoder = JSONDecoder()
            do {
                let itemArray = try decoder.decode(TestStruct.self, from: jsonData!)
                print("itemArray = \(itemArray)")
                print("itemArray.locations.isEmpty = \(String(describing: itemArray.locations?.isEmpty))")
                
                if itemArray.locations != nil {
                    print("locations nil")
                }
            } catch {
                print("testFirebaseJSONDownload jsonData decode failed: \(error.localizedDescription)")
            }
        } else {
            print("testFirebaseJSONDownload snapshot doesn't exist!")
            return
        }
    }) { (error) in
        print(error.localizedDescription)
    }
    
}

func testUploadBrandCategory(brand_name: String) {
    var brandCategory: DetailBrandCategory = DetailBrandCategory()
    brandCategory.brandName = brand_name
    brandCategory.brandIconImage = "Brand_Image/\(brand_name).png"
    brandCategory.brandCategory = "茶飲類"
    brandCategory.brandSubCategory = ""
    brandCategory.updateDateTime = "20200627121900000"
    
    let databaseRef = Database.database().reference()
    let pathString = "BRAND_CATEGORY/\(brandCategory.brandName)"
    
    databaseRef.child(pathString).setValue(brandCategory.toAnyObject())
}

func testUploadBrandEvent() {
    var eventData = DetailBrandEvent()

    let databaseRef = Database.database().reference()
    let pathString: String = "DETAIL_BRAND_EVENT/上宇林"
    var childString: String = ""

    eventData.eventTitle = "GOGORO3得獎公告"
    eventData.eventSubTitle = "上宇林GOGORO3抽獎活動已於10/20日完成抽獎"
    eventData.eventType = ""
    eventData.eventImageURL = " http://www.shangyulin.com.tw/upload/images/恭喜得獎.jpg"
    eventData.eventContentURL = "http://www.shangyulin.com.tw/news_detail.php?item=56"
    eventData.publishDate = "2019-10-25"
    childString = pathString + "/\(eventData.publishDate)"
    databaseRef.child(childString).setValue(eventData.toAnyObject())

    eventData.eventTitle = "來店購、集點抽GOGORO活動倒數"
    eventData.eventSubTitle = "喝喝上宇林、試試好手氣"
    eventData.eventType = ""
    eventData.eventImageURL = "http://www.shangyulin.com.tw/upload/images/gogoro倒數.jpg"
    eventData.eventContentURL = "http://www.shangyulin.com.tw/news_detail.php?item=55"
    eventData.publishDate = "2019-10-02"
    childString = pathString + "/\(eventData.publishDate)"
    databaseRef.child(childString).setValue(eventData.toAnyObject())

    eventData.eventTitle = "上宇林台中南屯黎明店試營運"
    eventData.eventSubTitle = "台中南屯黎明店在今天7/14(日)試營運啦"
    eventData.eventType = ""
    eventData.eventImageURL = "http://www.shangyulin.com.tw/upload/images/台中南屯黎明店_FB(S).jpg"
    eventData.eventContentURL = "http://www.shangyulin.com.tw/news_detail.php?item=54"
    eventData.publishDate = "2019-07-14"
    childString = pathString + "/\(eventData.publishDate)"
    databaseRef.child(childString).setValue(eventData.toAnyObject())

    eventData.eventTitle = "上宇林台中豐原中正店試營運"
    eventData.eventSubTitle = "上宇林台中豐原中正店即日起試營運啦"
    eventData.eventType = ""
    eventData.eventImageURL = "http://www.shangyulin.com.tw/upload/images/大明星小店長%20(2)_S.jpg"
    eventData.eventContentURL = "http://www.shangyulin.com.tw/news_detail.php?item=53"
    eventData.publishDate = "2019-07-13"
    childString = pathString + "/\(eventData.publishDate)"
    databaseRef.child(childString).setValue(eventData.toAnyObject())
}

func testUploadBrandStore() {
/*
     var storeID: Int = 0
     var storeName: String = ""
     var storeMenuNumber: String = ""
     var storeCategory: String?
     var storeSubCategory: String?
     var storeDescription: String?
     var storeLongitude: String?
     var storeLatitude: String?
     var storeWebURL: String?
     var storeFacebookURL: String?
     var storeInstagramURL: String?
     var storeAddress: String?
     var storePhoneNumber: String?
     var deliveryServiceFlag: Bool = false
     var deliveryService: [DeliveryService]?
*/
    var storeData = DetailStoreInformation()

    let databaseRef = Database.database().reference()
    let pathString: String = "DETAIL_BRAND_STORE/上宇林"
    var childString: String = ""

    storeData.storeID = 1
    storeData.storeName = "上宇林-台南東區青年店"
    storeData.storeMenuNumber = ""
    storeData.storeImageURL = "http://www.shangyulin.com.tw/upload/images/東區青年-門市據點1.jpg"
    storeData.storeAddress = "台南市東區青年路267號"
    storeData.storePhoneNumber = "06-208-8132"
    childString = pathString + "/\(storeData.storeName)"
    databaseRef.child(childString).setValue(storeData.toAnyObject())

    storeData.storeID = 2
    storeData.storeName = "上宇林-台南海安店"
    storeData.storeMenuNumber = ""
    storeData.storeImageURL = "http://www.shangyulin.com.tw/upload/images/中西海安-門市據點.jpg"
    storeData.storeAddress = "台南市中西區海安路一段87號"
    storeData.storePhoneNumber = "06-223-1986"
    childString = pathString + "/\(storeData.storeName)"
    databaseRef.child(childString).setValue(storeData.toAnyObject())

    storeData.storeID = 3
    storeData.storeName = "上宇林-台南永康東橋店"
    storeData.storeMenuNumber = ""
    storeData.storeImageURL = "http://www.shangyulin.com.tw/upload/images/shop-s06.jpg"
    storeData.storeAddress = "台南市永康區大強二街82號"
    storeData.storePhoneNumber = "06-302-3509"
    childString = pathString + "/\(storeData.storeName)"
    databaseRef.child(childString).setValue(storeData.toAnyObject())

    storeData.storeID = 4
    storeData.storeName = "上宇林-台南大同店"
    storeData.storeMenuNumber = ""
    storeData.storeImageURL = "http://www.shangyulin.com.tw/upload/images/南區大同-門市據點1.jpg"
    storeData.storeAddress = "台南市南區大同路2段496號"
    storeData.storePhoneNumber = "06-215-5223"
    childString = pathString + "/\(storeData.storeName)"
    databaseRef.child(childString).setValue(storeData.toAnyObject())

    storeData.storeID = 5
    storeData.storeName = "上宇林-台南新市二店"
    storeData.storeMenuNumber = ""
    storeData.storeImageURL = "http://www.shangyulin.com.tw/upload/images/shop-s02.jpg"
    storeData.storeAddress = "台南市新市區信義街23-2號"
    storeData.storePhoneNumber = "06-589-5077"
    childString = pathString + "/\(storeData.storeName)"
    databaseRef.child(childString).setValue(storeData.toAnyObject())

    storeData.storeID = 6
    storeData.storeName = "上宇林-台南新市總店"
    storeData.storeMenuNumber = ""
    storeData.storeImageURL = "http://www.shangyulin.com.tw/upload/images/shop-s01.jpg"
    storeData.storeAddress = "台南市新市區仁愛街215號"
    storeData.storePhoneNumber = "06-589-8171"
    childString = pathString + "/\(storeData.storeName)"
    databaseRef.child(childString).setValue(storeData.toAnyObject())

    storeData.storeID = 7
    storeData.storeName = "上宇林-台南善化店"
    storeData.storeMenuNumber = ""
    storeData.storeImageURL = "http://www.shangyulin.com.tw/upload/images/shop-s03.jpg"
    storeData.storeAddress = "台南市善化區大成路391號"
    storeData.storePhoneNumber = "06-583-9778"
    childString = pathString + "/\(storeData.storeName)"
    databaseRef.child(childString).setValue(storeData.toAnyObject())
    
}

func testFunction1() {
    var item = RecipeItem()
    var category = MenuRecipe()
    var template = MenuRecipeTemplate()
    template.templateName = "飲料類範本一"
    
    category.recipeCategory = "容量"
    category.sequenceNumber = 1
    category.allowedMultiFlag = false
    item.recipeName = "小杯"
    item.sequenceNumber = 1
    category.recipeItems?.append(item)
    item.recipeName = "中杯"
    item.sequenceNumber = 2
    category.recipeItems?.append(item)
    item.recipeName = "大杯"
    item.sequenceNumber = 3
    category.recipeItems?.append(item)
    item.recipeName = "瓶裝"
    item.sequenceNumber = 4
    category.recipeItems?.append(item)
    template.menuRecipes.append(category)

    category.recipeItems?.removeAll()
    category.recipeCategory = "冷飲溫度"
    category.sequenceNumber = 2
    category.allowedMultiFlag = false
    item.recipeName = "完全去冰"
    item.sequenceNumber = 1
    category.recipeItems?.append(item)
    item.recipeName = "去冰"
    item.sequenceNumber = 2
    category.recipeItems?.append(item)
    item.recipeName = "微冰"
    item.sequenceNumber = 3
    category.recipeItems?.append(item)
    item.recipeName = "少冰"
    item.sequenceNumber = 4
    category.recipeItems?.append(item)
    item.recipeName = "正常冰"
    item.sequenceNumber = 5
    category.recipeItems?.append(item)
    template.menuRecipes.append(category)

    category.recipeItems?.removeAll()
    category.recipeCategory = "熱飲溫度"
    category.sequenceNumber = 3
    category.allowedMultiFlag = false
    item.recipeName = "常溫"
    item.sequenceNumber = 1
    category.recipeItems?.append(item)
    item.recipeName = "微溫"
    item.sequenceNumber = 2
    category.recipeItems?.append(item)
    item.recipeName = "熱飲"
    item.sequenceNumber = 3
    category.recipeItems?.append(item)
    template.menuRecipes.append(category)
    
    category.recipeItems?.removeAll()
    category.recipeCategory = "甜度一"
    category.sequenceNumber = 4
    category.allowedMultiFlag = false
    item.recipeName = "無糖"
    item.sequenceNumber = 1
    category.recipeItems?.append(item)
    item.recipeName = "微糖"
    item.sequenceNumber = 2
    category.recipeItems?.append(item)
    item.recipeName = "半糖"
    item.sequenceNumber = 3
    category.recipeItems?.append(item)
    item.recipeName = "少糖"
    item.sequenceNumber = 4
    category.recipeItems?.append(item)
    item.recipeName = "全糖"
    item.sequenceNumber = 5
    category.recipeItems?.append(item)
    template.menuRecipes.append(category)

    category.recipeItems?.removeAll()
    category.recipeCategory = "甜度二"
    category.sequenceNumber = 5
    category.allowedMultiFlag = false
    item.recipeName = "一分糖"
    item.sequenceNumber = 1
    category.recipeItems?.append(item)
    item.recipeName = "二分糖"
    item.sequenceNumber = 2
    category.recipeItems?.append(item)
    item.recipeName = "三分糖"
    item.sequenceNumber = 3
    category.recipeItems?.append(item)
    item.recipeName = "四分糖"
    item.sequenceNumber = 4
    category.recipeItems?.append(item)
    item.recipeName = "五分糖"
    item.sequenceNumber = 5
    category.recipeItems?.append(item)
    item.recipeName = "六分糖"
    item.sequenceNumber = 6
    category.recipeItems?.append(item)
    item.recipeName = "七分糖"
    item.sequenceNumber = 7
    category.recipeItems?.append(item)
    item.recipeName = "八分糖"
    item.sequenceNumber = 8
    category.recipeItems?.append(item)
    item.recipeName = "九分糖"
    item.sequenceNumber = 9
    category.recipeItems?.append(item)
    item.recipeName = "十分糖"
    item.sequenceNumber = 10
    category.recipeItems?.append(item)
    template.menuRecipes.append(category)

    category.recipeItems?.removeAll()
    category.recipeCategory = "配料"
    category.sequenceNumber = 6
    category.allowedMultiFlag = true
    item.recipeName = "波霸"
    item.sequenceNumber = 1
    category.recipeItems?.append(item)
    item.recipeName = "珍珠"
    item.sequenceNumber = 2
    category.recipeItems?.append(item)
    item.recipeName = "仙草凍"
    item.sequenceNumber = 3
    category.recipeItems?.append(item)
    template.menuRecipes.append(category)

    let databaseRef = Database.database().reference()
    let pathString = "MENU_RECIPE_TEMPLATE/\(template.templateName)"
    
    databaseRef.child(pathString).setValue(template.toAnyObject())

}

func testFunction2() {
    var item = RecipeItem()
    var category = MenuRecipe()
    var template = MenuRecipeTemplate()
    template.templateName = "飲料類範本二"
    
    category.recipeCategory = "容量"
    category.sequenceNumber = 1
    category.allowedMultiFlag = false
    item.recipeName = "中杯"
    item.sequenceNumber = 1
    category.recipeItems?.append(item)
    item.recipeName = "大杯"
    item.sequenceNumber = 2
    category.recipeItems?.append(item)
    template.menuRecipes.append(category)

    category.recipeItems?.removeAll()
    category.recipeCategory = "冷飲溫度"
    category.sequenceNumber = 2
    category.allowedMultiFlag = false
    item.recipeName = "完全去冰"
    item.sequenceNumber = 1
    category.recipeItems?.append(item)
    item.recipeName = "去冰"
    item.sequenceNumber = 2
    category.recipeItems?.append(item)
    item.recipeName = "微冰"
    item.sequenceNumber = 3
    category.recipeItems?.append(item)
    item.recipeName = "少冰"
    item.sequenceNumber = 4
    category.recipeItems?.append(item)
    item.recipeName = "正常冰"
    item.sequenceNumber = 5
    category.recipeItems?.append(item)
    template.menuRecipes.append(category)

    category.recipeItems?.removeAll()
    category.recipeCategory = "甜度"
    category.sequenceNumber = 3
    category.allowedMultiFlag = false
    item.recipeName = "無糖"
    item.sequenceNumber = 1
    category.recipeItems?.append(item)
    item.recipeName = "微糖"
    item.sequenceNumber = 2
    category.recipeItems?.append(item)
    item.recipeName = "半糖"
    item.sequenceNumber = 3
    category.recipeItems?.append(item)
    item.recipeName = "少糖"
    item.sequenceNumber = 4
    category.recipeItems?.append(item)
    item.recipeName = "全糖"
    item.sequenceNumber = 5
    category.recipeItems?.append(item)
    template.menuRecipes.append(category)

    category.recipeItems?.removeAll()
    category.recipeCategory = "配料"
    category.sequenceNumber = 4
    category.allowedMultiFlag = true
    item.recipeName = "波霸"
    item.sequenceNumber = 1
    category.recipeItems?.append(item)
    item.recipeName = "珍珠"
    item.sequenceNumber = 2
    category.recipeItems?.append(item)
    template.menuRecipes.append(category)

    let databaseRef = Database.database().reference()
    let pathString = "MENU_RECIPE_TEMPLATE/\(template.templateName)"
    
    databaseRef.child(pathString).setValue(template.toAnyObject())

}

func testObserveEventFunction() {
    let databaseRef = Database.database().reference()
    let pathString = "BRAND_PROFILE/BRAND_PROFILE/0/brandID"

    databaseRef.child(pathString).observe(.value, with: { (snapshot) in
        if snapshot.exists() {
            let itemRawData = snapshot.value
            print("itemRawData = \(String(describing: itemRawData))")
            //let jsonData = try? JSONSerialization.data(withJSONObject: itemRawData as Any, options: [])

            //let decoder: JSONDecoder = JSONDecoder()
            //do {
            //    let brandID = try decoder.decode(Int.self, from: jsonData!)
            //    print("brandID = \(brandID)")
            //} catch {
            //    print("testObserveEventFunction jsonData decode failed: \(error.localizedDescription)")
            //}
        } else {
            print("testObserveEventFunction snapshot doesn't exist!")
            return
        }
    }) { (error) in
        print(error.localizedDescription)
    }
}

func testRemoveObserveEventFunction() {
    let databaseRef = Database.database().reference()
    let pathString = "BRAND_PROFILE/BRAND_PROFILE/0/brandID"
    databaseRef.child(pathString).removeAllObservers()
}

func testUploadBrandDetail() {
    var detailBrand: DetailBrandProfile = DetailBrandProfile()
    var detailMenu: DetailMenuInformation = DetailMenuInformation()
    var productList: [DetailProductItem] = [DetailProductItem]()
    
    detailBrand.brandName = "Teas原味"
    detailBrand.brandIconImage = "Brand_Image/Teas原味.png"
    detailBrand.brandCategory = "茶飲類"
    detailBrand.menuNumber = "Teas原味_MENU"
    detailBrand.brandSubCategory = ""
    detailBrand.updateDateTime = "20200628124800000"
    
    let databaseRef = Database.database().reference()

    /*
     [DetailMenuInformation]
     var menuNumber: String = ""
     var menuDescription: String?
     var multiMenuImageURL: [String]?
     //var locations: [String]?
     var productItems: [DetailProductItem]?
     var createTime: String = ""
     */
    
    detailMenu.menuNumber = detailBrand.menuNumber
    detailMenu.createTime = "20200628124800000"
    detailMenu.recipeTemplates = [DetailRecipeTemplate]()
    detailMenu.productCategory = [DetailProductCategory]()
    var tmpProd: DetailProductItem = DetailProductItem()
    var tt: DetailRecipeTemplate = DetailRecipeTemplate()
    var ri: DetailRecipeItem = DetailRecipeItem()


    /*
     [DetailProductItem]
     var productName: String = ""
     var productCategory: String?
     var productSubCategory: String?
     var productDescription: String?
     var productImageURL: [String]?
     var productBasicPrice: Int = 0
     var recipeTemplates: [DetailRecipeTemplate]?
     var priceList: [DetailRecipeItemPrice]?
     */
    tmpProd.productName = "阿里山香片"
    tmpProd.productCategory = "茶香系列"
    tmpProd.productBasicPrice = 0
    //tmpProd.recipeTemplates = [DetailRecipeTemplate]()

    /*
     var templateSequence: Int = 0
     var templateName: String = ""
     var templateCategory: String?
     var mandatoryFlag: Bool = false
     var allowMultiSelectionFlag: Bool = false
     var priceRelatedFlag: Bool = false
     var recipeList: [DetailRecipeItem] = [DetailRecipeItem]()
     */
    
    tt.templateSequence = 1
    tt.templateName = "容量"
    tt.mandatoryFlag = true
    tt.allowMultiSelectionFlag = false
    //tt.priceRelatedFlag = true
    tt.recipeList.removeAll()
    
    ri.itemSequence = 1
    ri.itemName = "M"
    ri.itemCheckedFlag = true
    tt.recipeList.append(ri)
    ri.itemSequence = 2
    ri.itemName = "L"
    ri.itemCheckedFlag = true
    tt.recipeList.append(ri)
    ri.itemSequence = 3
    ri.itemName = "瓶裝"
    ri.itemCheckedFlag = true
    tt.recipeList.append(ri)
    detailMenu.recipeTemplates!.append(tt)
    
    var pc: DetailProductCategory = DetailProductCategory()
    pc.categoryName = "茶香系列"
    pc.priceTemplate = tt
    detailMenu.productCategory!.append(pc)
    
    tt.templateSequence = 2
    tt.templateName = "糖度"
    tt.mandatoryFlag = true
    tt.allowMultiSelectionFlag = false
    //tt.priceRelatedFlag = false
    tt.recipeList.removeAll()
    
    ri.itemSequence = 1
    ri.itemName = "無糖"
    ri.itemCheckedFlag = true
    tt.recipeList.append(ri)
    ri.itemSequence = 2
    ri.itemName = "微糖"
    ri.itemCheckedFlag = true
    tt.recipeList.append(ri)
    ri.itemSequence = 3
    ri.itemName = "半糖"
    ri.itemCheckedFlag = true
    tt.recipeList.append(ri)
    ri.itemSequence = 4
    ri.itemName = "少糖"
    ri.itemCheckedFlag = true
    tt.recipeList.append(ri)
    ri.itemSequence = 5
    ri.itemName = "正常糖"
    ri.itemCheckedFlag = true
    tt.recipeList.append(ri)
    detailMenu.recipeTemplates!.append(tt)

    tt.templateSequence = 3
    tt.templateName = "冰量"
    tt.mandatoryFlag = true
    tt.allowMultiSelectionFlag = false
    //tt.priceRelatedFlag = false
    tt.recipeList.removeAll()
    
    ri.itemSequence = 1
    ri.itemName = "去冰"
    ri.itemCheckedFlag = true
    tt.recipeList.append(ri)
    ri.itemSequence = 2
    ri.itemName = "微冰"
    ri.itemCheckedFlag = true
    tt.recipeList.append(ri)
    ri.itemSequence = 3
    ri.itemName = "少冰"
    ri.itemCheckedFlag = true
    tt.recipeList.append(ri)
    ri.itemSequence = 4
    ri.itemName = "正常冰"
    ri.itemCheckedFlag = true
    tt.recipeList.append(ri)
    detailMenu.recipeTemplates!.append(tt)

    //tmpProd.relatedTemplates = [1, 2, 3]
    tmpProd.priceList = [DetailRecipeItemPrice]()
    var tmpPrice: DetailRecipeItemPrice = DetailRecipeItemPrice()
    tmpPrice.recipeItemName = "M"
    tmpPrice.price = 20
    tmpPrice.availableFlag = true
    tmpProd.priceList!.append(tmpPrice)

    tmpPrice.recipeItemName = "L"
    tmpPrice.price = 25
    tmpPrice.availableFlag = true
    tmpProd.priceList!.append(tmpPrice)

    tmpPrice.recipeItemName = "瓶裝"
    tmpPrice.price = 45
    tmpPrice.availableFlag = true
    tmpProd.priceList!.append(tmpPrice)
    
    productList.append(tmpProd)
    //detailMenu.productItems = productList
    
    let menuString = "DETAIL_MENU_INFORMATION/\(detailMenu.menuNumber)"
    databaseRef.child(menuString).setValue(detailMenu.toAnyObject())

}

func testUpdateBrandProfile(brand_profile: DetailBrandProfile?) {
    if brand_profile == nil {
        return
    }

    var brandData: DetailBrandProfile = DetailBrandProfile()
    brandData = brand_profile!
    
    let back: [Float] = [212.0, 187.0, 146.0]
    let tabbar: [Float] = [83.0, 41.0, 18.0]
    let text: [Float] = [255.0, 255.0, 255.0]
    var style: DetailStyle = DetailStyle()
    style.backgroundColor = back
    style.tabBarColor = tabbar
    style.textTintColor = text
    
    brandData.brandStyle = style
    let databaseRef = Database.database().reference()
    let pathStirng = "DETAIL_BRAND_PROFILE/上宇林"
    
    databaseRef.child(pathStirng).setValue(brandData.toAnyObject())
}
