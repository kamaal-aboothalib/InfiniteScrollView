//
//  ViewController.swift
//  InfiniteScrollView
//
//  Created by garazha on 4/22/15.
//  Copyright (c) 2015 Sergey Garazha. All rights reserved.
//

import UIKit

class SimpleViewController: UIViewController {
    
    @IBOutlet weak var infiniteScrollView: InfiniteScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        infiniteScrollView.items = images
    }
    
}

