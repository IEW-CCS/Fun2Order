//
//  SelectMenuRecipeTemplateCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/13.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import Firebase

protocol SelectMenuRecipeTemplateCellDelegate: class {
    func queryMenuRecipeTemplateData(cell: UITableViewCell)
    func saveMenuRecipeTemplate(cell: UITableViewCell)
    func addNewRecipeCategory(cell: UITableViewCell)
}

class SelectMenuRecipeTemplateCell: UITableViewCell {
    @IBOutlet weak var buttonSelectTemplate: UIButton!
    //@IBOutlet weak var labelTemplateName: UILabel!
    weak var delegate: SelectMenuRecipeTemplateCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //self.labelTemplateName.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func queryTemplateData(_ sender: UIButton) {
        //NotificationCenter.default.post(name: NSNotification.Name("QueryTemplate"), object: nil)
        delegate?.queryMenuRecipeTemplateData(cell: self)
    }
    
    @IBAction func addNewCategory(_ sender: UIButton) {
        delegate?.addNewRecipeCategory(cell: self)
    }
    
    @IBAction func saveTemplate(_ sender: UIButton) {
        delegate?.saveMenuRecipeTemplate(cell: self)
    }
    
    func setData(template_name: String) {
        //self.labelTemplateName.text = template_name
    }
}
