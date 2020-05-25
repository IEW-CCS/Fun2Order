//
//  MenuImageDescriptionTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/5/21.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

protocol MenuImageDescriptionDelegate: class {
    func getMenuImageDescription(sender: MenuImageDescriptionTableViewController, menu_images: [UIImage], menu_description: String)
}

class MenuImageDescriptionTableViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet weak var buttonAddImage: UIButton!
    @IBOutlet weak var imagePagerView: FSPagerView!
    @IBOutlet weak var imagePagerControl: FSPageControl!
    @IBOutlet weak var textViewDescription: UITextView!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var buttonConfirm: UIButton!
    
    var isDisplayMode: Bool = false
    var imageArray: [UIImage] = [UIImage]()
    var menuDescription: String = ""
    var selectedIndex: Int = 0
    var currentIndex: Int = 0
    weak var delegate: MenuImageDescriptionDelegate?

    fileprivate let transformerNames = ["cross fading", "zoom out", "depth", "linear", "overlap", "ferris wheel", "inverted ferris wheel", "coverflow", "cubic"]
    fileprivate let transformerTypes: [FSPagerViewTransformerType] = [.crossFading,
        .zoomOut, .depth, .linear, .overlap, .ferrisWheel, .invertedFerrisWheel, .coverFlow, .cubic]
    
    fileprivate var typeIndex = 0 {
        didSet {
            let type = self.transformerTypes[typeIndex]
            self.imagePagerView.transformer = FSPagerViewTransformer(type:type)
            switch type {
            case .crossFading, .zoomOut, .depth:
                self.imagePagerView.itemSize = FSPagerView.automaticSize
                self.imagePagerView.decelerationDistance = 1
            case .linear, .overlap:
                let transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                self.imagePagerView.itemSize = self.imagePagerView.frame.size.applying(transform)
                self.imagePagerView.decelerationDistance = FSPagerView.automaticDistance
            case .ferrisWheel, .invertedFerrisWheel:
                self.imagePagerView.itemSize = CGSize(width: 180, height: 140)
                self.imagePagerView.decelerationDistance = FSPagerView.automaticDistance
            case .coverFlow:
                self.imagePagerView.itemSize = CGSize(width: 220, height: 170)
                self.imagePagerView.decelerationDistance = FSPagerView.automaticDistance
            case .cubic:
                let transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.imagePagerView.itemSize = self.imagePagerView.frame.size.applying(transform)
                self.imagePagerView.decelerationDistance = 1
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textViewDescription.layer.borderWidth = 1.0
        self.textViewDescription.layer.borderColor = UIColor.darkGray.cgColor
        self.textViewDescription.layer.cornerRadius = 6

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)

        setupPageView()
        refreshInformation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let index = self.typeIndex
        self.typeIndex = index // Manually trigger didSet
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          textField.resignFirstResponder()
          return true
    }
    
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }

    private func setupPageView() {
        //self.imageArray.removeAll()
        self.imagePagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "PageViewCell")
        //self.imagePagerView.automaticSlidingInterval = 3.0
        self.imagePagerView.isInfinite = false
        self.imagePagerView.delegate = self
        self.imagePagerView.dataSource = self
        self.imagePagerControl.numberOfPages = self.imageArray.count
        self.imagePagerControl.contentHorizontalAlignment = .center
        self.imagePagerControl.contentInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        self.typeIndex = 4
    }

    func refreshInformation() {
        if self.isDisplayMode {
            self.buttonAddImage.isEnabled = false
            self.buttonAddImage.isHidden = true
            self.buttonCancel.isEnabled = false
            self.buttonCancel.isHidden = true
            self.buttonConfirm.isEnabled = false
            self.buttonConfirm.isHidden = true
            self.textViewDescription.isEditable = false
            self.textViewDescription.isSelectable = false
            self.textViewDescription.isUserInteractionEnabled = false
            self.textViewDescription.isMultipleTouchEnabled = false
        } else {
            self.buttonAddImage.isEnabled = true
            self.buttonAddImage.isHidden = false
            self.buttonCancel.isEnabled = true
            self.buttonCancel.isHidden = false
            self.buttonConfirm.isEnabled = true
            self.buttonConfirm.isHidden = false
            self.textViewDescription.isEditable = true
            self.textViewDescription.isSelectable = true
            self.textViewDescription.isUserInteractionEnabled = true
            self.textViewDescription.isMultipleTouchEnabled = true
        }
        
        self.textViewDescription.text = self.menuDescription
        self.currentIndex = 0
        
        if !self.imageArray.isEmpty {
            if self.imageArray.count >= 3 {
                self.buttonAddImage.isEnabled = false
            } else {
                self.buttonAddImage.isEnabled = true
            }
        }
        
        self.imagePagerView.reloadData()
    }
    
    @IBAction func addMenuImage(_ sender: UIButton) {
        let controller = UIAlertController(title: "選取照片來源", message: nil, preferredStyle: .actionSheet)
        
        let photoAction = UIAlertAction(title: "相簿", style: .default) { (_) in
            // Add code to pick a photo from Album
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .photoLibrary
                //imagePicker.allowsEditing = true
                imagePicker.delegate = self
                
                self.show(imagePicker, sender: self)
            }
        }
        
        photoAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        controller.addAction(photoAction)
        
        let cameraAction = UIAlertAction(title: "相機", style: .default) { (_) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .camera
                //imagePicker.allowsEditing = true
                imagePicker.delegate = self
                
                self.show(imagePicker, sender: self)
            }
        }
        
        cameraAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        controller.addAction(cameraAction)
        
        let cancelAction = UIAlertAction(title: "取消", style: .default) { (_) in
           print("Cancel update")
        }
        cancelAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        controller.addAction(cancelAction)
        
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func confirmAction(_ sender: UIButton) {
        self.menuDescription = textViewDescription.text
        self.delegate?.getMenuImageDescription(sender: self, menu_images: self.imageArray, menu_description: self.textViewDescription.text)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func menuImageClicked(_ sender: UITapGestureRecognizer) {
        //print("Menu Image tapped")

        //let zoomView = ImageZoomView(frame: UIScreen.main.bounds, image: self.imageArray[self.currentIndex])
        let zoomView = ImageZoomView(frame: self.view.frame, image: self.imageArray[self.currentIndex])
        zoomView.bounces = false
        //let zoomView = ImageZoomView(frame: self.view.bounds, image: imageView.image!)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        tap.cancelsTouchesInView = false
        zoomView.addGestureRecognizer(tap)
        self.view.addSubview(zoomView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true

    }
    
    @objc func menuImageLongPressed(_ sender: UILongPressGestureRecognizer) {
        if(sender.state == .began) {
            //presentSimpleAlertMessage(title: "測試訊息", message: "Image[\(self.currentIndex)] is long-pressed!")
            let controller = UIAlertController(title: "編輯照片選項", message: nil, preferredStyle: .actionSheet)
            
            let deleteAction = UIAlertAction(title: "刪除照片", style: .default) { (_) in
                print("Delete MenuImage[\(self.currentIndex)]")
                let alertController = UIAlertController(title: "刪除照片", message: "確定要刪除此照片嗎？", preferredStyle: .alert)

                let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
                    print("Confirm to delete this menu image")
                    
                    self.imageArray.remove(at: self.currentIndex)
                    self.currentIndex = 0
                    self.imagePagerView.scrollToItem(at: self.currentIndex, animated: true)
                    self.refreshInformation()
                }
                
                alertController.addAction(okAction)
                let cancelDeleteAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                alertController.addAction(cancelDeleteAction)
                self.present(alertController, animated: true, completion: nil)
            }
            
            deleteAction.setValue(UIColor.red, forKey: "titleTextColor")
            controller.addAction(deleteAction)
            
            let cancelAction = UIAlertAction(title: "取消", style: .default) { (_) in
               print("Cancel update")
            }
            cancelAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
            controller.addAction(cancelAction)
            
            present(controller, animated: true, completion: nil)
        }
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }

}

extension MenuImageDescriptionTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        self.imageArray.append(image)
        
        if self.imageArray.count == 3 {
            self.buttonAddImage.isEnabled = false
        } else {
            self.buttonAddImage.isEnabled = true
        }
        self.imagePagerView.reloadData()
        dismiss(animated: true, completion: nil)
    }
}

extension MenuImageDescriptionTableViewController: FSPagerViewDataSource, FSPagerViewDelegate {
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        if self.imageArray.isEmpty {
            return 0
        } else {
            self.imagePagerControl.numberOfPages = self.imageArray.count
            self.imagePagerControl.currentPage = self.currentIndex
            return self.imageArray.count
        }
    }
    
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        if !self.imageArray.isEmpty {
            let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "PageViewCell", at: index)
            cell.imageView?.image = self.imageArray[index]
            cell.imageView?.contentMode = .scaleAspectFit
            cell.imageView?.clipsToBounds = true

            let tapGesture = UITapGestureRecognizer(target: self, action:#selector(self.menuImageClicked(_:)))
            cell.addGestureRecognizer(tapGesture)

            if !self.isDisplayMode {
                let longPressedGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.menuImageLongPressed(_:)))
                cell.addGestureRecognizer(longPressedGesture)
            }

            cell.isUserInteractionEnabled = true

            return cell
        }
        return FSPagerViewCell()
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        self.imagePagerView.deselectItem(at: index, animated: true)
        self.imagePagerView.scrollToItem(at: index, animated: true)
        
        print("Image [\(index)] is selected")
        self.selectedIndex = index
    }

    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        self.imagePagerControl.currentPage = targetIndex
        self.currentIndex = targetIndex
    }
    
    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        self.imagePagerControl.currentPage = pagerView.currentIndex
        self.currentIndex = pagerView.currentIndex
    }

}
