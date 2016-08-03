//
//  SNDrawView.swift
//  SNDraw
//
//  Created by satoshi on 8/2/16.
//  Copyright © 2016 Satoshi Nakajima. All rights reserved.
//

import UIKit

class SNDrawView: UIView {
    var delta = 20.0 as CGFloat
    var path = CGPathCreateMutable()
    var pathPrev:CGMutablePath?
    var ptPrev = CGPointZero
    var ptLast = CGPointZero
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
            ptLast = pt
            ptDelta = nil
            pathPrev = nil
            count = 0
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let pt = touch.locationInView(self)
            let (dx, dy) = (pt.x - ptLast.x, pt.y - ptLast.y)
            if dx * dx + dy * dy > delta * delta {
                if let _ = ptDelta {
                    pathPrev = CGPathCreateMutableCopy(path)
                    ptPrev = ptLast
                    let ptMid = CGPointMake((ptLast.x + pt.x) / 2.0, (ptLast.y + pt.y) / 2.0)
                    CGPathAddQuadCurveToPoint(path, nil, ptLast.x, ptLast.y, ptMid.x, ptMid.y)
                    shapeLayer.path = path
                }
                ptLast = pt
                ptDelta = CGPointMake(dx, dy)
            } else if let ptD = ptDelta where ptD.x * dx + ptD.y * dy < 0 {
                if let pathPrev = pathPrev {
                    print("Tight turn", count)
                    CGPathAddQuadCurveToPoint(pathPrev, nil, ptPrev.x, ptPrev.y, ptLast.x, ptLast.y)
                    path = pathPrev
                } else {
                    print("Tight turn, no pathPrev", count)
                    CGPathAddLineToPoint(path, nil, ptLast.x, ptLast.y)
                }
                pathPrev = nil
                shapeLayer.path = path
                ptLast = pt
                ptDelta = CGPointMake(dx, dy)
            } else {
                let pathTemp = CGPathCreateMutableCopy(path)
                CGPathAddLineToPoint(pathTemp, nil, pt.x, pt.y)
                shapeLayer.path = pathTemp
            }
            count = count + 1
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let pt = touch.locationInView(self)
            CGPathAddQuadCurveToPoint(path, nil, ptLast.x, ptLast.y, pt.x, pt.y)
            shapeLayer.path = path
            pathPrev = nil
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        print("touchesCancelled")
    }
}
