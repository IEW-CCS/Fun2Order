//
//  HomeViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/10.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit
import CoreData
import Firebase


class HomeViewController: UIViewController, FSPagerViewDataSource, FSPagerViewDelegate {
    @IBOutlet weak var pageControl: FSPageControl!
    
    @IBOutlet weak var pagerView: FSPagerView!

    var updateInformation: UpdateInformation!
    var brandProfileList: BrandProfileList!
    var codeTableList: CodeTableList!
    var productInformationList: ProductInformationList!
    var storeInformationList: StoreInformationList!
    var productRecipeList: ProductRecipeList!
    
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!

    let imageNames = ["1.png","2.png","3.png","4.png","5.png","6.png","7.png", "8.png"]
    let imageTitles = ["嵐山", "車折神社", "清水寺", "直指庵", "圓光寺", "高台寺", "北野天滿宮", "高雄神護寺"]
    let imageDescription = [
        "京都的「嵐山」是無人不知無人不曉的日本代表性賞楓名所。既是國家級史蹟，又是國家指定名勝景點的「嵐山」，其楓紅時期的景致宛如一幅絕美的畫作。非常推薦大家搭乘超有人氣的「嵯峨野遊覽小火車」，從各種角度來賞楓!",
        "擁有大國主神社、弁天神社、藝能神社等3間境內神社的「車折神社」，是相當有名的藝人神社，來此參拜的藝人絡繹不絕。此外，神社周圍寫滿一整面藝人姓名的木柵欄也相當有名。這間「車折神社」不但四季的美景獲得好評，更是許多人會前來造訪的賞楓景點!",
        "提到京都觀光景點絕對少不了「清水寺」的紅葉，能從樹木上方眺望，感受不同於以往的觀賞樂趣。此外，於11月中旬~12月初會舉行「秋季夜間特別參拜」，夜晚打上燈光的紅葉可說是絶景，相當有值得一看的價值!",
        "京都的私房賞楓景點「直指庵」為淨土宗的寺院，不但觀賞期間較長，被寂靜所包圍的景觀也充滿著浪漫的氛圍。「直指庵」內有一尊「愛逢地藏」像，因此也是相當有人氣的祈求良緣景點!",
        "「圓光寺」是臨濟宗南禪寺派的寺院。能在寺院內的池泉回遊式庭園「十牛之庭」與枯山水式庭園「奔龍庭」欣賞秋季的楓紅，對比鮮明的繽紛色彩非常美麗，因此獲得好評。樹葉從11 月中旬開始變色，11月下旬則進入觀賞的最佳時期。",
        "距離「八坂神社」不遠處有一個有名的賞楓地點「高台寺」，每年總會吸引大批遊客前來造訪。此處的池泉回遊式庭園據說是由豐臣秀吉之妻「寧寧」所建造的，每到紅葉變色的季節，美麗的庭園與「高台寺」相互輝映，形成饒富逸趣的景致。",
        "以「春梅名所」而聞名的「北野天滿宮」，近年期間限定開放參觀的「史跡御土居的紅葉苑」成為最受矚目的新賞楓景點。約250棵楓樹在夜晚打上燈光後的景色可以說是觀賞重點!11月下旬〜12月上旬為最佳觀賞期，觀光客絡繹不絕相當熱鬧!",
        "京都郊區的踏青地點「高雄神護寺」一帶，與梅畑槙尾町的「西明寺」、梅畑栂尾町的「高山寺」並稱「三尾」，是自古以來便為人所知的紅葉名所。特別是人氣紅葉名所「高雄神護寺」內的五大堂被紅葉所包圍的景 觀更是必看重點，夜晚點燈後更顯絕美!"]
    
    
    
    fileprivate let transformerNames = ["cross fading", "zoom out", "depth", "linear", "overlap", "ferris wheel", "inverted ferris wheel", "coverflow", "cubic"]
    fileprivate let transformerTypes: [FSPagerViewTransformerType] = [.crossFading,
                                                              .zoomOut,
                                                              .depth,
                                                              .linear,
                                                              .overlap,
                                                              .ferrisWheel,
                                                              .invertedFerrisWheel,
                                                              .coverFlow,
                                                              .cubic]
    
    fileprivate var typeIndex = 0 {
        didSet {
            let type = self.transformerTypes[typeIndex]
            self.pagerView.transformer = FSPagerViewTransformer(type:type)
            switch type {
            case .crossFading, .zoomOut, .depth:
                self.pagerView.itemSize = FSPagerView.automaticSize
                self.pagerView.decelerationDistance = 1
            case .linear, .overlap:
                let transform = CGAffineTransform(scaleX: 0.6, y: 0.75)
                self.pagerView.itemSize = self.pagerView.frame.size.applying(transform)
                self.pagerView.decelerationDistance = FSPagerView.automaticDistance
            case .ferrisWheel, .invertedFerrisWheel:
                self.pagerView.itemSize = CGSize(width: 180, height: 140)
                self.pagerView.decelerationDistance = FSPagerView.automaticDistance
            case .coverFlow:
                self.pagerView.itemSize = CGSize(width: 220, height: 170)
                self.pagerView.decelerationDistance = FSPagerView.automaticDistance
            case .cubic:
                let transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.pagerView.itemSize = self.pagerView.frame.size.applying(transform)
                self.pagerView.decelerationDistance = 1
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vc = app.persistentContainer.viewContext

        setupPageView()
        requestUpdateDateTime()
        print("sqlite path --> \(app.persistentContainer.persistentStoreDescriptions)")
    }
    
    private func setupPageView() {
        self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "PageViewCell")
        self.pagerView.automaticSlidingInterval = 3.0
        self.pagerView.isInfinite = true
        self.pagerView.delegate = self
        self.pagerView.dataSource = self
        self.pageControl.numberOfPages = self.imageNames.count
        self.pageControl.contentHorizontalAlignment = .center
        self.pageControl.contentInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        self.typeIndex = 8
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let index = self.typeIndex
        self.typeIndex = index // Manually trigger didSet
    }

    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return imageNames.count
    }
    
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "PageViewCell", at: index)
        cell.imageView?.image = UIImage(named: self.imageNames[index])
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        cell.textLabel?.text = self.imageTitles[index]
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
        
        print("Image [\(index)] is selected")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "Banner_VC") as? BannerDetailViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: pickerStoryboard can't find!! (ViewController)")
            return
        }

        let img = UIImage(named: self.imageNames[index])!
        vc.modalTransitionStyle = .flipHorizontal
        vc.modalPresentationStyle = .overCurrentContext
        navigationController?.present(vc, animated: true, completion: nil)
        vc.setData(image_name: img, image_description: self.imageDescription[index])
    }
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        self.pageControl.currentPage = targetIndex
    }
    
    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        self.pageControl.currentPage = pagerView.currentIndex
    }

    func requestUpdateDateTime() {
        let sessionConf = URLSessionConfiguration.default
        sessionConf.timeoutIntervalForRequest = HTTP_REQUEST_TIMEOUT
        sessionConf.timeoutIntervalForResource = HTTP_REQUEST_TIMEOUT
        let sessionHttp = URLSession(configuration: sessionConf)

        let temp = getFirebaseUrlForRequest(uri: "UpdateInformation")
        let urlString = temp.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlRequest = URLRequest(url: URL(string: urlString)!)

        print("requestUpdateDateTime")
        let task = sessionHttp.dataTask(with: urlRequest) {(data, response, error) in
            do {
                if error != nil{
                    //DispatchQueue.main.async {self.presentedViewController?.dismiss(animated: false, completion: nil)}
                    let httpAlert = alert(message: error!.localizedDescription, title: "Http Error")
                    self.present(httpAlert, animated : false, completion : nil)
                } else {
                    guard let httpResponse = response as? HTTPURLResponse,
                        (200...299).contains(httpResponse.statusCode) else {
                            let errorResponse = response as? HTTPURLResponse
                            let message: String = String(errorResponse!.statusCode) + " - " + HTTPURLResponse.localizedString(forStatusCode: errorResponse!.statusCode)
                            //DispatchQueue.main.async {self.presentedViewController?.dismiss(animated: false, completion: nil)}
                            let httpAlert = alert(message: message, title: "Http Error")
                            self.present(httpAlert, animated : false, completion : nil)
                            return
                    }
                    
                    //DispatchQueue.main.async {self.presentedViewController?.dismiss(animated: false, completion: nil)}
                    
                    let outputStr  = String(data: data!, encoding: String.Encoding.utf8) as String?
                    let jsonData = outputStr!.data(using: String.Encoding.utf8, allowLossyConversion: true)
                    let decoder = JSONDecoder()
                    self.updateInformation = try decoder.decode(UpdateInformation.self, from: jsonData!)
                    self.checkUpdateInformation()
                }
            } catch {
                print(error.localizedDescription)
                let httpAlert = alert(message: error.localizedDescription, title: "Request UpdateInformation Error")
                self.present(httpAlert, animated : false, completion : nil)
                return
            }
        }
        task.resume()
        
        return
    }
    
    func checkUpdateInformation() {
        var sysUpdateDT = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = DATETIME_FORMATTER
        sysUpdateDT = dateFormatter.date(from: self.updateInformation.systemUpdateDateTime)!
        let lastQueryDT = getLastQueryTime()
        
        if lastQueryDT >= sysUpdateDT {
            print("No need to update basic data.")
            updateLastQueryTime()
            print("LastSystemQueryTime is \(getLastQueryTime())")
        } else {
            print("Server updated information, start to request necessary data.")
            deleteAllBrandProfiles()
            deleteAllCodeTable()
            deleteAllProductInformation()
            deleteAllProductRecipe()
            deleteAllStoreInformation()

            requestBrandProfile()
            requestCodeTable()
            requestProductInformation()
            requestProductRecipe()
            requestStoreInformation()
            
            updateLastQueryTime()
            print("LastSystemQueryTime is \(getLastQueryTime())")
        }
    }
    
    func requestCodeTable() {
        let sessionConf = URLSessionConfiguration.default
        sessionConf.timeoutIntervalForRequest = HTTP_REQUEST_TIMEOUT
        sessionConf.timeoutIntervalForResource = HTTP_REQUEST_TIMEOUT
        let sessionHttp = URLSession(configuration: sessionConf)

        let temp = getFirebaseUrlForRequest(uri: "CODE_TABLE")
        let urlString = temp.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlRequest = URLRequest(url: URL(string: urlString)!)

        print("requestCodeTable")
        let task = sessionHttp.dataTask(with: urlRequest) {(data, response, error) in
            do {
                if error != nil{
                    //DispatchQueue.main.async {self.presentedViewController?.dismiss(animated: false, completion: nil)}
                    let httpAlert = alert(message: error!.localizedDescription, title: "Http Error")
                    self.present(httpAlert, animated : false, completion : nil)
                } else {
                    guard let httpResponse = response as? HTTPURLResponse,
                        (200...299).contains(httpResponse.statusCode) else {
                            let errorResponse = response as? HTTPURLResponse
                            let message: String = String(errorResponse!.statusCode) + " - " + HTTPURLResponse.localizedString(forStatusCode: errorResponse!.statusCode)
                            //DispatchQueue.main.async {self.presentedViewController?.dismiss(animated: false, completion: nil)}
                            let httpAlert = alert(message: message, title: "Http Error")
                            self.present(httpAlert, animated : false, completion : nil)
                            return
                    }
                    
                    //DispatchQueue.main.async {self.presentedViewController?.dismiss(animated: false, completion: nil)}
                    
                    let outputStr  = String(data: data!, encoding: String.Encoding.utf8) as String?
                    let jsonData = outputStr!.data(using: String.Encoding.utf8, allowLossyConversion: true)
                    let decoder = JSONDecoder()
                    self.codeTableList = try decoder.decode(CodeTableList.self, from: jsonData!)

                    if self.codeTableList.CODE_TABLE.count > 0 {
                        print("Code Table Count = \(self.codeTableList.CODE_TABLE.count)")
                        self.updateCodeTableToCoreData()
                    }
                }
            } catch {
                print(error.localizedDescription)
                let httpAlert = alert(message: error.localizedDescription, title: "Request Code Table Error")
                self.present(httpAlert, animated : false, completion : nil)
                return
            }
        }
        task.resume()
        
        return
    }
    
    func updateCodeTableToCoreData() {
        for i in 0...self.codeTableList.CODE_TABLE.count - 1 {
            let codeData = NSEntityDescription.insertNewObject(forEntityName: "CODE_TABLE", into: vc) as! CODE_TABLE
            codeData.codeCategory = self.codeTableList.CODE_TABLE[i].codeCategory
            codeData.code = self.codeTableList.CODE_TABLE[i].code
            codeData.subCode = self.codeTableList.CODE_TABLE[i].subCode
            codeData.codeExtension = self.codeTableList.CODE_TABLE[i].codeExtension
            codeData.index = Int32(self.codeTableList.CODE_TABLE[i].index)
            codeData.codeDescription = self.codeTableList.CODE_TABLE[i].codeDescription
            codeData.subItem = self.codeTableList.CODE_TABLE[i].subItem
            codeData.extension1 = self.codeTableList.CODE_TABLE[i].extension1
            codeData.extension2 = self.codeTableList.CODE_TABLE[i].extension2
            codeData.extension3 = self.codeTableList.CODE_TABLE[i].extension3
            codeData.extension4 = self.codeTableList.CODE_TABLE[i].extension4
            codeData.extension5 = self.codeTableList.CODE_TABLE[i].extension5
        }
        self.app.saveContext()
        updateLastQueryTime()
    }

    func requestProductInformation() {
        let sessionConf = URLSessionConfiguration.default
        sessionConf.timeoutIntervalForRequest = HTTP_REQUEST_TIMEOUT
        sessionConf.timeoutIntervalForResource = HTTP_REQUEST_TIMEOUT
        let sessionHttp = URLSession(configuration: sessionConf)

        let temp = getFirebaseUrlForRequest(uri: "PRODUCT_INFORMATION")
        let urlString = temp.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlRequest = URLRequest(url: URL(string: urlString)!)

        print("requestProductInformation")
        let task = sessionHttp.dataTask(with: urlRequest) {(data, response, error) in
            do {
                if error != nil{
                    //DispatchQueue.main.async {self.presentedViewController?.dismiss(animated: false, completion: nil)}
                    let httpAlert = alert(message: error!.localizedDescription, title: "Http Error")
                    self.present(httpAlert, animated : false, completion : nil)
                } else {
                    guard let httpResponse = response as? HTTPURLResponse,
                        (200...299).contains(httpResponse.statusCode) else {
                            let errorResponse = response as? HTTPURLResponse
                            let message: String = String(errorResponse!.statusCode) + " - " + HTTPURLResponse.localizedString(forStatusCode: errorResponse!.statusCode)
                            //DispatchQueue.main.async {self.presentedViewController?.dismiss(animated: false, completion: nil)}
                            let httpAlert = alert(message: message, title: "Http Error")
                            self.present(httpAlert, animated : false, completion : nil)
                            return
                    }
                    
                    //DispatchQueue.main.async {self.presentedViewController?.dismiss(animated: false, completion: nil)}
                    
                    let outputStr  = String(data: data!, encoding: String.Encoding.utf8) as String?
                    let jsonData = outputStr!.data(using: String.Encoding.utf8, allowLossyConversion: true)
                    let decoder = JSONDecoder()
                    self.productInformationList = try decoder.decode(ProductInformationList.self, from: jsonData!)

                    if self.productInformationList.PRODUCT_INFORMATION.count > 0 {
                        print("Product Information Count = \(self.self.productInformationList.PRODUCT_INFORMATION.count)")
                        self.updateProductInformationToCoreData()
                    }
                }
            } catch {
                print(error.localizedDescription)
                let httpAlert = alert(message: error.localizedDescription, title: "Request Product Information Error")
                self.present(httpAlert, animated : false, completion : nil)
                return
            }
        }
        task.resume()
        
        return
    }
    
    func updateProductInformationToCoreData() {
        let storage = Storage.storage()

        for i in 0...self.productInformationList.PRODUCT_INFORMATION.count - 1 {
            let productData = NSEntityDescription.insertNewObject(forEntityName: "PRODUCT_INFORMATION", into: vc) as! PRODUCT_INFORMATION
            productData.brandID = Int16(self.productInformationList.PRODUCT_INFORMATION[i].brandID)
            productData.productID = Int16(self.productInformationList.PRODUCT_INFORMATION[i].productID)
            productData.productCategory = self.productInformationList.PRODUCT_INFORMATION[i].productCategory
            productData.productName = self.productInformationList.PRODUCT_INFORMATION[i].productName
            productData.productDescription = self.productInformationList.PRODUCT_INFORMATION[i].productDescription
            productData.recommand = self.productInformationList.PRODUCT_INFORMATION[i].recommand
            productData.popularity = self.productInformationList.PRODUCT_INFORMATION[i].popularity
            productData.limit = self.productInformationList.PRODUCT_INFORMATION[i].limit

            let pathReference = storage.reference(withPath: "Product_Image/\(self.productInformationList.PRODUCT_INFORMATION[i].productImage)")
            pathReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        let httpAlert = alert(message: error.localizedDescription, title: "Request Product Image Error")
                        self.present(httpAlert, animated : false, completion : nil)
                        return
                    }
                } else {
                    print("Get Product Image: \(self.productInformationList.PRODUCT_INFORMATION[i].productImage) from Firebase")
                    productData.productImage = data!
                    self.app.saveContext()
                }
            }
        }
        updateLastQueryTime()
    }
    
    func requestProductRecipe() {
        let sessionConf = URLSessionConfiguration.default
        sessionConf.timeoutIntervalForRequest = HTTP_REQUEST_TIMEOUT * 2
        sessionConf.timeoutIntervalForResource = HTTP_REQUEST_TIMEOUT * 2
        let sessionHttp = URLSession(configuration: sessionConf)

        let temp = getFirebaseUrlForRequest(uri: "PRODUCT_RECIPE")
        let urlString = temp.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlRequest = URLRequest(url: URL(string: urlString)!)

        print("requestProductRecipe")
        let task = sessionHttp.dataTask(with: urlRequest) {(data, response, error) in
            do {
                if error != nil{
                    //DispatchQueue.main.async {self.presentedViewController?.dismiss(animated: false, completion: nil)}
                    let httpAlert = alert(message: error!.localizedDescription, title: "Http Error")
                    self.present(httpAlert, animated : false, completion : nil)
                } else {
                    guard let httpResponse = response as? HTTPURLResponse,
                        (200...299).contains(httpResponse.statusCode) else {
                            let errorResponse = response as? HTTPURLResponse
                            let message: String = String(errorResponse!.statusCode) + " - " + HTTPURLResponse.localizedString(forStatusCode: errorResponse!.statusCode)
                            //DispatchQueue.main.async {self.presentedViewController?.dismiss(animated: false, completion: nil)}
                            let httpAlert = alert(message: message, title: "Http Error")
                            self.present(httpAlert, animated : false, completion : nil)
                            return
                    }
                    
                    //DispatchQueue.main.async {self.presentedViewController?.dismiss(animated: false, completion: nil)}
                    
                    let outputStr  = String(data: data!, encoding: String.Encoding.utf8) as String?
                    let jsonData = outputStr!.data(using: String.Encoding.utf8, allowLossyConversion: true)
                    let decoder = JSONDecoder()
                    self.productRecipeList = try decoder.decode(ProductRecipeList.self, from: jsonData!)

                    if self.productRecipeList.PRODUCT_RECIPE.count > 0 {
                        print("Product Recipe Count = \(self.productRecipeList.PRODUCT_RECIPE.count)")
                        self.updateProductRecipeToCoreData()
                    }
                }
            } catch {
                print(error.localizedDescription)
                let httpAlert = alert(message: error.localizedDescription, title: "Request Product Recipe Error")
                self.present(httpAlert, animated : false, completion : nil)
                return
            }
        }
        task.resume()
        
        return
    }
    
    func updateProductRecipeToCoreData() {
        for i in 0...self.productRecipeList.PRODUCT_RECIPE.count - 1 {
            let productRecipeData = NSEntityDescription.insertNewObject(forEntityName: "PRODUCT_RECIPE", into: vc) as! PRODUCT_RECIPE
            
            productRecipeData.brandID = Int16(self.productRecipeList.PRODUCT_RECIPE[i].brandID)
            productRecipeData.storeID = Int16(self.productRecipeList.PRODUCT_RECIPE[i].storeID)
            productRecipeData.productID = Int16(self.productRecipeList.PRODUCT_RECIPE[i].productID)
            productRecipeData.recipe1 = self.productRecipeList.PRODUCT_RECIPE[i].recipe1
            productRecipeData.recipe2 = self.productRecipeList.PRODUCT_RECIPE[i].recipe2
            productRecipeData.recipe3 = self.productRecipeList.PRODUCT_RECIPE[i].recipe3
            productRecipeData.recipe4 = self.productRecipeList.PRODUCT_RECIPE[i].recipe4
            productRecipeData.recipe5 = self.productRecipeList.PRODUCT_RECIPE[i].recipe5
            productRecipeData.recipe6 = self.productRecipeList.PRODUCT_RECIPE[i].recipe6
            productRecipeData.recipe7 = self.productRecipeList.PRODUCT_RECIPE[i].recipe7
            productRecipeData.recipe8 = self.productRecipeList.PRODUCT_RECIPE[i].recipe8
            productRecipeData.recipe9 = self.productRecipeList.PRODUCT_RECIPE[i].recipe9
            productRecipeData.recipe10 = self.productRecipeList.PRODUCT_RECIPE[i].recipe10
        }

        self.app.saveContext()
        updateLastQueryTime()
    }
    
    func requestStoreInformation() {
        let sessionConf = URLSessionConfiguration.default
        sessionConf.timeoutIntervalForRequest = HTTP_REQUEST_TIMEOUT
        sessionConf.timeoutIntervalForResource = HTTP_REQUEST_TIMEOUT
        let sessionHttp = URLSession(configuration: sessionConf)

        let temp = getFirebaseUrlForRequest(uri: "STORE_INFORMATION")
        let urlString = temp.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlRequest = URLRequest(url: URL(string: urlString)!)

        print("requestStoreInformation")
        let task = sessionHttp.dataTask(with: urlRequest) {(data, response, error) in
            do {
                if error != nil{
                    //DispatchQueue.main.async {self.presentedViewController?.dismiss(animated: false, completion: nil)}
                    let httpAlert = alert(message: error!.localizedDescription, title: "Http Error")
                    self.present(httpAlert, animated : false, completion : nil)
                } else {
                    guard let httpResponse = response as? HTTPURLResponse,
                        (200...299).contains(httpResponse.statusCode) else {
                            let errorResponse = response as? HTTPURLResponse
                            let message: String = String(errorResponse!.statusCode) + " - " + HTTPURLResponse.localizedString(forStatusCode: errorResponse!.statusCode)
                            //DispatchQueue.main.async {self.presentedViewController?.dismiss(animated: false, completion: nil)}
                            let httpAlert = alert(message: message, title: "Http Error")
                            self.present(httpAlert, animated : false, completion : nil)
                            return
                    }
                    
                    //DispatchQueue.main.async {self.presentedViewController?.dismiss(animated: false, completion: nil)}
                    
                    let outputStr  = String(data: data!, encoding: String.Encoding.utf8) as String?
                    let jsonData = outputStr!.data(using: String.Encoding.utf8, allowLossyConversion: true)
                    let decoder = JSONDecoder()
                    self.storeInformationList = try decoder.decode(StoreInformationList.self, from: jsonData!)

                    if self.storeInformationList.STORE_INFORMATION.count > 0 {
                        print("Store Information Count = \(self.storeInformationList.STORE_INFORMATION.count)")
                        self.updateStoreInformationToCoreData()
                    }
                }
            } catch {
                print(error.localizedDescription)
                let httpAlert = alert(message: error.localizedDescription, title: "Request Store Information Error")
                self.present(httpAlert, animated : false, completion : nil)
                return
            }
        }
        task.resume()
        
        return
    }
    
    func updateStoreInformationToCoreData() {
        for i in 0...self.storeInformationList.STORE_INFORMATION.count - 1 {
            let storeData = NSEntityDescription.insertNewObject(forEntityName: "STORE_INFORMATION", into: vc) as! STORE_INFORMATION
            
            storeData.brandID = Int16(self.storeInformationList.STORE_INFORMATION[i].brandID)
            storeData.storeID = Int16(self.storeInformationList.STORE_INFORMATION[i].storeID)
            storeData.storeCategory = self.storeInformationList.STORE_INFORMATION[i].storeCategory
            storeData.storeSubCategory = self.storeInformationList.STORE_INFORMATION[i].storeSubCategory
            storeData.storeName = self.storeInformationList.STORE_INFORMATION[i].storeName
            storeData.storeDescription = self.storeInformationList.STORE_INFORMATION[i].storeDescription
            storeData.storeAddress = self.storeInformationList.STORE_INFORMATION[i].storeAddress
            storeData.storePhoneNumber = self.storeInformationList.STORE_INFORMATION[i].storePhoneNumber
            storeData.deliveryService = self.storeInformationList.STORE_INFORMATION[i].deliveryService
        }

        self.app.saveContext()
        updateLastQueryTime()
    }
    
    func requestBrandProfile() {
        let sessionConf = URLSessionConfiguration.default
        sessionConf.timeoutIntervalForRequest = HTTP_REQUEST_TIMEOUT
        sessionConf.timeoutIntervalForResource = HTTP_REQUEST_TIMEOUT
        let sessionHttp = URLSession(configuration: sessionConf)

        let temp = getFirebaseUrlForRequest(uri: "BRAND_PROFILE")
        let urlString = temp.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlRequest = URLRequest(url: URL(string: urlString)!)

        print("requestBrandProfile")
        let task = sessionHttp.dataTask(with: urlRequest) {(data, response, error) in
            do {
                if error != nil{
                    //DispatchQueue.main.async {self.presentedViewController?.dismiss(animated: false, completion: nil)}
                    let httpAlert = alert(message: error!.localizedDescription, title: "Http Error")
                    self.present(httpAlert, animated : false, completion : nil)
                } else {
                    guard let httpResponse = response as? HTTPURLResponse,
                        (200...299).contains(httpResponse.statusCode) else {
                            let errorResponse = response as? HTTPURLResponse
                            let message: String = String(errorResponse!.statusCode) + " - " + HTTPURLResponse.localizedString(forStatusCode: errorResponse!.statusCode)
                            //DispatchQueue.main.async {self.presentedViewController?.dismiss(animated: false, completion: nil)}
                            let httpAlert = alert(message: message, title: "Http Error")
                            self.present(httpAlert, animated : false, completion : nil)
                            return
                    }
                    
                    //DispatchQueue.main.async {self.presentedViewController?.dismiss(animated: false, completion: nil)}
                    
                    let outputStr  = String(data: data!, encoding: String.Encoding.utf8) as String?
                    let jsonData = outputStr!.data(using: String.Encoding.utf8, allowLossyConversion: true)
                    let decoder = JSONDecoder()
                    self.brandProfileList = try decoder.decode(BrandProfileList.self, from: jsonData!)

                    if self.brandProfileList.BRAND_PROFILE.count > 0 {
                        print("Brand Profiles Count = \(self.brandProfileList.BRAND_PROFILE.count)")
                        self.updateBrandProfileToCoreData()
                    }
                }
            } catch {
                print(error.localizedDescription)
                let httpAlert = alert(message: error.localizedDescription, title: "Request Brand Profile Error")
                self.present(httpAlert, animated : false, completion : nil)
                return
            }
        }
        task.resume()
        
        return
    }
    
    func updateBrandProfileToCoreData() {
        let storage = Storage.storage()
        
        for i in 0...self.brandProfileList.BRAND_PROFILE.count - 1 {
            let brandData = NSEntityDescription.insertNewObject(forEntityName: "BRAND_PROFILE", into: vc) as! BRAND_PROFILE
            brandData.brandID = Int16(self.brandProfileList.BRAND_PROFILE[i].brandID)
            brandData.brandName = self.brandProfileList.BRAND_PROFILE[i].brandName
            brandData.brandCategory = self.brandProfileList.BRAND_PROFILE[i].brandCategory
            brandData.brandSubCategory = self.brandProfileList.BRAND_PROFILE[i].brandSubCategory
            brandData.brandDescription = self.brandProfileList.BRAND_PROFILE[i].brandDescription
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = DATETIME_FORMATTER
            brandData.brandUpdateDateTime = dateFormatter.date(from: self.brandProfileList.BRAND_PROFILE[i].brandUpdateDateTime)
            let pathReference = storage.reference(withPath: "Brand_Image/\(self.brandProfileList.BRAND_PROFILE[i].brandIconImage)")
            pathReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        let httpAlert = alert(message: error.localizedDescription, title: "Request Brand Image Error")
                        self.present(httpAlert, animated : false, completion : nil)
                        return
                    }
                } else {
                    print("Get Brand Image: \(self.brandProfileList.BRAND_PROFILE[i].brandIconImage) from Firebase")
                    brandData.brandIconImage = data!
                    self.app.saveContext()
                }
            }
        }
        updateLastQueryTime()
    }
}
