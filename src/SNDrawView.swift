//
//  SNDrawView.swift
//  SNDraw
//
//  Created by satoshi on 8/2/16.
//  Copyright © 2016 Satoshi Nakajima. All rights reserved.
//

import UIKit

public struct SNQuadCurve {
    let cpt:CGPoint
    let pt:CGPoint
    init(cpx: CGFloat, cpy: CGFloat, x: CGFloat, y: CGFloat) {
        cpt = CGPointMake(cpx, cpy)
        pt = CGPointMake(x, y)
    }
}

public protocol SNDrawViewDelegate:NSObjectProtocol {
    func didComplete(ptBegin:CGPoint, curves:[SNQuadCurve]) -> Bool
}

public class SNDrawView: UIView {
    public var minSegment = 25.0 as CGFloat
    weak public var delegate:SNDrawViewDelegate?
    private var ptBegin = CGPointZero
    private var curves = [SNQuadCurve]()
    private var path = CGPathCreateMutable()
    private var segment = 0 as CGFloat
    private var anchor = CGPointZero // last anchor point
    private var last = CGPointZero // last touch point
    private var delta:CGPoint? // last movement to compare against to detect a sharp turn
    private var fEdge = true //either the begging or the turning point
    private var count = 0
    private lazy var shapeLayer:CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.contentsScale = UIScreen.mainScreen().scale
        shapeLayer.lineWidth = 10.0
        shapeLayer.strokeColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.3).CGColor
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        self.layer.addSublayer(shapeLayer)
        return shapeLayer
    }()
    
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let pt = touch.locationInView(self)
            path = CGPathCreateMutable()
            CGPathMoveToPoint(path, nil, pt.x, pt.y)
            ptBegin = pt
            curves = [SNQuadCurve]()
            shapeLayer.path = path
            anchor = pt
            last = pt
            delta = nil
            fEdge = true
            segment = 0.0
            count = 0
        }
    }
    
    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let pt = touch.locationInView(self)
            let (dx, dy) = (pt.x - last.x, pt.y - last.y)
            segment += sqrt(dx * dx + dy * dy)
            if segment > minSegment {
                if !fEdge {
                    let ptMid = CGPointMake((anchor.x + pt.x) / 2.0, (anchor.y + pt.y) / 2.0)
                    CGPathAddQuadCurveToPoint(path, nil, anchor.x, anchor.y, ptMid.x, ptMid.y)
                    curves.append(SNQuadCurve(cpx: anchor.x, cpy: anchor.y, x: ptMid.x, y: ptMid.y))
                    shapeLayer.path = path
                }
                delta = CGPointMake(pt.x - anchor.x, pt.y - anchor.y)
                anchor = pt
                fEdge = false
                segment = 0.0
                count = count + 1
            } else if let ptD = delta where ptD.x * dx + ptD.y * dy < 0 {
                print("Tight turn", count)
                CGPathAddQuadCurveToPoint(path, nil, anchor.x, anchor.y, last.x, last.y)
                curves.append(SNQuadCurve(cpx: anchor.x, cpy: anchor.y, x: last.x, y: last.y))
                shapeLayer.path = path
                anchor = pt
                delta = nil
                fEdge = true
                segment = 0.0
                count = count + 1
            } else {
                let pathTemp = CGPathCreateMutableCopy(path)
                CGPathAddLineToPoint(pathTemp, nil, pt.x, pt.y)
                shapeLayer.path = pathTemp
                delta = CGPointMake(pt.x - anchor.x, pt.y - anchor.y)
            }
            last = pt
        }
    }
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let _ = touches.first {
            print("End", count)
            // NOTE: We intentionally ignore the last point to reduce the noise.
            CGPathAddQuadCurveToPoint(path, nil, anchor.x, anchor.y, last.x, last.y)
            curves.append(SNQuadCurve(cpx: anchor.x, cpy: anchor.y, x: last.x, y: last.y))
            shapeLayer.path = path
            
            if let delegate = delegate where delegate.didComplete(ptBegin, curves: curves) {
                shapeLayer.path = nil
            }
        }
    }
    
    override public func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        print("touchesCancelled")
    }
}
