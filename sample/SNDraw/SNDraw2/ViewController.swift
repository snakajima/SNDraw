//
//  ViewController.swift
//  SNDraw2
//
//  Created by satoshi on 8/6/16.
//  Copyright © 2016 Satoshi Nakajima. All rights reserved.
//

import UIKit

enum DrawStatus: Int {
    case none = 0
    case invalid = 1
    case valid = 2
    case drawing = 3
    case done = 4
}

class ViewController: UIViewController {
    private var index = 0
    private var status = DrawStatus.none {
        didSet {
            switch(oldValue) {
            default:
                break
            }
            
            switch(status) {
            case .none:
                self.view.layer.backgroundColor = normalColor
                layers.forEach({ (layer) in
                    layer.backgroundColor = validColor
                })
            case .invalid:
                self.view.layer.backgroundColor = invalidColor
            case .valid:
                self.view.layer.backgroundColor = validColor
                layers[index].backgroundColor = normalColor
                layers.filter({ (layer) -> Bool in
                    layer != layers[index]
                }).forEach({ (layer) in
                    layer.backgroundColor = normalColor
                })
            default:
                break
            }
        }
    }
    private let layers = [CALayer(), CALayer()]
    private let normalColor = UIColor.whiteColor().CGColor
    private let invalidColor = UIColor(red: 1, green: 0.8, blue: 0.8, alpha: 1.0).CGColor
    private let validColor = UIColor(red: 0.8, green: 1, blue: 0.8, alpha: 1.0).CGColor
    private let activeColor = UIColor(red: 0.5, green: 1, blue: 0.5, alpha: 1.0).CGColor
    private let radius = 100.0 as CGFloat

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let frame = CGRectMake(0, 0, radius * 2, radius * 2)
        layers.forEach() { (layer: CALayer) in
            layer.frame = frame
            layer.backgroundColor = validColor
            layer.cornerRadius = radius
            self.view.layer.addSublayer(layer)
        }
    }
    
    override func viewDidLayoutSubviews() {
        let size = self.view.frame.size
        layers[0].position = CGPointMake(0, size.height)
        layers[1].position = CGPointMake(size.width, size.height)
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
            let pt = touch.locationInView(self.view)
            shapeLayer.path = builder.start(pt)
            var newStatus = DrawStatus.invalid
            for (i, layer) in layers.enumerate() {
                let pos = layer.position
                let (dx, dy) = (pos.x - pt.x, pos.y - pt.y)
                if dx * dx + dy * dy < radius * radius {
                    index = i
                    newStatus = .valid
                }
            }
            status = newStatus
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
        status = .none
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        print("touchesCancelled")
        status = .none
    }

}

