//
//  ViewController.swift
//  InfiniteScrollView
//
//  Created by garazha on 4/22/15.
//  Copyright (c) 2015 Sergey Garazha. All rights reserved.
//

import UIKit

class ViewController: UIViewController, InfiniteScrollViewDelegate {
    
    @IBOutlet weak var infiniteScrollView: InfiniteScrollViewWithPageControll!
    var images = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 1...7 {
            let image = UIImage(named: "\(i).jpg")
            images.append(image!)
        }
        
        infiniteScrollView.dataSource = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        infiniteScrollView.showCenterContainer()
        
        infiniteScrollView.startAutoscroll()
    }
    
    // MARK: - InfiniteScrollViewDelegate
    
    func imageForContainer(index: Int)->UIImage {
        return images[currentIndex(index)]
    }
    
    func numberOfPages()->Int {
        return images.count
    }
    
    func currentIndex(index: Int) -> Int {
        var i = index % images.count
        i = i < 0 ? images.count + i : i
        return i
    }
    
}

