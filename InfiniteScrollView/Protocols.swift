//
//  InfiniteScrollView.swift
//  123
//
//  Created by garazha on 4/22/15.
//  Copyright (c) 2015 Sergey Garazha. All rights reserved.
//

import UIKit

protocol ContainerDelegate {
    func containerSelected(container: Container)
}

protocol InfiniteScrollViewDelegate {
    func imageForContainer(index: Int)->UIImage?
    func numberOfPages()->Int
    func currentIndex(index: Int)->Int
    func didSelectContainer(index: Int)
}

protocol PageControlDelegate {
    func updatePageControl()
}

