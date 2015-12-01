//
//  Container.swift
//  NopRocks
//
//  Created by orlangur on 24.11.15.
//  Copyright © 2015 liferevslabs. All rights reserved.
//

import UIKit
import AVFoundation

class Container: UIView {
    
    var item: AnyObject?
    let imageView = UIImageView(frame: CGRectZero)
    var index = 0
    var widthConstraint: NSLayoutConstraint?
    var id: String?
//    var delegate: ContainerDelegate?
    var action: ((Void)->(Void))?
    var itemHandlingBlock: ((item: AnyObject?, container: Container)->(Void)) = { (item, container) in
        if let image = item as? UIImage {
            container.imageView.image = image
        }
    }
    
    // MARK: -
    
    override func copy() -> AnyObject {
        let  container = self.dynamicType.init(frame: frame)
        return container
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        configure()
    }
    
    func updateContent() {
        itemHandlingBlock(item: item, container: self)
    }
    
    func configure() {
        addSubview(imageView)
        
//        let hue = arc4random() % 256 / 256
//        let saturation = ( arc4random() % 128 / 256) + UInt32(0.5)
//        let brightness = ( arc4random() % 128 / 256 ) + UInt32(0.5)
//        let color = UIColor(hue: CGFloat(hue), saturation: CGFloat(saturation), brightness: CGFloat(brightness), alpha: 1)
//        backgroundColor = color
        backgroundColor = UIColor.clearColor()
        imageView.backgroundColor = UIColor.clearColor()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .ScaleAspectFit
        
        addConstraints([NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: imageView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0), NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: imageView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0), NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: imageView, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0), NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: imageView, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0)])
    }
    
    var touch: UITouch?
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touch = touches.first
    }
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
//        delegate?.containerSelected(self)
        touch = nil
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        delegate?.containerSelected(self)
        touch = nil
    }
}