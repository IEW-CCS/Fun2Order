//
//  BrandListCollectionViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/14.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class BrandListCollectionViewController: UICollectionViewController {

    let brandImages: [UIImage] = [
        UIImage(named: "上宇林@3x.jpg")!,
        UIImage(named: "丸作@3x.jpg")!,
        UIImage(named: "五十嵐@3x.png")!,
        UIImage(named: "公館手作@3x.jpg")!,
        UIImage(named: "迷克夏@3x.jpg")!,
        UIImage(named: "自在軒@3x.png")!,
        UIImage(named: "柚豆@3x.jpg")!,
        UIImage(named: "紅太陽@3x.png")!,
        UIImage(named: "茶湯會@3x.jpg")!,
        UIImage(named: "圓石@3x.jpg")!,
        UIImage(named: "Teas原味@3x.jpg")!]
    let brandTitles: [String] = ["上宇林", "丸作", "五十嵐", "公館手作", "迷克夏", "自在軒", "柚豆", "紅太陽", "茶湯會", "圓石", "Teas原味"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let cellViewNib: UINib = UINib(nibName: "BrandCollectionViewCell", bundle: nil)
        self.collectionView.register(cellViewNib, forCellWithReuseIdentifier: "BrandCollectionViewCell")
        //self.collectionView!.register(BrandCollectionViewCell.self, forCellWithReuseIdentifier: "BrandCollectionViewCell")
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 5
        collectionView.collectionViewLayout = layout
        self.tabBarController?.title = self.title
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.brandImages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BrandCollectionViewCell", for: indexPath) as! BrandCollectionViewCell
    
        cell.setData(text: self.brandTitles[indexPath.row], image: self.brandImages[indexPath.row])
        //cell.layer.borderColor = UIColor.black.cgColor
        //cell.layer.borderWidth = 1
        
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Select: \(self.brandTitles[indexPath.row])")
        NotificationCenter.default.post(name: NSNotification.Name("BrandInfo"), object: Int(indexPath.row))
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension BrandListCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90, height: 115)
    }
}
