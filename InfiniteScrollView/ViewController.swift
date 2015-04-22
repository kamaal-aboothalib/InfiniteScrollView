//
//  ViewController.swift
//  InfiniteScrollView
//
//  Created by garazha on 4/22/15.
//  Copyright (c) 2015 Sergey Garazha. All rights reserved.
//

import UIKit

class ViewController: UIViewController, InfiniteScrollViewDelegate {
    
    @IBOutlet weak var infiniteScrollView: InfiniteScrollView!
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
    }
    
    // MARK: - InfiniteScrollViewDelegate
    
    func imageForContainer(index: Int)->UIImage {
        let i = abs(index) % images.count
        println("\(i)")
        return images[i]
    }
    
}

