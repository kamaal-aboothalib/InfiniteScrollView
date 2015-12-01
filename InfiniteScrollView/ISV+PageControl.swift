//
//  ISV+PageControl.swift
//  NopRocks
//
//  Created by orlangur on 24.11.15.
//  Copyright © 2015 liferevslabs. All rights reserved.
//

import UIKit

class InfiniteScrollViewWithPageControll: UIView, UIScrollViewDelegate, PageControlDelegate {
    
    let infiniteScrollView = InfiniteScrollView(frame: CGRectZero)
    let pageControl = UIPageControl(frame: CGRectZero)
    
    // MARK: -
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        baseConfiguration()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        baseConfiguration()
    }
    
    func baseConfiguration() {
        // scroll view
        addSubview(infiniteScrollView)
        infiniteScrollView.translatesAutoresizingMaskIntoConstraints = false
        addConstraints([
            NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: infiniteScrollView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: infiniteScrollView, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: infiniteScrollView, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0)])
        
        // page control
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.tintColor = UIColor.blackColor()
        pageControl.backgroundColor = UIColor.clearColor()
        pageControl.pageIndicatorTintColor = UIColor.darkGrayColor()
        pageControl.currentPageIndicatorTintColor = UIColor.lightGrayColor()
        addSubview(pageControl)
        pageControl.addConstraints([NSLayoutConstraint(item: pageControl, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 100), NSLayoutConstraint(item: pageControl, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 23)])
        addConstraints([NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: pageControl, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0), NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: pageControl, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0), NSLayoutConstraint(item: infiniteScrollView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: pageControl, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)])
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

    }
    
}
