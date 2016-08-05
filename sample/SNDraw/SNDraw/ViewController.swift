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
    var layers = [CALayer]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        drawView?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func clear() {
        for layer in layers {
            layer.removeFromSuperlayer()
        }
        layers.removeAll()
    }
    
    @IBAction func slide(slider:UISlider) {
        drawView?.minSegment = CGFloat(slider.value)
    }
}

extension ViewController : SNDrawViewDelegate {
    func didComplete(ptBegin:CGPoint, curves:[SNQuadCurve]) -> Bool {
        print("complete", curves.count)
        let pathLine = CGPathCreateMutable()
        let pathCurve = CGPathCreateMutable()
        CGPathMoveToPoint(pathLine, nil, ptBegin.x, ptBegin.y)
        CGPathMoveToPoint(pathCurve, nil, ptBegin.x, ptBegin.y)
        for curve in curves {
            CGPathAddLineToPoint(pathLine, nil, curve.cpt.x, curve.cpt.y)
            CGPathAddLineToPoint(pathLine, nil, curve.pt.x, curve.pt.y)
            CGPathAddQuadCurveToPoint(pathCurve, nil, curve.cpt.x, curve.cpt.y, curve.pt.x, curve.pt.y)
        }
        let layerCurve = CAShapeLayer()
        layerCurve.path = pathCurve
        layerCurve.lineWidth = 1
        layerCurve.fillColor = UIColor.clearColor().CGColor
        layerCurve.strokeColor = UIColor.greenColor().CGColor
        self.view.layer.addSublayer(layerCurve)
        layers.append(layerCurve)

        let layerLine = CAShapeLayer()
        layerLine.path = pathLine
        layerLine.lineWidth = 1
        layerLine.fillColor = UIColor.clearColor().CGColor
        layerLine.strokeColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.3).CGColor
        self.view.layer.addSublayer(layerLine)
        layers.append(layerLine)

        return true
    }
}

