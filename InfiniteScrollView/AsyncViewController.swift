//
//  AsyncViewController.swift
//  InfiniteScrollView
//
//  Created by orlangur on 01.12.15.
//  Copyright © 2015 Sergey Garazha. All rights reserved.
//

import UIKit

class AsyncViewController: UIViewController {

    @IBOutlet weak var isv: InfiniteScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isv.items = images
    }

}
