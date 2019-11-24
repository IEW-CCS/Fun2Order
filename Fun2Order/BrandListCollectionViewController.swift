//
//  BrandListCollectionViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/14.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit
import CoreData

class BrandListCollectionViewController: UICollectionViewController {

    var brandImages = [UIImage]()
    var brandTitles = [String]()
    var brandIDs = [Int]()
    
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let cellViewNib: UINib = UINib(nibName: "BrandCollectionViewCell", bundle: nil)
        self.collectionView.register(cellViewNib, forCellWithReuseIdentifier: "BrandCollectionViewCell")
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 5
        collectionView.collectionViewLayout = layout
        self.tabBarController?.title = self.title
        
        vc = app.persistentContainer.viewContext
        retrieveBrandProfiles()
    }

    func retrieveBrandProfiles() {
        let fetchSortRequest: NSFetchRequest<BRAND_PROFILE> = BRAND_PROFILE.fetchRequest()
        let sort = NSSortDescriptor(key: "brandID", ascending: true)
        fetchSortRequest.sortDescriptors = [sort]

        do {
            let profile_list = try vc.fetch(fetchSortRequest)
            for profile_data in profile_list {
                self.brandImages.append(UIImage(data: profile_data.brandIconImage!)!)
                self.brandTitles.append(profile_data.brandName!)
                self.brandIDs.append(Int(profile_data.brandID))
            }
        } catch {
            print(error.localizedDescription)
            let httpAlert = alert(message: error.localizedDescription, title: "Retrieve Brand Profile from CoreData Error")
            self.present(httpAlert, animated : false, completion : nil)
            return
        }
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
        
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected Brand ID: \(self.brandIDs[indexPath.row])")
        //NotificationCenter.default.post(name: NSNotification.Name("BrandInfo"), object: Int(indexPath.row))
        updateSelectedBrandID(brand_id: self.brandIDs[indexPath.row])
        NotificationCenter.default.post(name: NSNotification.Name("BrandInfo"), object: self.brandIDs[indexPath.row])
        dismiss(animated: true, completion: nil)
    }
    
}

extension BrandListCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 125)
    }
}
