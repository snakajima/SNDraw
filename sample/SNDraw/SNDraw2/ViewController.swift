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
    case started = 2
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
            case .started:
                self.view.layer.backgroundColor = validColor
                layers[index].backgroundColor = normalColor
            case .drawing:
                self.view.layer.backgroundColor = normalColor
                for (i, layer) in layers.enumerate() {
                    layer.backgroundColor = (i == index) ? validColor : normalColor
                }
            case .done:
                self.view.layer.backgroundColor = normalColor
                layers[index].backgroundColor = normalColor
            }
        }
    }
    private let layers = [CALayer(), CALayer(), CALayer(), CALayer(), CALayer()]
    private let normalColor = UIColor.whiteColor().CGColor
    private let invalidColor = UIColor(red: 1, green: 0.8, blue: 0.8, alpha: 1.0).CGColor
    private let validColor = UIColor(red: 0.8, green: 1, blue: 0.8, alpha: 1.0).CGColor
    private let activeColor = UIColor(red: 0.5, green: 1, blue: 0.5, alpha: 1.0).CGColor
    private var radius = 100.0 as CGFloat

    override func viewDidLoad() {
        super.viewDidLoad()
        
        layers.forEach() { (layer: CALayer) in
            layer.backgroundColor = validColor
            self.view.layer.addSublayer(layer)
        }
    }
    
    override func viewDidLayoutSubviews() {
        let size = self.view.frame.size
        radius = size.width / 10
        let r2 = radius * 2
        for (i, layer) in layers.enumerate() {
            layer.frame = CGRectMake(CGFloat(i) * r2, size.height - r2, r2, r2)
            layer.cornerRadius = radius
        }
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
            var newStatus = DrawStatus.invalid
            for (i, layer) in layers.enumerate() {
                if inRange(layer, pt: pt) {
                    index = i
                    newStatus = .started
                }
            }
            status = newStatus
        }
    }
    
    func inRange(layer:CALayer, pt:CGPoint) -> Bool {
        let pos = layer.position
        let (dx, dy) = (pos.x - pt.x, pos.y - pt.y)
        return dx * dx + dy * dy < radius * radius
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let pt = touch.locationInView(self.view)
            switch(status) {
            case .started:
                if !inRange(layers[index], pt: pt) {
                    status = .drawing
                    shapeLayer.path = builder.start(pt)
                }
            case .drawing:
                if let path = builder.move(pt) {
                    shapeLayer.path = path
                }
                if inRange(layers[index], pt: pt) {
                    status = .done
                }
            default:
                break
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let _ = touches.first {
            shapeLayer.path = builder.end()
        }
        switch(status) {
        case .done:
            var elements = builder.elements
            if let move = elements.first as? SNMove {
                elements[0] = SNLine(x: move.pt.x, y:move.pt.y)
            }
            var offset = index * 2 + 1
            if index < 2 {
                offset -= 1
            } else if index > 2 {
                offset += 1
            }
            let pt = CGPointMake(CGFloat(offset) * radius, self.view.frame.size.height)
            elements.insert(SNMove(x: pt.x, y: pt.y), atIndex: 0)
            elements.append(SNLine(x: pt.x, y: pt.y))
            shapeLayer.path = SNPath.pathFrom(elements)
            break
        default:
            shapeLayer.path = nil
        }
        status = .none
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        print("touchesCancelled")
        shapeLayer.path = nil
        status = .none
    }

}

