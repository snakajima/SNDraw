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
        drawView?.shapeLayer.lineWidth = 12.0
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
    
    @IBAction func slide(_ slider:UISlider) {
        drawView?.builder.minSegment = CGFloat(slider.value)
    }
}

extension ViewController : SNDrawViewDelegate {
    func didComplete(_ elements:[SNPathElement]) -> Bool {
        print("complete", elements.count)

        let layerCurve = CAShapeLayer()
        
        // Extra round-trips to SVG and CGPath
        let svg = SNPath.svg(from: elements)
        let es = SNPath.elements(from: svg)
        let path = SNPath.path(from: es)
        let es2 = SNPath.elements(from: path)
        
        layerCurve.path = SNPath.path(from: es2)
        layerCurve.lineWidth = 12
        layerCurve.fillColor = UIColor.clear.cgColor
        layerCurve.strokeColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.4).cgColor
        layerCurve.lineCap = convertToCAShapeLayerLineCap("round")
        layerCurve.lineJoin = convertToCAShapeLayerLineJoin("round")
        self.view.layer.addSublayer(layerCurve)
        layers.append(layerCurve)

        let layerLine = CAShapeLayer()
        layerLine.path = SNPath.polyPath(from: elements)
        layerLine.lineWidth = 2
        layerLine.fillColor = UIColor.clear.cgColor
        layerLine.strokeColor = UIColor(red: 0, green: 0, blue: 0.8, alpha: 0.1).cgColor
        self.view.layer.addSublayer(layerLine)
        layers.append(layerLine)
        
        print(SNPath.svg(from: elements))

        return true
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToCAShapeLayerLineCap(_ input: String) -> CAShapeLayerLineCap {
	return CAShapeLayerLineCap(rawValue: input)
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToCAShapeLayerLineJoin(_ input: String) -> CAShapeLayerLineJoin {
	return CAShapeLayerLineJoin(rawValue: input)
}
