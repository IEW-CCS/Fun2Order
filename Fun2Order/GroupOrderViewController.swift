//
//  GroupOrderViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/22.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class GroupOrderViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var groupCollectionView: UICollectionView!
    @IBOutlet weak var memberTableView: UITableView!
    
    let groupTitles: [String] = ["Group1", "Group2", "Group3", "Group4", "Group5", "Group6", "Group7"]
    let memberImages: [UIImage] = [UIImage(named: "Image_Friend1.png")!,
                                UIImage(named: "Image_Friend2.png")!,
                                UIImage(named: "Image_Friend3.png")!,
                                UIImage(named: "Image_Friend4.png")!,
                                UIImage(named: "Image_Friend5.png")!]
    let memberNames: [String] = ["熱帶魚", "河馬", "火雞", "青蛙弟", "章魚哥"]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.groupCollectionView.register(GroupCell.self, forCellWithReuseIdentifier: "GroupCell")

        let memberCellViewNib: UINib = UINib(nibName: "MemberCell", bundle: nil)
        self.memberTableView.register(memberCellViewNib, forCellReuseIdentifier: "MemberCell")

        let layout = groupCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 8
        groupCollectionView.collectionViewLayout = layout

        let gesTap = UITapGestureRecognizer(target: self, action:#selector(self.handleTapGesture(_:)))
        gesTap.delegate = self
        self.view.addGestureRecognizer(gesTap)

        self.tabBarController?.title = self.title

        self.groupCollectionView.delegate = self
        self.groupCollectionView.dataSource = self
        
        self.memberTableView.delegate = self
        self.memberTableView.dataSource = self
    }
    
    @objc private func handleTapGesture(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}

extension GroupOrderViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.groupTitles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupCell", for: indexPath) as! GroupCell
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1.5
        cell.layer.cornerRadius = 6

        //cell.setData(group: self.groupTitles[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Select: \(self.groupTitles[indexPath.row])")
        //NotificationCenter.default.post(name: NSNotification.Name("BrandInfo"), object: Int(indexPath.row))
        //dismiss(animated: true, completion: nil)
    }
}


extension GroupOrderViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 30)
    }
}


extension GroupOrderViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memberNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath) as! MemberCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.setData(image: self.memberImages[indexPath.row], name: self.memberNames[indexPath.row])
        return cell
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

