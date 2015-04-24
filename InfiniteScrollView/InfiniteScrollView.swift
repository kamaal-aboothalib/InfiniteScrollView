//
//  InfiniteScrollView.swift
//  123
//
//  Created by garazha on 4/22/15.
//  Copyright (c) 2015 Sergey Garazha. All rights reserved.
//

import UIKit

class InfiniteScrollViewWithPageControll: UIView, UIScrollViewDelegate, QweDelegate {
    
    let infiniteScrollView = InfiniteScrollView(frame: CGRectZero)
    let pageControl = UIPageControl(frame: CGRectZero)
    var dataSource: InfiniteScrollViewDelegate? {
        didSet {
            infiniteScrollView.dataSource = dataSource
            reloadData()
        }
    }
    
    // MARK: -
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        baseConfiguration()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        baseConfiguration()
    }
    
    func baseConfiguration() {
        // scroll view
        infiniteScrollView.delegate = self
        infiniteScrollView.qwe = self
        addSubview(infiniteScrollView)
        infiniteScrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        addConstraints([NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: infiniteScrollView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0), NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: infiniteScrollView, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0), NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: infiniteScrollView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0), NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: infiniteScrollView, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0)])
        
        // page control
        pageControl.setTranslatesAutoresizingMaskIntoConstraints(false)
        pageControl.numberOfPages = 4
        pageControl.tintColor = UIColor.blackColor()
        pageControl.pageIndicatorTintColor = UIColor.darkGrayColor()
        pageControl.currentPageIndicatorTintColor = UIColor.lightGrayColor()
        addSubview(pageControl)
        pageControl.addConstraints([NSLayoutConstraint(item: pageControl, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 100), NSLayoutConstraint(item: pageControl, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 100)])
        self.addConstraints([NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: pageControl, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0), NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: pageControl, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 20)])
        
        pageControl.numberOfPages = 3
    }
    
    func showCenterContainer() {
        infiniteScrollView.showCenterContainer()
        updatePageControl()
    }
    
    func reloadData() {
        infiniteScrollView.reloadData()
        pageControl.numberOfPages = dataSource!.numberOfPages()
        updatePageControl()
    }
    
    func startAutoscroll() {
        infiniteScrollView.startAutoscroll()
    }
    
    // MARK: - Scroll view default methods
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        updatePageControl()
    }
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        infiniteScrollView.autoscrollTimer = NSTimer.scheduledTimerWithTimeInterval(3.5, target: infiniteScrollView, selector: "scrollNext", userInfo: nil, repeats: true)
    }
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        infiniteScrollView.autoscrollTimer?.invalidate()
    }
    
    func updatePageControl() {
        for container in infiniteScrollView.containers {
            if container.frame.origin.x == infiniteScrollView.contentOffset.x {
                pageControl.currentPage = dataSource!.currentIndex(container.index)
            }
        }
    }
    
}

// MARK: - qwe

protocol QweDelegate {
    func updatePageControl()
}

// MARK: -

class InfiniteScrollView: UIScrollView {
    
    let content = UIView(frame: CGRectZero)
    var containers = [Container]()
    var centerConstraint = NSLayoutConstraint()
    var anchorView: UIView?
    var autoscrollTimer: NSTimer?
    var dataSource: InfiniteScrollViewDelegate? {
        didSet {
            reloadData()
        }
    }
    var qwe: QweDelegate?
    var scroll = true
    
    // MARK: -
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        baseConfiguration()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        baseConfiguration()
    }
    
    func baseConfiguration() {
        pagingEnabled = true
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        
        self.addSubview(content)
        content.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.addConstraints([NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: content, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0), NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: content, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0), NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: content, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0), NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: content, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)])
        self.addConstraint(NSLayoutConstraint(item: content, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Width, multiplier: 9, constant: 0))
        
        placeFirstContainer()
        placeNewContainerOnTheLeft()
        placeNewContainerOnTheRight()
    }
    
    // MARK: - Content
    
    func reloadData() {
        for container in containers {
            container.imageView.image = dataSource?.imageForContainer(container.index)
        }
        
    }
    
    // MARK: - Addition of containers
    
    func placeFirstContainer() {
        let container = addNewContainer(0)
        containers.append(container)
        
        centerConstraint = NSLayoutConstraint(item: content, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: container, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        content.addConstraint(centerConstraint)
        
        anchorView = container
    }
    
    func placeNewContainerOnTheLeft() {
        let container = addNewContainer(containers.first!.index-1)
        
        var temp = containers.first!.frame
        temp.origin.x -= frame.size.width
        container.frame = temp
        
        content.addConstraint(NSLayoutConstraint(item: container, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: containers.first, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
        
        containers.insert(container, atIndex: 0)
    }
    
    func placeNewContainerOnTheRight() {
        let container = addNewContainer(containers.last!.index+1)
        
        var temp = containers.last!.frame
        temp.origin.x += frame.size.width
        container.frame = temp
        
        content.addConstraint(NSLayoutConstraint(item: container, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: containers.last, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0))
        
        containers.append(container)
    }
    
    func addNewContainer(index: Int)->Container {
        let container = Container(frame: CGRectZero)
        container.index = index
        container.imageView.image = dataSource?.imageForContainer(index)
        container.imageView.contentMode = UIViewContentMode.ScaleAspectFit
        content.addSubview(container)
        container.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.addConstraint(NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: container, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0))
        content.addConstraints([NSLayoutConstraint(item: content, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: container, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0), NSLayoutConstraint(item: content, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: container, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)])
        
        return container
        
    }
    
    // MARK: - Laying out containers
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        centerIfNeeded()
        
        tileContainers()
    }
    
    func centerIfNeeded() {
        let x = contentOffset.x + frame.size.width/2
        
        if (fabs(contentSize.width/2 - x) > contentSize.width/4) {
            let y = contentOffset.x
            if pagingEnabled {
                let p = contentSize.width/2 - frame.size.width/2 + contentOffset.x % frame.size.width
                contentOffset.x =  p
                centerConstraint.constant += y - p
            } else {
                contentOffset.x = contentSize.width/2 - frame.size.width/2
                centerConstraint.constant += y - contentOffset.x
            }
            
            content.layoutIfNeeded()
        }
        
    }
    
    func tileContainers() {
        var i = 0
        do {
            i = 0
            //remove container
            if let first = containers.first {
                if contentOffset.x > first.frame.origin.x + 2*frame.size.width {
                    if containers.count > 1 {
                        var newConstraint = centerConstraint
                
                        if first == anchorView {
                            if containers.count > 1 {
                                let second = containers[1]
                                newConstraint = NSLayoutConstraint(item: content, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: second, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: centerConstraint.constant-frame.size.width)
                                anchorView = second
                            }
                        }
                    
                        content.removeConstraint(centerConstraint)
                        centerConstraint = newConstraint
                        content.addConstraint(centerConstraint)
                    }
                }
            }
            if let last = containers.last {
                if contentOffset.x < last.frame.origin.x - 2*frame.size.width {
                    if containers.count > 1 {
                        if last == anchorView {
                            if containers.count > 1 {
                                let second = containers[containers.count - 2]
            
                                let newConstraint = NSLayoutConstraint(item: content, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: second, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: centerConstraint.constant+frame.size.width)
                                content.removeConstraint(centerConstraint)
                                content.addConstraint(newConstraint)
                                centerConstraint = newConstraint
                                anchorView = second
                            }
                        }
                    }
                }
            }
            
            // add new container
            if let first = containers.first {
                if contentOffset.x < first.frame.origin.x+frame.size.width {
                    placeNewContainerOnTheLeft()
                    i++
                } else if let last = containers.last {
                    if contentOffset.x > last.frame.origin.x-frame.size.width {
                        placeNewContainerOnTheRight()
                        i++
                    }
                }
            }
        } while i != 0
    }
    
    func showCenterContainer() {
        if containers.count > 0 {
            let x = containers.count/2
            let container = containers[x]
            contentOffset = CGPointMake(container.frame.origin.x, 0)
        }
    }

    // MARK: - Autoscroll
    
    func startAutoscroll() {
        autoscrollTimer = NSTimer.scheduledTimerWithTimeInterval(3.5, target: self, selector: "scrollNext", userInfo: nil, repeats: true)
    }
    
    func scrollNext() {
        if scroll {
            let currentOffset = contentOffset.x
            let currentConstraint = centerConstraint.constant
            
            var newOffset = contentOffset.x + self.frame.size.width
            var newConstraint = currentConstraint - self.frame.size.width
            
            contentOffset.x = newOffset
            centerConstraint.constant = newConstraint
            centerIfNeeded()
            
            if contentOffset.x == newOffset {
                contentOffset.x = currentOffset
                centerConstraint.constant = currentConstraint
            } else {
                tileContainers()
                newOffset = contentOffset.x + frame.size.width
            }
            
            UIView.animateWithDuration(0.7, animations: { () -> Void in
                self.contentOffset.x = newOffset
            }) { (complete: Bool) -> Void in
                self.tileContainers()
                self.qwe!.updatePageControl()
            }
        }
    }
    
}

// MARK: -

class Container: UIView {
    
    let imageView = UIImageView(frame: CGRectZero)
    var index = 0
    
    // MARK: -
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    func configure() {
        addSubview(imageView)
        imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        addConstraints([NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: imageView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0), NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: imageView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0), NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: imageView, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0), NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: imageView, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0)])
    }
}

// MARK: - Delegate Protocol
// MARK: -

protocol InfiniteScrollViewDelegate {
    func imageForContainer(index: Int)->UIImage
    func numberOfPages()->Int
    func currentIndex(index: Int)->Int
}
