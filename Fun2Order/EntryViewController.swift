//
//  EntryViewController.swift
//  Fun2Order
//
//  Created by chris on 2019/10/17.
//  Copyright © 2019 JStudio. All rights reserved.
//

import Foundation

import UIKit

import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseFirestore


class EntryViewController: UIViewController {

    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        do {
            try Auth.auth().signOut()
           
        } catch {
            
        }*/
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        if(Auth.auth().currentUser?.uid != nil)
        {
            //print(Auth.auth().currentUser?.phoneNumber)
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HomeTabBar") as! UITabBarController
            navigationController?.pushViewController(nextViewController, animated: true)
        }
        
    }

    
    @IBAction func guest(_ sender: Any) {
        
         let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
         let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HomeTabBar") as! UITabBarController
         navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    
    @IBAction func authentication(_ sender: Any) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "VerifyPhNoController") as! VerifyPhNoController
        navigationController?.pushViewController(nextViewController, animated: true)
        
        
    }
}
