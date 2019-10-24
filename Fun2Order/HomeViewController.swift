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
    
    let imageNames = ["1.png","2.png","3.png","4.png","5.png","6.png","7.png", "8.png"]
    let imageTitles = ["嵐山", "車折神社", "清水寺", "直指庵", "圓光寺", "高台寺", "北野天滿宮", "高雄神護寺"]
    let imageDescription = [
        "京都的「嵐山」是無人不知無人不曉的日本代表性賞楓名所。既是國家級史蹟，又是國家指定名勝景點的「嵐山」，其楓紅時期的景致宛如一幅絕美的畫作。非常推薦大家搭乘超有人氣的「嵯峨野遊覽小火車」，從各種角度來賞楓!",
        "擁有大國主神社、弁天神社、藝能神社等3間境內神社的「車折神社」，是相當有名的藝人神社，來此參拜的藝人絡繹不絕。此外，神社周圍寫滿一整面藝人姓名的木柵欄也相當有名。這間「車折神社」不但四季的美景獲得好評，更是許多人會前來造訪的賞楓景點!",
        "提到京都觀光景點絕對少不了「清水寺」的紅葉，能從樹木上方眺望，感受不同於以往的觀賞樂趣。此外，於11月中旬~12月初會舉行「秋季夜間特別參拜」，夜晚打上燈光的紅葉可說是絶景，相當有值得一看的價值!",
        "京都的私房賞楓景點「直指庵」為淨土宗的寺院，不但觀賞期間較長，被寂靜所包圍的景觀也充滿著浪漫的氛圍。「直指庵」內有一尊「愛逢地藏」像，因此也是相當有人氣的祈求良緣景點!",
        "「圓光寺」是臨濟宗南禪寺派的寺院。能在寺院內的池泉回遊式庭園「十牛之庭」與枯山水式庭園「奔龍庭」欣賞秋季的楓紅，對比鮮明的繽紛色彩非常美麗，因此獲得好評。樹葉從11 月中旬開始變色，11月下旬則進入觀賞的最佳時期。",
        "距離「八坂神社」不遠處有一個有名的賞楓地點「高台寺」，每年總會吸引大批遊客前來造訪。此處的池泉回遊式庭園據說是由豐臣秀吉之妻「寧寧」所建造的，每到紅葉變色的季節，美麗的庭園與「高台寺」相互輝映，形成饒富逸趣的景致。",
        "以「春梅名所」而聞名的「北野天滿宮」，近年期間限定開放參觀的「史跡御土居的紅葉苑」成為最受矚目的新賞楓景點。約250棵楓樹在夜晚打上燈光後的景色可以說是觀賞重點!11月下旬〜12月上旬為最佳觀賞期，觀光客絡繹不絕相當熱鬧!",
        "京都郊區的踏青地點「高雄神護寺」一帶，與梅畑槙尾町的「西明寺」、梅畑栂尾町的「高山寺」並稱「三尾」，是自古以來便為人所知的紅葉名所。特別是人氣紅葉名所「高雄神護寺」內的五大堂被紅葉所包圍的景 觀更是必看重點，夜晚點燈後更顯絕美!"]
    
    
    
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
    @IBOutlet weak var tableView: UITableView!
    
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
        cell.textLabel?.text = self.imageTitles[index]
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
        
        print("Image [\(index)] is selected")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "Banner_VC") as? BannerDetailViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: pickerStoryboard can't find!! (ViewController)")
            return
        }

        let img = UIImage(named: self.imageNames[index])!
        vc.modalTransitionStyle = .flipHorizontal
        vc.modalPresentationStyle = .overCurrentContext
        navigationController?.present(vc, animated: true, completion: nil)
        vc.setData(image_name: img, image_description: self.imageDescription[index])
    }
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        self.pageControl.currentPage = targetIndex
    }
    
    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        self.pageControl.currentPage = pagerView.currentIndex
    }

}
/*
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductBriefCell", for: indexPath) as! ProductBriefCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}
*/
