//
//  InfiniteScrollView.swift
//  123
//
//  Created by garazha on 4/22/15.
//  Copyright (c) 2015 Sergey Garazha. All rights reserved.
//

import UIKit

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

// MARK: - 

protocol InfiniteScrollViewDelegate {
    func imageForContainer(index: Int)->UIImage
}

// MARK: -

class InfiniteScrollView: UIScrollView {
    
    let content = UIView(frame: CGRectZero)
    var containers = [Container]()
    var centerConstraint = NSLayoutConstraint()
    var anchorView: UIView?
    var dataSource: InfiniteScrollViewDelegate? {
        didSet {
            reloadData()
        }
    }
    
    // MARK: -
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
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
        
        content.addConstraint(NSLayoutConstraint(item: container, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: containers.first, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
        
        containers.insert(container, atIndex: 0)
    }
    
    func placeNewContainerOnTheRight() {
        let container = addNewContainer(containers.last!.index+1)
        
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
        }
    }
    
    func tileContainers() {
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
                    
                    containers.removeAtIndex(0)
                    first.removeFromSuperview()
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
                    
                    containers.removeAtIndex(containers.count-1)
                    last.removeFromSuperview()
                }
            }
        }

        // add new container
        if let first = containers.first {
            if contentOffset.x < first.frame.origin.x+frame.size.width {
                placeNewContainerOnTheLeft()
            } else if let last = containers.last {
                if contentOffset.x > last.frame.origin.x-frame.size.width {
                    placeNewContainerOnTheRight()
                }
            }
        }
    }
    
    func showCenterContainer() {
        if containers.count > 0 {
            let x = containers.count/2
            let container = containers[x]
            contentOffset = CGPointMake(container.frame.origin.x, 0)
        }
    }
    
}
