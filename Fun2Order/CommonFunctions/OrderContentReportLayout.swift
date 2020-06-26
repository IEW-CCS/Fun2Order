//
//  OrderContentReportLayout.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/4/20.
//  Copyright © 2020 JStudio. All rights reserved.
//

import Foundation
import UIKit


class OrderContentReportLayout: UICollectionViewLayout {
    private var layoutItemsArray: [ReportLayoutStruct] = [ReportLayoutStruct]()
    private let cellHeight: CGFloat = 36
    private let cellPadding: CGFloat = 5
    private var cache: [UICollectionViewLayoutAttributes] = []
    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat = 0
    private var columnsWidth: [CGFloat] = [CGFloat]()
    private var calculatedXOffset: [CGFloat] = [CGFloat]()
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: self.contentWidth, height: self.contentHeight)
    }
    
    override func prepare() {
        guard cache.isEmpty, let collectionView = collectionView else {
            return
        }

        if self.layoutItemsArray.isEmpty {
            print("self.layoutItemsArray is empty, return error")
            return
        }

        //let totalItems = collectionView.numberOfItems(inSection: 0)
        //print("Total number of items for UICollectionView is [\(totalItems)]")

        var xOffset: CGFloat = 0
        //var firstColumnWidth: CGFloat = 0
        for i in 0...self.layoutItemsArray.count - 1 {
            var yOffset: CGFloat = 0
            var width: CGFloat = 0
            var height: CGFloat = 0
            
            let indexPath = IndexPath(item: self.layoutItemsArray[i].itemIndex, section: 0)
            if self.layoutItemsArray[i].type == REPORT_LAYOUT_TYPE_SECTION_HEADER {
                xOffset = 0
                yOffset = CGFloat(self.layoutItemsArray[i].rowIndex) * self.cellHeight
                width = self.layoutItemsArray[i].width
                height = CGFloat(self.layoutItemsArray[i].rowCount) * self.cellHeight
                self.contentWidth = max(self.contentWidth, self.layoutItemsArray[i].width)
            } else {
                if self.columnsWidth.isEmpty {
                    continue
                }
                xOffset = self.calculatedXOffset[self.layoutItemsArray[i].columnIndex]
/*
                if self.layoutItemsArray[i].columnIndex == 0 {
                    xOffset = 0
                    //firstColumnWidth = self.layoutItemsArray[i].width
                } else if self.layoutItemsArray[i].columnIndex == 1 {
                    //xOffset = firstColumnWidth
                    xOffset = self.columnsWidth[0]
                } else {
                    //xOffset = xOffset + self.layoutItemsArray[i - 1].width
                    for j in 2...self.layoutItemsArray[i].columnIndex - 1 {
                        xOffset = xOffset + self.columnsWidth[j]
                    }
                }
*/
                yOffset = CGFloat(self.layoutItemsArray[i].rowIndex) * self.cellHeight
                width = self.layoutItemsArray[i].width
                height = CGFloat(self.layoutItemsArray[i].rowCount) * self.cellHeight
            }

            let frame = CGRect(x: xOffset, y: yOffset, width: width, height: height)
            self.contentHeight = max(self.contentHeight, frame.maxY)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            
            if self.layoutItemsArray[i].columnIndex == 0 {
                attributes.zIndex = 3
            } else {
                attributes.zIndex = 2
            }

            if self.layoutItemsArray[i].columnIndex == 0 && self.layoutItemsArray[i].type != REPORT_LAYOUT_TYPE_SECTION_HEADER{
                var stickyFrame = attributes.frame
                
                stickyFrame.origin.x = collectionView.contentOffset.x
                attributes.frame = stickyFrame.integral
            }

            self.cache.append(attributes)
        }

    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributesArray = [UICollectionViewLayoutAttributes]()
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                attributesArray.append(attributes)
            }
        }
        
        return attributesArray
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.cache[indexPath.item]
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        
        self.cache.removeAll()
    }

    func setLayoutItems(items: [ReportLayoutStruct]) {
        self.layoutItemsArray.removeAll()
        self.layoutItemsArray = items
        self.cache.removeAll()
    }
    
    func setColumnsWidth(widths: [CGFloat]) {
        self.columnsWidth = widths
        self.calculatedXOffset.removeAll()
        if !self.columnsWidth.isEmpty {
            self.calculatedXOffset.append(0.0)
            self.calculatedXOffset.append(self.columnsWidth[0])
            for i in 2...self.columnsWidth.count - 1 {
                self.calculatedXOffset.append(self.calculatedXOffset[i - 1] + self.columnsWidth[i - 1])
            }
            print("self.columnsWidth = \(self.columnsWidth)")
            print("self.calculatedXOffset = \(self.calculatedXOffset)")
        }
    }
    
    func setContentWidth(width: CGFloat) {
        self.contentWidth = width
    }
}

