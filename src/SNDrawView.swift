//
//  SNDrawView.swift
//  SNDraw
//
//  Created by satoshi on 8/2/16.
//  Copyright © 2016 Satoshi Nakajima. All rights reserved.
//

import UIKit


public protocol SNDrawViewDelegate:NSObjectProtocol {
    func didComplete(elements:[SNPathElement]) -> Bool
}

public class SNDrawView: UIView {
    public var builder = SNPathBuilder(minSegment: 25.0)
    weak public var delegate:SNDrawViewDelegate?

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
            shapeLayer.path = builder.start(touch.locationInView(self))
        }
    }
    
    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            if let path = builder.move(touch.locationInView(self)) {
                shapeLayer.path = path
            }
        }
    }
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let _ = touches.first {
            shapeLayer.path = builder.end()
            
            if let delegate = delegate where delegate.didComplete(builder.elements) {
                shapeLayer.path = nil
            }
        }
    }
    
    override public func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        print("touchesCancelled")
    }
}
