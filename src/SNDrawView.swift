//
//  SNDrawView.swift
//  SNDraw
//
//  Created by satoshi on 8/2/16.
//  Copyright © 2016 Satoshi Nakajima. All rights reserved.
//

import UIKit


public protocol SNDrawViewDelegate:NSObjectProtocol {
    func didComplete(_ elements:[SNPathElement]) -> Bool
}

open class SNDrawView: UIView {
    public var builder = SNPathBuilder(minSegment: 25.0)
    weak public var delegate:SNDrawViewDelegate?
    public lazy var shapeLayer:CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.contentsScale = UIScreen.main.scale
        shapeLayer.lineWidth = 10.0
        shapeLayer.strokeColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.3).cgColor
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(shapeLayer)
        return shapeLayer
    }()
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            shapeLayer.path = builder.start(touch.location(in: self))
        }
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if let path = builder.move(touch.location(in: self)) {
                shapeLayer.path = path
            }
        }
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = touches.first {
            shapeLayer.path = builder.end()
            
            if delegate?.didComplete(builder.elements) == true {
                shapeLayer.path = nil
            }
        }
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        print("touchesCancelled")
    }
}
