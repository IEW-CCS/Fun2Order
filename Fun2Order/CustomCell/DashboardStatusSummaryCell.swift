//
//  DashboardStatusSummaryCell.swift
//  TestCoreData
//
//  Created by Lo Fang Chou on 2019/9/21.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit
import Charts

class DashboardStatusSummaryCell: UITableViewCell {
    let chartLabelText = ["等待回覆", "已回覆", "不參加", "逾期未回覆"]
    
    @IBOutlet weak var pieChart: PieChartView!

    @IBOutlet weak var FrontShadow: ShadowGradientView!
    @IBOutlet weak var BackShadow: ShadowGradientView!
    @IBOutlet weak var MenuInfoShadow: ShadowGradientView!
    @IBOutlet weak var labelStartTime: UILabel!
    @IBOutlet weak var labelDueTime: UILabel!
    @IBOutlet weak var labelMemberCount: UILabel!
    @IBOutlet weak var labelBrandName: UILabel!
    
    //private var previousSelectedIndex:Int = 0
    //private var currentSelectedIndex: Int = 0
    //private var selectedSliceIndex: Int = -1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        self.contentView.layer.cornerRadius = CELL_CORNER_RADIUS
        self.contentView.layer.backgroundColor = UIColor.clear.cgColor

        //pieChart.delegate = self
        
        configPieChart()
        
        //if !categoryArray.isEmpty {
        //    normalizeData()
        //    setupChartData(cate_index: self.previousSelectedIndex)
        //}
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    public func AdjustAutoLayout()
    {
        BackShadow.AdjustAutoLayout()
        FrontShadow.AdjustAutoLayout()
        MenuInfoShadow.AdjustAutoLayout()
    }
    
    func configPieChart() {
        let l = self.pieChart.legend
        l.horizontalAlignment = .center
        l.verticalAlignment = .top
        l.orientation = .horizontal
        l.direction = .leftToRight
        l.xEntrySpace = 7
        l.yEntrySpace = 0
        l.yOffset = 0
        
        pieChart.entryLabelColor = .black
        pieChart.entryLabelFont = .systemFont(ofSize: 12, weight: .light)
        pieChart.animate(xAxisDuration: 1.0, easingOption: .easeOutBack)
        pieChart.drawHoleEnabled = true
        pieChart.holeColor = .clear
        pieChart.drawEntryLabelsEnabled = false
        pieChart.drawSlicesUnderHoleEnabled = false
        pieChart.holeRadiusPercent = 0.45

    }
    
    func setMenuInfo(brand: String, start_time: String, member_count: Int, due_time: String) {
        labelBrandName.text = brand
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = DATETIME_FORMATTER
        let startTimeData = timeFormatter.date(from: start_time)
        let dueTimeData = timeFormatter.date(from: due_time)
        
        let formatter = DateFormatter()
        formatter.dateFormat = TAIWAN_DATETIME_FORMATTER
        let startTimeString = formatter.string(from: startTimeData!)
        let dueTimeString = formatter.string(from: dueTimeData!)
        self.labelStartTime.text = startTimeString
        
        if due_time == "" {
            self.labelDueTime.text = "無逾期時間"
        } else {
            self.labelDueTime.text = dueTimeString
        }
        
        self.labelMemberCount.text = String(member_count)

    }
    
    func setupChartData(data_array: [Int]) {
        var dataEntries: [PieChartDataEntry] = []
        
        if data_array.isEmpty {
            return
        }
        
        for index in 0...data_array.count - 1 {
            let entry = PieChartDataEntry(value: Double(data_array[index]), label: self.chartLabelText[index])
            entry.data = Int()
            entry.data = index
            dataEntries.append(entry)
        }
        
        let set = PieChartDataSet(entries: dataEntries, label: "")
        //let set = PieChartDataSet(entries: dataEntries)
        set.drawIconsEnabled = false
        set.sliceSpace = 4

        set.colors = [SUMMARY_WAIT_COLOR, SUMMARY_ACCEPT_COLOR, SUMMARY_REJECT_COLOR, SUMMARY_EXPIRE_COLOR]
        let data = PieChartData(dataSet: set)
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .decimal
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        //pFormatter.percentSymbol = " %"
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        
        data.setValueFont(.systemFont(ofSize: 16, weight: .light))
        data.setValueTextColor(.black)
        
        pieChart.data = data
        pieChart.highlightValues(nil)
        pieChart.animate(xAxisDuration: 1.0, easingOption: .easeOutBack)
    }
    
    /*
     private func normalizeData() {
         var tmp = [Double]()
         var sum:Int = 0
         
         if !self.pieDataArray.isEmpty {
             for index in 0...self.pieDataArray.count - 1 {
                 tmp.removeAll()
                 sum = 0
                 for i in 0...self.pieDataArray[index].count - 1 {
                     sum += self.pieDataArray[index][i]
                 }
                 print("pieDataArray[\(index)] sum = \(sum)")
                 
                 for j in 0...self.pieDataArray[index].count - 1 {
                     tmp.append(Double(self.pieDataArray[index][j])/Double(sum))
                 }
                 self.normalizeArray.append(tmp)
             }
         }
     }
     */
}
