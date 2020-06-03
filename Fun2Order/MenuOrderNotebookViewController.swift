//
//  MenuOrderNotebookViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/22.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit


class MenuOrderNotebookViewController: UIViewController {
    @IBOutlet weak var buttonCopy: UIButton!
    @IBOutlet weak var segmentOption: UISegmentedControl!
    @IBOutlet weak var buttonShare: UIButton!
    @IBOutlet weak var collectionReport: UICollectionView!
    @IBOutlet weak var labelStoreName: UILabel!
    @IBOutlet weak var labelPhoneNumber: UILabel!
    @IBOutlet weak var backView: UIView!


    var menuOrder: MenuOrder = MenuOrder()
    var contentString: String = ""
    var filterItems: [MenuOrderMemberContent] = [MenuOrderMemberContent]()
    var isNoLocations: Bool = true
    var orderMergedContent: [MergedContent] = [MergedContent]()
    var reportData: [ReportDataStruct] = [ReportDataStruct]()
    var layoutItemsArray: [ReportLayoutStruct] = [ReportLayoutStruct]()
    var contentWidth: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.buttonShare.setImage(UIImage(named: "Icon_Share.png")?.withRenderingMode(.alwaysTemplate), for: UIControl.State.normal)
        self.buttonShare.setImage(UIImage(named: "Icon_Share.png")?.withRenderingMode(.alwaysTemplate), for: UIControl.State.selected)
        self.buttonShare.imageView?.contentMode = .scaleAspectFit
        self.buttonShare.imageView?.tintColor = UIColor.systemBlue

        self.backView.layer.borderWidth = 1.0
        self.backView.layer.borderColor = UIColor.darkGray.cgColor
        self.backView.layer.cornerRadius = 6
        
        self.collectionReport.layer.borderWidth = 1.0
        self.collectionReport.layer.borderColor = UIColor.darkGray.cgColor
        self.collectionReport.layer.cornerRadius = 6

        self.labelStoreName.text = self.menuOrder.storeInfo?.storeName
        self.labelPhoneNumber.text = self.menuOrder.storeInfo?.storePhoneNumber
        setupSegmentOption()

        let reportCellViewNib: UINib = UINib(nibName: "ReportCell", bundle: nil)
        self.collectionReport.register(reportCellViewNib, forCellWithReuseIdentifier: "ReportCell")

        self.collectionReport.dataSource = self
        self.collectionReport.delegate = self

    }
    
    @IBAction func changeOption(_ sender: UISegmentedControl) {
        if self.isNoLocations {
            if self.segmentOption.selectedSegmentIndex == 0 {
                generateContentString()
            } else {
                generateMergedContentString()
            }
        } else {
            if self.segmentOption.selectedSegmentIndex == self.menuOrder.locations!.count {
                generateMergedContentString()
            } else {
                generateContentString()
            }
        }
        self.collectionReport.reloadData()
    }
    
    @IBAction func copyContent(_ sender: UIButton) {
        //UIPasteboard.general.string = self.textViewContent.text
        UIPasteboard.general.string = self.contentString
    }
    
    @IBAction func shareOrderInformation(_ sender: UIButton) {
        if self.contentString == "" {
            presentSimpleAlertMessage(title: "警告訊息", message: "目前訂單內容為空白，無可供分享資訊，請稍候再試。")
            return
        }
        
        let userName = getMyUserName()
        
        var msg: String = "來自[ \(userName) ] -- 揪Fun 的訂單內容\n"
        msg = msg + self.contentString
        
        let vc = UIActivityViewController(activityItems: [msg], applicationActivities: [])
        
        present(vc, animated: true)
    }
    
    func setupSegmentOption() {
        //if self.menuOrder.locations.isEmpty {
        if self.menuOrder.locations == nil {
            self.segmentOption.removeAllSegments()
            self.segmentOption.insertSegment(withTitle: "全部項目", at: 0, animated: true)
            self.segmentOption.insertSegment(withTitle: "顯示合併項目", at: 1, animated: true)
            self.segmentOption.selectedSegmentIndex = 1
            self.isNoLocations = true
        } else {
            self.segmentOption.removeAllSegments()
            for i in 0...(self.menuOrder.locations!.count - 1) {
                self.segmentOption.insertSegment(withTitle: self.menuOrder.locations![i], at: i, animated: true)
            }
            self.segmentOption.insertSegment(withTitle: "顯示合併項目", at: self.menuOrder.locations!.count, animated: true)
            //self.segmentOption.selectedSegmentIndex = 0
            self.segmentOption.selectedSegmentIndex = self.menuOrder.locations!.count
            self.isNoLocations = false
        }
        //generateContentString()
        generateMergedContentString()
    }
    
    func refreshCollectionReport() {
        //let reportLayout: OrderContentReportLayout = OrderContentReportLayout()
        let reportLayout = self.collectionReport.collectionViewLayout as! OrderContentReportLayout
        reportLayout.setLayoutItems(items: self.layoutItemsArray)
        reportLayout.setContentWidth(width: self.contentWidth)

        //self.collectionReport.collectionViewLayout.invalidateLayout()
        //self.collectionReport.setCollectionViewLayout(reportLayout, animated: true)
        DispatchQueue.main.async { self.collectionReport.reloadData() }
    }
    
    func getItemsContent(index: Int) -> [MergedContent] {
        var recipeString: String = ""
        var returnItem: MergedContent = MergedContent()
        var returnItems: [MergedContent] = [MergedContent]()
        
        if self.menuOrder.contentItems[index].orderContent.menuProductItems != nil {
            for m in 0...self.menuOrder.contentItems[index].orderContent.menuProductItems!.count - 1 {
                returnItem.owner = self.menuOrder.contentItems[index].orderContent.itemOwnerName
                returnItem.productName = self.menuOrder.contentItems[index].orderContent.menuProductItems![m].itemName

                recipeString = ""
                if self.menuOrder.contentItems[index].orderContent.menuProductItems![m].menuRecipes != nil {
                    for j in 0...self.menuOrder.contentItems[index].orderContent.menuProductItems![m].menuRecipes!.count - 1 {
                        if self.menuOrder.contentItems[index].orderContent.menuProductItems![m].menuRecipes![j].recipeItems != nil {
                            for k in 0...self.menuOrder.contentItems[index].orderContent.menuProductItems![m].menuRecipes![j].recipeItems!.count - 1 {
                                recipeString = recipeString + self.menuOrder.contentItems[index].orderContent.menuProductItems![m].menuRecipes![j].recipeItems![k].recipeName + " "
                            }
                        }
                    }
                }
                
                returnItem.mergedRecipe = recipeString
                returnItem.quantity = self.menuOrder.contentItems[index].orderContent.menuProductItems![m].itemQuantity
                returnItem.comments = self.menuOrder.contentItems[index].orderContent.menuProductItems![m].itemComments
                returnItem.location = self.menuOrder.contentItems[index].orderContent.location
                returnItems.append(returnItem)
            }
        }
        
        return returnItems
    }
    
    func getItemString(index: Int) -> String {
        var itemString: String = ""
        if self.menuOrder.contentItems[index].orderContent.menuProductItems != nil {
            for m in 0...self.menuOrder.contentItems[index].orderContent.menuProductItems!.count - 1 {
                if m != 0 {
                    itemString = itemString + "\n"
                }
                
                itemString = itemString + self.menuOrder.contentItems[index].orderContent.itemOwnerName + " " + self.menuOrder.contentItems[index].orderContent.menuProductItems![m].itemName + " "

                if self.menuOrder.contentItems[index].orderContent.menuProductItems![m].menuRecipes != nil {
                    for j in 0...self.menuOrder.contentItems[index].orderContent.menuProductItems![m].menuRecipes!.count - 1 {
                        if self.menuOrder.contentItems[index].orderContent.menuProductItems![m].menuRecipes![j].recipeItems != nil {
                            for k in 0...self.menuOrder.contentItems[index].orderContent.menuProductItems![m].menuRecipes![j].recipeItems!.count - 1 {
                                itemString = itemString + self.menuOrder.contentItems[index].orderContent.menuProductItems![m].menuRecipes![j].recipeItems![k].recipeName + " "
                            }
                        }
                    }
                }
                
                itemString = itemString + " * " + String(self.menuOrder.contentItems[index].orderContent.menuProductItems![m].itemQuantity)
                
                if self.menuOrder.contentItems[index].orderContent.menuProductItems![m].itemComments != "" {
                    itemString = itemString + " (" + self.menuOrder.contentItems[index].orderContent.menuProductItems![m].itemComments + ")"
                }
            }
        }

        return itemString
    }
    
    func getMergedItemRecipe(index: Int, product_index: Int) -> String {
        var recipeString: String = ""
        if self.menuOrder.contentItems[index].orderContent.menuProductItems != nil {
            if self.menuOrder.contentItems[index].orderContent.menuProductItems![product_index].menuRecipes != nil {
                for j in 0...self.menuOrder.contentItems[index].orderContent.menuProductItems![product_index].menuRecipes!.count - 1 {
                    if self.menuOrder.contentItems[index].orderContent.menuProductItems![product_index].menuRecipes![j].recipeItems != nil {
                        for k in 0...self.menuOrder.contentItems[index].orderContent.menuProductItems![product_index].menuRecipes![j].recipeItems!.count - 1 {
                            recipeString = recipeString + self.menuOrder.contentItems[index].orderContent.menuProductItems![product_index].menuRecipes![j].recipeItems![k].recipeName + " "
                        }
                    }
                }
            }
        }


        return recipeString
    }
    
    func generateContentString() {
        var content: String = ""
        var tmpContent: [MergedContent] = [MergedContent]()

        if self.menuOrder.contentItems.isEmpty {
            return
        }
        
        self.orderMergedContent.removeAll()
        if self.isNoLocations {
            for i in 0...self.menuOrder.contentItems.count - 1 {
                if self.menuOrder.contentItems[i].orderContent.replyStatus != MENU_ORDER_REPLY_STATUS_ACCEPT {
                    continue
                }
                content = content + getItemString(index: i)
                content = content + "\n"
                tmpContent = getItemsContent(index: i)
                if !tmpContent.isEmpty {
                    self.orderMergedContent.append(contentsOf: tmpContent)
                }
            }
        } else {
            for i in 0...self.menuOrder.contentItems.count - 1 {
                if self.menuOrder.contentItems[i].orderContent.replyStatus != MENU_ORDER_REPLY_STATUS_ACCEPT {
                    continue
                }
                if self.menuOrder.contentItems[i].orderContent.location != self.menuOrder.locations![self.segmentOption.selectedSegmentIndex] {
                    continue
                }
                
                content = content + getItemString(index: i)
                tmpContent = getItemsContent(index: i)
                if !tmpContent.isEmpty {
                    self.orderMergedContent.append(contentsOf: tmpContent)
                }

            }
        }
        self.contentString = content
        
        convertNormalReportData()
        prepareLayoutItems()
        refreshCollectionReport()
    }

    func generateMergedContentString() {
        var mergedContent: [MergedContent] = [MergedContent]()
        
        var tmp: MergedContent = MergedContent()

        self.orderMergedContent.removeAll()

        if self.menuOrder.contentItems.isEmpty {
            return
        }

        for i in 0...self.menuOrder.contentItems.count - 1 {
            if self.menuOrder.contentItems[i].orderContent.replyStatus != MENU_ORDER_REPLY_STATUS_ACCEPT {
                continue
            }
            
            if self.menuOrder.contentItems[i].orderContent.menuProductItems != nil {
                for k in 0...self.menuOrder.contentItems[i].orderContent.menuProductItems!.count - 1 {
                    if mergedContent.isEmpty {
                        tmp.productName = self.menuOrder.contentItems[i].orderContent.menuProductItems![k].itemName
                        tmp.mergedRecipe = getMergedItemRecipe(index: i, product_index: k)
                        tmp.comments = self.menuOrder.contentItems[i].orderContent.menuProductItems![k].itemComments
                        tmp.quantity = self.menuOrder.contentItems[i].orderContent.menuProductItems![k].itemQuantity
                        tmp.location = self.menuOrder.contentItems[i].orderContent.location
                        mergedContent.append(tmp)
                    } else {
                        var isFound: Bool = false
                        for j in 0...mergedContent.count - 1 {
                            if mergedContent[j].productName == self.menuOrder.contentItems[i].orderContent.menuProductItems![k].itemName  && mergedContent[j].mergedRecipe == getMergedItemRecipe(index: i, product_index: k) && mergedContent[j].location == self.menuOrder.contentItems[i].orderContent.location && mergedContent[j].comments == self.menuOrder.contentItems[i].orderContent.menuProductItems![k].itemComments {
                                mergedContent[j].quantity = mergedContent[j].quantity + self.menuOrder.contentItems[i].orderContent.menuProductItems![k].itemQuantity
                                isFound = true
                                break
                            }
                        }
                        
                        if !isFound {
                            tmp.productName = self.menuOrder.contentItems[i].orderContent.menuProductItems![k].itemName
                            tmp.comments = self.menuOrder.contentItems[i].orderContent.menuProductItems![k].itemComments
                            tmp.mergedRecipe = getMergedItemRecipe(index: i, product_index: k)
                            tmp.quantity = self.menuOrder.contentItems[i].orderContent.menuProductItems![k].itemQuantity
                            tmp.location = self.menuOrder.contentItems[i].orderContent.location
                            mergedContent.append(tmp)
                        }
                    }
                }
            }
        }

        self.orderMergedContent = mergedContent
        
        if self.isNoLocations {
            if !mergedContent.isEmpty {
                var content: String = ""
                for i in 0...mergedContent.count - 1 {
                    if i != 0 {
                        content = content + "\n"
                    }
                    
                    content = content + mergedContent[i].productName + "  "
                    content = content + mergedContent[i].mergedRecipe + " * " + String(mergedContent[i].quantity)
                    if mergedContent[i].comments != "" {
                        content = content + " (" + mergedContent[i].comments + ")"
                    }
                }
                self.contentString = content
            }
        } else {
            if !mergedContent.isEmpty {
                var content: String = ""
                let prefixString = "  "
                print("mergedContent = \(mergedContent)")
                for i in 0...self.menuOrder.locations!.count - 1 {
                    print("content = \(content)")
                    content = content + "--" + self.menuOrder.locations![i] + "\n"
                    var count: Int = 0
                    for j in 0...mergedContent.count - 1 {
                        if mergedContent[j].location != self.menuOrder.locations![i] {
                            continue
                        }
                        
                        if count != 0 {
                            content = content + "\n"
                        }
                        count = count + 1

                        content = content + mergedContent[j].productName + "  "
                        content = content + prefixString + mergedContent[j].mergedRecipe + " * " + String(mergedContent[j].quantity)
                        if mergedContent[j].comments != "" {
                            content = content + " (" + mergedContent[j].comments + ")"
                        }
                    }
                    content = content + "\n"
                }
                self.contentString = content
            }
        }
        
        convertMergedReportData()
        prepareLayoutItems()
        refreshCollectionReport()
    }

    func prepareLayoutItems() {
        self.layoutItemsArray.removeAll()

        if self.reportData.isEmpty {
            print("Report Data is empty, just return")
            return
        }
        
        // Verify raw data
        for i in 0...self.reportData.count - 1 {
            if self.reportData[i].numberOfColumns != self.reportData[i].columnHeaders.count {
                print("columnHeaders count is NOT sync with numberOfColumns")
                return
            }
            
            if !self.reportData[i].rawCellData.isEmpty {
                for j in 0...self.reportData[i].rawCellData.count - 1 {
                    if self.reportData[i].rawCellData[j].count != self.reportData[i].numberOfColumns {
                        print("rawCellData count is NOT sync with numberOfColumns")
                        return
                    }
                }
            }
        }
        
        var itemIndex: Int = 0
        var rowIndex: Int = 0
        for i in 0...self.reportData.count - 1 {
            var tmpData: [[String]] = [[String]]()
            tmpData = self.reportData[i].rawCellData.sorted(by: {$0[0] < $1[0]})
            print("self.report.rawCellData = \(self.reportData[i].rawCellData)")
            print("sroted self.report.rawCellData = \(tmpData)")
            self.reportData[i].rawCellData = tmpData
            
            //var tmpLayoutItemArray: [ReportLayoutStruct] = [ReportLayoutStruct]()
            var tmpLayoutItem: ReportLayoutStruct = ReportLayoutStruct()
            if self.reportData.count != 1 {
                tmpLayoutItem.type = REPORT_LAYOUT_TYPE_SECTION_HEADER
                tmpLayoutItem.data = self.reportData[i].sectionTitle
                tmpLayoutItem.itemIndex = itemIndex
                tmpLayoutItem.sectionIndex = i
                tmpLayoutItem.columnIndex = 0
                tmpLayoutItem.rowIndex = rowIndex
                tmpLayoutItem.rowCount = 1
                var totalWidth: CGFloat = 0
                for x in 0...self.reportData[i].columnWidth.count - 1 {
                    totalWidth = totalWidth + self.reportData[i].columnWidth[x]
                }
                tmpLayoutItem.width = totalWidth
                
                itemIndex = itemIndex + 1
                rowIndex = rowIndex + 1
                self.layoutItemsArray.append(tmpLayoutItem)
            }
            
            for j in 0...self.reportData[i].numberOfColumns - 1 {
                tmpLayoutItem.type = REPORT_LAYOUT_TYPE_COLUMN_HEADER
                tmpLayoutItem.data = self.reportData[i].columnHeaders[j]
                tmpLayoutItem.itemIndex = itemIndex
                tmpLayoutItem.sectionIndex = i
                tmpLayoutItem.columnIndex = j
                tmpLayoutItem.rowIndex = rowIndex
                tmpLayoutItem.rowCount = 1
                tmpLayoutItem.width = self.reportData[i].columnWidth[j]
                itemIndex = itemIndex + 1
                layoutItemsArray.append(tmpLayoutItem)
            }
            rowIndex = rowIndex + 1
            
            //var currentFirstHeader: String = self.reportData[i].rawCellData[0][0]
            if self.reportData[i].rawCellData.isEmpty {
                continue
            }
            
            var currentFirstHeader: String = ""
            for k in 0...self.reportData[i].rawCellData.count - 1 {
                for m in 0...self.reportData[i].numberOfColumns - 1 {
                    if m == 0 {
                        if self.reportData[i].rawCellData[k][m] != currentFirstHeader {
                            currentFirstHeader = self.reportData[i].rawCellData[k][m]
                            tmpLayoutItem.type = REPORT_LAYOUT_TYPE_CELL
                            tmpLayoutItem.data = self.reportData[i].rawCellData[k][m]
                            tmpLayoutItem.itemIndex = itemIndex
                            tmpLayoutItem.sectionIndex = i
                            tmpLayoutItem.columnIndex = m
                            tmpLayoutItem.rowIndex = rowIndex
                            tmpLayoutItem.width = self.reportData[i].columnWidth[(m % self.reportData[i].numberOfColumns)]
                            var totalRowCount: Int = 0
                            for n in 0...self.reportData[i].rawCellData.count - 1 {
                                if self.reportData[i].rawCellData[n][0] == currentFirstHeader {
                                    totalRowCount = totalRowCount + 1
                                }
                            }
                            tmpLayoutItem.rowCount = totalRowCount
                            itemIndex = itemIndex + 1
                            layoutItemsArray.append(tmpLayoutItem)
                        } else {
                            continue
                        }
                    } else {
                        tmpLayoutItem.type = REPORT_LAYOUT_TYPE_CELL
                        tmpLayoutItem.data = self.reportData[i].rawCellData[k][m]
                        tmpLayoutItem.itemIndex = itemIndex
                        tmpLayoutItem.sectionIndex = i
                        tmpLayoutItem.columnIndex = m
                        tmpLayoutItem.rowIndex = rowIndex
                        tmpLayoutItem.rowCount = 1
                        tmpLayoutItem.width = self.reportData[i].columnWidth[(m % self.reportData[i].numberOfColumns)]
                        itemIndex = itemIndex + 1
                        layoutItemsArray.append(tmpLayoutItem)
                    }
                }
                rowIndex = rowIndex + 1
            }
            //self.layoutItemsArray.append(tmpLayoutItemArray)
        }
        print("prepareLayoutItems break point")
    }

    func convertNormalReportData() {
        self.reportData.removeAll()
        if self.orderMergedContent.isEmpty {
            print("No information for self.orderMergedContent, just return")
            return
        }

        var tmpReportData: ReportDataStruct = ReportDataStruct()
        tmpReportData.numberOfColumns = 5
        tmpReportData.columnHeaders = ["參與者", "產品", "配方內容", "數量", "備註"]
        tmpReportData.columnWidth = [100.0, 80.0, 160.0, 40.0, 160.0]
        self.contentWidth = tmpReportData.columnWidth.reduce(0, { $0 + $1 })
        print("self.contentWidth = \(self.contentWidth)")

        for i in 0...self.orderMergedContent.count - 1 {
            var dataArray: [String] = [String]()
            dataArray.append(self.orderMergedContent[i].owner)
            dataArray.append(self.orderMergedContent[i].productName)
            dataArray.append(self.orderMergedContent[i].mergedRecipe)
            dataArray.append(String(self.orderMergedContent[i].quantity))
            dataArray.append(self.orderMergedContent[i].comments)
            tmpReportData.rawCellData.append(dataArray)
        }
        self.reportData.append(tmpReportData)
    }
    
    func convertMergedReportData() {
        if self.orderMergedContent.isEmpty {
            print("No information for self.orderMergedContent, just return")
            return
        }
        
        self.reportData.removeAll()
        if self.menuOrder.locations == nil {
            var tmpReportData: ReportDataStruct = ReportDataStruct()
            tmpReportData.numberOfColumns = 4
            tmpReportData.columnHeaders = ["產品", "配方內容", "數量", "備註"]
            tmpReportData.columnWidth = [80.0, 160.0, 40.0, 160.0]
            self.contentWidth = tmpReportData.columnWidth.reduce(0, { $0 + $1 })
            print("self.contentWidth = \(self.contentWidth)")

            for i in 0...self.orderMergedContent.count - 1 {
                var dataArray: [String] = [String]()
                dataArray.append(self.orderMergedContent[i].productName)
                dataArray.append(self.orderMergedContent[i].mergedRecipe)
                dataArray.append(String(self.orderMergedContent[i].quantity))
                dataArray.append(self.orderMergedContent[i].comments)
                tmpReportData.rawCellData.append(dataArray)
            }
            self.reportData.append(tmpReportData)
        } else {
            for i in 0...self.menuOrder.locations!.count - 1 {
                var tmpReportData: ReportDataStruct = ReportDataStruct()
                tmpReportData.numberOfColumns = 4
                tmpReportData.columnHeaders = ["產品", "配方內容", "數量", "備註"]
                tmpReportData.columnWidth = [80.0, 160.0, 40.0, 160.0]
                tmpReportData.sectionTitle = self.menuOrder.locations![i]
                for j in 0...self.orderMergedContent.count - 1 {
                    if self.orderMergedContent[j].location == self.menuOrder.locations![i] {
                        var dataArray: [String] = [String]()
                        dataArray.append(self.orderMergedContent[j].productName)
                        dataArray.append(self.orderMergedContent[j].mergedRecipe)
                        dataArray.append(String(self.orderMergedContent[j].quantity))
                        dataArray.append(self.orderMergedContent[j].comments)
                        tmpReportData.rawCellData.append(dataArray)
                    }
                }
                self.reportData.append(tmpReportData)
            }
        }
    }

}

extension MenuOrderNotebookViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if self.reportData.isEmpty {
            return 0
        } else {
            return 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.reportData.isEmpty {
            return 0
        } else {
            return self.layoutItemsArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReportCell", for: indexPath) as! ReportCell

        cell.setData(title: self.layoutItemsArray[indexPath.row].data)
        
        switch self.layoutItemsArray[indexPath.row].type {
            case REPORT_LAYOUT_TYPE_SECTION_HEADER:
                cell.setSectionHeaderStyle()
                break
            
            case REPORT_LAYOUT_TYPE_COLUMN_HEADER:
                cell.setColumnHeaderStyle()
                break
                
            default:
                break
        }
        
        cell.tag = indexPath.row
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor.black.cgColor
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ReportCell
        let direction = PopTipDirection.up

        let popTip = PopTip()
        popTip.font = UIFont(name: "Avenir-Medium", size: 15)!
        popTip.shouldDismissOnTap = true
        popTip.shouldDismissOnTapOutside = true
        popTip.shouldDismissOnSwipeOutside = true
        popTip.edgeMargin = 5
        popTip.offset = 2
        popTip.bubbleOffset = 0
        popTip.edgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        popTip.arrowRadius = 1
        popTip.bubbleColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)

        //popTip.bubbleColor = UIColor(red: 0.31, green: 0.57, blue: 0.87, alpha: 1)
        popTip.show(text: self.layoutItemsArray[indexPath.row].data, direction: direction, maxWidth: 200, in: self.collectionReport, from: cell.frame)
    }
}
