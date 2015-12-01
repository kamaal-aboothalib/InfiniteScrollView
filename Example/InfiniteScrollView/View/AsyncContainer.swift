//
//  AsyncContainer.swift
//  InfiniteScrollView
//
//  Created by orlangur on 01.12.15.
//  Copyright © 2015 Sergey Garazha. All rights reserved.
//

import UIKit

extension UIView {
    func fillSubview(view: UIView) {
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        addConstraints([constraint(.Left, subview: view), constraint(.Top, subview: view), constraint(.Right, subview: view), constraint(.Bottom, subview: view)])
    }
    
    func constraint(side: NSLayoutAttribute, subview: UIView) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self, attribute: side, relatedBy: .Equal, toItem: subview, attribute: side, multiplier: 1, constant: 0)
    }
    func loadFromNib(name: String) -> UIView {
        let view = UINib(nibName: name, bundle: NSBundle.mainBundle()).instantiateWithOwner(self, options: nil).first as! UIView
        fillSubview(view)
        return view
    }
}

class AsyncContainer: Container {

    @IBOutlet weak var imView: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func configure() {
        loadFromNib("AsyncContainer")
    }
    
}
