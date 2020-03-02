//
//  AddFriendViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/2/28.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

protocol AddFriendDelegate: class {
    func confirmToAddFriend(sender: AddFriendViewController)
}

class AddFriendViewController: UIViewController {
    @IBOutlet weak var labelUserID: UILabel!
    
    weak var delegate: AddFriendDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func setData(user_id: String) {
        self.labelUserID.text = user_id
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmToAddFriend(_ sender: UIButton) {
        delegate?.confirmToAddFriend(sender: self)
        dismiss(animated: true, completion: nil)
    }

}
