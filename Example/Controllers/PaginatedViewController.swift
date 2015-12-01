//
//  PaginatedViewController.swift
//  InfiniteScrollView
//
//  Created by orlangur on 01.12.15.
//  Copyright © 2015 Sergey Garazha. All rights reserved.
//

import UIKit

class PaginatedViewController: UIViewController {

    @IBOutlet weak var isv: InfiniteScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isv.items = images
        isv.pagingEnabled = true
    }

}
