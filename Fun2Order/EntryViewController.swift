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
            
        }
*/
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        if(Auth.auth().currentUser?.uid != nil)
        {
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
