//
//  ViewController.swift
//  SNDraw
//
//  Created by satoshi on 8/2/16.
//  Copyright © 2016 Satoshi Nakajima. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var drawView:SNDrawView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        drawView?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController : SNDrawViewDelegate {
    func didComplete(ptBegin:CGPoint, curves:[SNQuadCurve]) -> Bool {
        print("complete", curves.count)
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, ptBegin.x, ptBegin.y)
        for curve in curves {
            CGPathAddLineToPoint(path, nil, curve.cpt.x, curve.cpt.y)
            CGPathAddLineToPoint(path, nil, curve.pt.x, curve.pt.y)
        }
        let layer = CAShapeLayer()
        layer.path = path
        layer.lineWidth = 1
        layer.fillColor = UIColor.clearColor().CGColor
        layer.strokeColor = UIColor.blueColor().CGColor
        self.view.layer.addSublayer(layer)
        return true
    }
}

