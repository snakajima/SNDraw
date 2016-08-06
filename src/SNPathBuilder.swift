//
//  SNPathBuilder.swift
//  SNDraw
//
//  Created by satoshi on 8/6/16.
//  Copyright © 2016 Satoshi Nakajima. All rights reserved.
//

import UIKit

public struct SNPathBuilder {
    public var minSegment:CGFloat
    public private(set) var elements = [SNPathElement]()
    private var path = CGPathCreateMutable()
    private var segment = 0 as CGFloat
    private var anchor = CGPointZero // last anchor point
    private var last = CGPointZero // last touch point
    private var delta:CGPoint? // last movement to compare against to detect a sharp turn
    private var fEdge = true //either the begging or the turning point
    private var count = 0

    init(minSegment:CGFloat) {
        self.minSegment = minSegment
    }
    
    public mutating func start(pt:CGPoint) -> CGPath {
        path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, pt.x, pt.y)
        elements = [SNMove(x: pt.x, y: pt.y)]
        anchor = pt
        last = pt
        delta = nil
        fEdge = true
        segment = 0.0
        count = 0
        return path
    }

    public mutating func move(pt:CGPoint) -> CGPath? {
        var pathToReturn:CGPath?
        let (dx, dy) = (pt.x - last.x, pt.y - last.y)
        segment += sqrt(dx * dx + dy * dy)
        if segment > minSegment {
            if !fEdge {
                let ptMid = CGPointMake((anchor.x + pt.x) / 2.0, (anchor.y + pt.y) / 2.0)
                CGPathAddQuadCurveToPoint(path, nil, anchor.x, anchor.y, ptMid.x, ptMid.y)
                elements.append(SNQuadCurve(cpx: anchor.x, cpy: anchor.y, x: ptMid.x, y: ptMid.y))
                pathToReturn = path
            }
            delta = CGPointMake(pt.x - anchor.x, pt.y - anchor.y)
            anchor = pt
            fEdge = false
            segment = 0.0
            count = count + 1
        } else if let ptD = delta where ptD.x * dx + ptD.y * dy < 0 {
            print("Tight turn", count)
            CGPathAddQuadCurveToPoint(path, nil, anchor.x, anchor.y, last.x, last.y)
            elements.append(SNQuadCurve(cpx: anchor.x, cpy: anchor.y, x: last.x, y: last.y))
            pathToReturn = path
            anchor = pt
            delta = nil
            fEdge = true
            segment = 0.0
            count = count + 1
        } else {
            let pathTemp = CGPathCreateMutableCopy(path)
            CGPathAddLineToPoint(pathTemp, nil, pt.x, pt.y)
            pathToReturn = pathTemp
            delta = CGPointMake(pt.x - anchor.x, pt.y - anchor.y)
        }
        last = pt
        
        return pathToReturn
    }
    
    public mutating func end() -> CGPath {
        print("End", count)
        // NOTE: We intentionally ignore the last point to reduce the noise.
        CGPathAddQuadCurveToPoint(path, nil, anchor.x, anchor.y, last.x, last.y)
        elements.append(SNQuadCurve(cpx: anchor.x, cpy: anchor.y, x: last.x, y: last.y))
        return path
    }
}
