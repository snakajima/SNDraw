//
//  SNPath.swift
//  SNDraw
//
//  Created by satoshi on 8/5/16.
//  Copyright © 2016 Satoshi Nakajima. All rights reserved.
//

import UIKit

public struct SNPath {
    static func pathFrom(elements:[SNPathElement]) -> CGPath {
        let path = CGPathCreateMutable()
        for element in elements {
            switch(element) {
            case let move as SNMove:
                CGPathMoveToPoint(path, nil, move.pt.x, move.pt.y)
            case let curve as SNQuadCurve:
                CGPathAddQuadCurveToPoint(path, nil, curve.cpt.x, curve.cpt.y, curve.pt.x, curve.pt.y)
            default:
                break
            }
        }
        return path
    }
    
    static func polyPathFrom(elements:[SNPathElement]) -> CGPath {
        let path = CGPathCreateMutable()
        for element in elements {
            switch(element) {
            case let move as SNMove:
                CGPathMoveToPoint(path, nil, move.pt.x, move.pt.y)
            case let curve as SNQuadCurve:
                CGPathAddLineToPoint(path, nil, curve.cpt.x, curve.cpt.y)
                CGPathAddLineToPoint(path, nil, curve.pt.x, curve.pt.y)
            default:
                break
            }
        }
        return path
    }
}

public protocol SNPathElement {
}

public struct SNMove:SNPathElement {
    let pt:CGPoint
    init(x:CGFloat, y:CGFloat) {
        pt = CGPointMake(x,y)
    }
}

public struct SNLine:SNPathElement {
    let pt:CGPoint
}

public struct SNQuadCurve:SNPathElement {
    let cpt:CGPoint
    let pt:CGPoint
    init(cpx: CGFloat, cpy: CGFloat, x: CGFloat, y: CGFloat) {
        cpt = CGPointMake(cpx, cpy)
        pt = CGPointMake(x, y)
    }
}

