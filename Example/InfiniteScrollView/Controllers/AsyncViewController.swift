//
//  AsyncViewController.swift
//  InfiniteScrollView
//
//  Created by orlangur on 01.12.15.
//  Copyright © 2015 Sergey Garazha. All rights reserved.
//

import UIKit
import AVFoundation

func randomCGFloat() -> CGFloat {
    return CGFloat(arc4random()) / CGFloat(UInt32.max)
}

extension UIColor {
    static func randomColor() -> UIColor {
        let r = randomCGFloat()
        let g = randomCGFloat()
        let b = randomCGFloat()
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}

class AsyncViewController: UIViewController {

    @IBOutlet weak var isv: InfiniteScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isv.customContainer = AsyncContainer(frame: CGRectZero)
        isv.itemHandlingBlock = { (item: AnyObject?, container: Container) in
            if let item = item as? Model, container = container as? AsyncContainer {
                if let pic = item.image {
                    container.imView.image = pic
                    container.loadingIndicator.stopAnimating()
                } else {
                    container.loadingIndicator.startAnimating()
                }
            }
        }
        isv.widthForItem = { (item, isv) in
            if let item = item as? Model, image = item.image {
                return AVMakeRectWithAspectRatioInsideRect(CGSizeMake(image.size.width, image.size.height), isv.bounds).size.width
            } else {
                return isv.frame.size.width
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        let delay = 1 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.isv.items = models
            self.isv.reloadData()
            
            let session = NSURLSession.sharedSession()
            for model in models {
                if let surl = model.url, url = NSURL(string: surl) {
                    let task = session.dataTaskWithURL(url, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                        if let data = data, image = UIImage(data: data) {
                            model.image = image
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.isv.reloadData()
                            })
                        }
                    })
                    task.resume()
                }
            }
        }
    }

}
