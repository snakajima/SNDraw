//
//  SNDrawView.swift
//  SNDraw
//
//  Created by satoshi on 8/2/16.
//  Copyright © 2016 Satoshi Nakajima. All rights reserved.
//

import UIKit

class SNDrawView: UIView {
    var delta = 10.0 as CGFloat
    var path = CGPathCreateMutable()
    var ptLast = CGPointZero
    var ptDelta:CGPoint?
    lazy var shapeLayer:CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.contentsScale = UIScreen.mainScreen().scale
        shapeLayer.lineWidth = 10.0
        shapeLayer.strokeColor = UIColor.blueColor().CGColor
        shapeLayer.lineCap = "round"
        shapeLayer.lineJoin = "round"
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        self.layer.addSublayer(shapeLayer)
        return shapeLayer
    }()
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let pt = touch.locationInView(self)
            path = CGPathCreateMutable()
            CGPathMoveToPoint(path, nil, pt.x, pt.y)
            shapeLayer.path = path
            ptLast = pt
            ptDelta = nil
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let pt = touch.locationInView(self)
            let (dx, dy) = (pt.x - ptLast.x, pt.y - ptLast.y)
            if dx * dx + dy * dy > delta * delta {
                if let _ = ptDelta {
                    let ptMid = CGPointMake((ptLast.x + pt.x) / 2.0, (ptLast.y + pt.y) / 2.0)
                    CGPathAddQuadCurveToPoint(path, nil, ptLast.x, ptLast.y, ptMid.x, ptMid.y)
                    shapeLayer.path = path
                }
                ptLast = pt
                ptDelta = CGPointMake(dx, dy)
            } else if let ptD = ptDelta {
                let v = ptD.x * dx + ptD.y * dy
                if v < 0 {
                    CGPathAddLineToPoint(path, nil, ptLast.x, ptLast.y)
                    shapeLayer.path = path
                    ptLast = pt
                    ptDelta = CGPointMake(dx, dy)
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let pt = touch.locationInView(self)
            CGPathAddQuadCurveToPoint(path, nil, ptLast.x, ptLast.y, pt.x, pt.y)
            shapeLayer.path = path
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        print("touchesCancelled")
    }
}
