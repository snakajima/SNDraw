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
    var ptPrev = CGPointZero
    var anchor = CGPointZero
    var last = CGPointZero
    var ptDelta:CGPoint?
    var count = 0
    lazy var shapeLayer:CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.contentsScale = UIScreen.mainScreen().scale
        shapeLayer.lineWidth = 10.0
        shapeLayer.strokeColor = UIColor.blueColor().CGColor
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.lineJoin = kCALineJoinRound
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
            anchor = pt // REVIEW: optional?
            last = pt
            ptDelta = nil
            count = 0
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let pt = touch.locationInView(self)
            let (dxA, dyA) = (pt.x - anchor.x, pt.y - anchor.y)
            let (dx, dy) = (pt.x - last.x, pt.y - last.y)
            if dxA * dxA + dyA * dyA > delta * delta {
                if let _ = ptDelta {
                    ptPrev = anchor
                    let ptMid = CGPointMake((anchor.x + pt.x) / 2.0, (anchor.y + pt.y) / 2.0)
                    CGPathAddQuadCurveToPoint(path, nil, anchor.x, anchor.y, ptMid.x, ptMid.y)
                    shapeLayer.path = path
                }
                anchor = pt
                ptDelta = CGPointMake(dx, dy)
            } else if let ptD = ptDelta where ptD.x * dx + ptD.y * dy < 0 {
                print("Tight turn", count)
                CGPathAddQuadCurveToPoint(path, nil, anchor.x, anchor.y, last.x, last.y)
                shapeLayer.path = path
                anchor = pt
                ptDelta = CGPointMake(dx, dy)
            } else {
                let pathTemp = CGPathCreateMutableCopy(path)
                CGPathAddLineToPoint(pathTemp, nil, pt.x, pt.y)
                shapeLayer.path = pathTemp
            }
            last = pt
            count = count + 1
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let pt = touch.locationInView(self)
            CGPathAddQuadCurveToPoint(path, nil, anchor.x, anchor.y, pt.x, pt.y)
            shapeLayer.path = path
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        print("touchesCancelled")
    }
}
