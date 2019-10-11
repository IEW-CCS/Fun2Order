//
//  HomeViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/10.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, FSPagerViewDataSource, FSPagerViewDelegate {
    @IBOutlet weak var pageControl: FSPageControl!
    
    @IBOutlet weak var pagerView: FSPagerView!
    
    fileprivate let imageNames = ["1.jpg","2.jpg","3.jpg","4.jpg","5.jpg","6.jpg","7.jpg"]
    fileprivate let transformerNames = ["cross fading", "zoom out", "depth", "linear", "overlap", "ferris wheel", "inverted ferris wheel", "coverflow", "cubic"]
    fileprivate let transformerTypes: [FSPagerViewTransformerType] = [.crossFading,
                                                              .zoomOut,
                                                              .depth,
                                                              .linear,
                                                              .overlap,
                                                              .ferrisWheel,
                                                              .invertedFerrisWheel,
                                                              .coverFlow,
                                                              .cubic]
    
    fileprivate var typeIndex = 0 {
        didSet {
            let type = self.transformerTypes[typeIndex]
            self.pagerView.transformer = FSPagerViewTransformer(type:type)
            switch type {
            case .crossFading, .zoomOut, .depth:
                self.pagerView.itemSize = FSPagerView.automaticSize
                self.pagerView.decelerationDistance = 1
            case .linear, .overlap:
                let transform = CGAffineTransform(scaleX: 0.6, y: 0.75)
                self.pagerView.itemSize = self.pagerView.frame.size.applying(transform)
                self.pagerView.decelerationDistance = FSPagerView.automaticDistance
            case .ferrisWheel, .invertedFerrisWheel:
                self.pagerView.itemSize = CGSize(width: 180, height: 140)
                self.pagerView.decelerationDistance = FSPagerView.automaticDistance
            case .coverFlow:
                self.pagerView.itemSize = CGSize(width: 220, height: 170)
                self.pagerView.decelerationDistance = FSPagerView.automaticDistance
            case .cubic:
                let transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.pagerView.itemSize = self.pagerView.frame.size.applying(transform)
                self.pagerView.decelerationDistance = 1
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageView()
    }
    
    private func setupPageView() {
        self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "PageViewCell")
        self.pagerView.automaticSlidingInterval = 3.0
        self.pagerView.isInfinite = true
        self.pagerView.delegate = self
        self.pagerView.dataSource = self
        self.pageControl.numberOfPages = self.imageNames.count
        self.pageControl.contentHorizontalAlignment = .center
        self.pageControl.contentInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        self.typeIndex = 8
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let index = self.typeIndex
        self.typeIndex = index // Manually trigger didSet
    }

    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return imageNames.count
    }
    
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "PageViewCell", at: index)
        cell.imageView?.image = UIImage(named: self.imageNames[index])
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
    }
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        self.pageControl.currentPage = targetIndex
    }
    
    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        self.pageControl.currentPage = pagerView.currentIndex
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
