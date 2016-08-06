//
//  ViewController.swift
//  SNDraw2
//
//  Created by satoshi on 8/6/16.
//  Copyright © 2016 Satoshi Nakajima. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var builder = SNPathBuilder(minSegment: 25.0)
    lazy var shapeLayer:CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.contentsScale = UIScreen.mainScreen().scale
        shapeLayer.lineWidth = 10.0
        shapeLayer.strokeColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.3).CGColor
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        self.view.layer.addSublayer(shapeLayer)
        return shapeLayer
    }()
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            shapeLayer.path = builder.start(touch.locationInView(self.view))
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            if let path = builder.move(touch.locationInView(self.view)) {
                shapeLayer.path = path
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let _ = touches.first {
            shapeLayer.path = builder.end()
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        print("touchesCancelled")
    }

}

