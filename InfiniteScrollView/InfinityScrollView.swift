//
//  InfinityScrollView.swift
//  NopRocks
//
//  Created by orlangur on 24.11.15.
//  Copyright © 2015 liferevslabs. All rights reserved.
//

import UIKit
import AVFoundation

class InfiniteScrollView: UIScrollView, ContainerDelegate {
    
    static var views = [InfiniteScrollView]() // all isv's for containers dequing (see deinit)
    static let primeContainer = Container(frame: CGRectZero) // base container to copy
    static var globalContainers = [Container]() // array for dequing containers
    var id: String?
    var customContainer: UIView?
    let contentView = UIView(frame: CGRectZero)
    var subviewContainers = [Container]()
    var centerConstraint = NSLayoutConstraint()
    var contentWidthConstraint = NSLayoutConstraint()
    var centerView: Container?
    var centerIndex: Int? // maybe not neccessery
    var autoscrollTimer: NSTimer?
    var animation = false // support var for autoscroll method
    var scroll = true // support variable for autoscrolling method
    var items: [AnyObject]?
    var it = 0 // temp var for debugging
    var itemHandlingBlock: ((item: AnyObject?, container: Container)->(Void)) = { (item, container) in
        if let item = item as? UIImage {
            container.imageView.image = item
        }
    } {
        didSet {
            for container in subviewContainers {
                container.itemHandlingBlock = itemHandlingBlock
            }
        }
    }
    
    // MARK: - Static methods
    
    func dequeContainer(id: String?) -> Container {
        if let custom = customContainer {
            for container in InfiniteScrollView.globalContainers {
                if container.classForCoder == custom.classForCoder && container.superview == nil {
                    return container
                }
            }
            if let container = custom.copy() as? Container {
                return container
            }
        }
        
        for container in InfiniteScrollView.globalContainers {
            if container.id == id && container.superview == nil {
                return container
            }
        }
        
        let container = Container(frame: CGRectZero)
        container.id = id
        return container
    }
    
    class func willDestroy(isv: InfiniteScrollView) {
        if let ind = views.indexOf(isv) {
            views.removeAtIndex(ind)
        }
        // remove fabric containers for type
        if let id = isv.id {
            var remove = true
            for view in views {
                if id == view.id {
                    remove = false
                    break
                }
            }
            if remove {
                for container in InfiniteScrollView.globalContainers {
                    if container.id == id {
                        if let ind = InfiniteScrollView.globalContainers.indexOf(container) {
                            InfiniteScrollView.globalContainers.removeAtIndex(ind)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Initializations
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        baseConfiguration()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        baseConfiguration()
    }
    
    // configuration
    func baseConfiguration() {
        addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.New, context: nil)
        layer.masksToBounds = true
        InfiniteScrollView.views.append(self)
        // appearance
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        backgroundColor = UIColor.clearColor()
        
        // content container subview
        self.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        // constraints for content view
        self.addConstraints([
            NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
        ])
        contentWidthConstraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Width, multiplier: 9, constant: 0)
        self.addConstraint(contentWidthConstraint)
        
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRotate:", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    var rotated = false
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        rotated = true
    }
    
    func didRotate(notification: NSNotification) {
        rotated = false
    }

    deinit {
        InfiniteScrollView.willDestroy(self)
    }
    
    // MARK: Delegate methods
    
    func containerSelected(container: Container) {
        
    }
    
    func selected(container: Container) {
        
    }
    
    // MARK: - Adding containers
    
    func addNewContainer(index: Int)->Container {
        let container = dequeContainer(nil)
        container.itemHandlingBlock = itemHandlingBlock
        var tempRect = container.frame
        tempRect.origin.x = contentOffset.x
        container.frame = tempRect
        container.action = {
            self.selected(container)
        }
        container.index = index
        let item = itemForIndex(index)
        container.item = item
        itemHandlingBlock(item: item, container: container)
        contentView.addSubview(container)
        
        container.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraints([
            NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: container, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: container, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        ])
        let width = widthForItem(item, self)
        if let wc = container.widthConstraint {
            wc.constant = width
        } else {
            container.widthConstraint = NSLayoutConstraint(item: container, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: width)
            container.addConstraint(container.widthConstraint!)
        }
        
        container.frame = CGRectMake(0, 0, width, self.frame.size.height)
        
        InfiniteScrollView.globalContainers.append(container)
        
        return container
    }
    
    func placeFirstContainer() {
        let container = addNewContainer(0)
        
        container.center = contentView.center
        
        centerConstraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: container, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        contentView.addConstraint(centerConstraint)
        contentView.layoutIfNeeded()
        
        centerView = container
        subviewContainers.append(container)
    }
    
    func placeNewContainerOnTheLeft() {
        let container = addNewContainer(subviewContainers.first!.index - 1)
        var tCenter = subviewContainers.first!.center
        tCenter.x -= container.frame.size.width/2
        container.center = tCenter
        contentView.addConstraint(NSLayoutConstraint(item: container, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: subviewContainers.first, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
        contentView.layoutIfNeeded()
        
        subviewContainers.insert(container, atIndex: 0)
    }
    
    func placeNewContainerOnTheRight() {
        let container = addNewContainer(subviewContainers.last!.index+1)
        var tCenter = subviewContainers.last!.center
        tCenter.x += container.frame.size.width/2
        container.center = tCenter
        contentView.addConstraint(NSLayoutConstraint(item: container, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: subviewContainers.last, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0))
        contentView.layoutIfNeeded()
        
        subviewContainers.append(container)
    }
    
    // MARK: - Support methods
    
    var widthForItem: (AnyObject?, InfiniteScrollView) -> CGFloat = { item, isv in
        if !isv.pagingEnabled {
            if let image = item as? UIImage {
                return AVMakeRectWithAspectRatioInsideRect(CGSizeMake(image.size.width, image.size.height), isv.bounds).size.width
            }
        }
        return isv.bounds.size.width
    }

    func reloadData() {
        for container in subviewContainers {
            container.updateContent()
            if pagingEnabled {
                container.updateContent()
                container.widthConstraint?.constant = widthForItem(container.item, self)
                contentView.layoutIfNeeded()
            }
        }
        tileContainers()
    }
    
    func itemForIndex(index: Int) -> AnyObject? {
        if items == nil || items!.count == 0 {
            return nil
        } else if index < 0 {
            return itemForIndex(items!.count + index)
        } else if index > items!.count-1 {
            return itemForIndex(index % items!.count)
        } else {
            return items![index]
        }
    }
    
    // MARK: - Laying out containers
    
    override func layoutSubviews() {
        super.layoutSubviews()
        it = 0
        tileContainers()
    }
    
    var contentWitdh: CGFloat? // support variable for display rotation handling
    func tileContainers() {
        if items != nil && items!.count > 0 {
            if rotated && subviewContainers.count > 0 {
                if let w = contentWitdh {
                    contentOffset.x = contentOffset.x * (contentView.frame.size.width / w)
                    for con in contentView.subviews {
                        if let con = con as? Container {
                            con.widthConstraint?.constant = widthForItem(con.item!, self)
                        }
                    }
                    contentView.layoutIfNeeded()
                }
                contentWitdh = contentView.frame.size.width
                rotated = false
            }
            
            if ++it > 20 {
                print("attention!!!")
            }
            let fab = fabs(contentOffset.x - contentView.frame.size.width/2)
            // offset handling
            if fab > frame.size.width*3 {
                let newOffset = contentView.frame.size.width/2 - frame.size.width/2
                let diff = newOffset - contentOffset.x
                contentOffset.x = newOffset
                centerConstraint.constant += diff
                contentView.layoutIfNeeded()
            }
            
            // containers management
            if subviewContainers.count == 0 {
                // content empty
                placeFirstContainer()
                tileContainers()
                return
            } else {
                let visibleCenter = CGPointMake(contentOffset.x + frame.size.width/2, frame.size.height/2)
                // select central container (index and anchor view) and adjust offset if needed
                for container in subviewContainers {
                    if CGRectContainsPoint(container.frame, visibleCenter) && container != centerView {
                        let diff = centerView!.center.x - container.center.x
                        contentOffset.x += diff
                        contentView.removeConstraint(centerConstraint)
                        centerConstraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: container, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
                        contentView.addConstraint(centerConstraint)
                        centerView = container
                        centerIndex = container.index
                        contentView.layoutIfNeeded()
                        
                        break
                    }
                }
                
                // add and remove containers
                let first = subviewContainers.first as Container!
                let last = subviewContainers.last as Container!
                // adding new containers
                if contentOffset.x - first.frame.origin.x < first.frame.size.width/2 {
                    // adding left
                    placeNewContainerOnTheLeft()
                    tileContainers()
                    return
                } else {
                    // removing left
                    if subviewContainers.count > 1 {
                        let second = subviewContainers[1] as Container!
                        if contentOffset.x - second.frame.origin.x > second.frame.size.width/2 {
                            removeLeftContainer()
                            tileContainers()
                            return
                        }
                    }
                }
                if (last.frame.origin.x + last.frame.size.width/2) - (contentOffset.x + frame.size.width) < last.frame.size.width/2 {
                    // adding right
                    placeNewContainerOnTheRight()
                    tileContainers()
                    return
                } else {
                    // removing right
                    if subviewContainers.count > 1 {
                        let preLast = subviewContainers[subviewContainers.count-2]
                        if (preLast.frame.origin.x + preLast.frame.size.width/2) - (contentOffset.x + frame.size.width) > preLast.frame.size.width/2 {
                            removeRightContainer()
                            tileContainers()
                            return
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Removing containers
    
    func removeLeftContainer() {
        if let left = subviewContainers.first {
            subviewContainers.removeFirst()
            left.removeFromSuperview()
            left.item = nil
        }
    }
    
    func removeRightContainer() {
        if let right = subviewContainers.last {
            subviewContainers.removeLast()
            right.removeFromSuperview()
            right.item = nil
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
            let newConstraint = currentConstraint - self.frame.size.width
            
            contentOffset.x = newOffset
            centerConstraint.constant = newConstraint
            
            if contentOffset.x == newOffset {
                contentOffset.x = currentOffset
                centerConstraint.constant = currentConstraint
            } else {
                tileContainers()
                newOffset = contentOffset.x + frame.size.width
            }
            
            UIView.animateWithDuration(0.7, animations: { () -> Void in
                self.animation = true
                self.contentOffset.x = newOffset
                }) { (complete: Bool) -> Void in
                    self.animation = false
                    self.tileContainers()
                    // TODO: update page control here
            }
        }
    }
    
}