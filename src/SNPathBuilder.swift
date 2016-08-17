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
    public private(set) var elements:[SNPathElement]
    
    private var path = CGPathCreateMutable()
    private var length = 0 as CGFloat
    private var anchor = CGPoint.zero // last anchor point
    private var last = CGPoint.zero // last touch point
    private var delta = CGPoint.zero // last movement to compare against to detect a sharp turn
    private var fEdge = true //either the begging or the turning point

    init(minSegment:CGFloat) {
        self.elements = [SNPathElement]()
        self.minSegment = minSegment
    }
    
    public mutating func start(pt:CGPoint) -> CGPath {
        path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, pt.x, pt.y)
        elements = [SNMove(x: pt.x, y: pt.y)]
        anchor = pt
        last = pt
        fEdge = true
        length = 0.0
        return path
    }

    public mutating func move(pt:CGPoint) -> CGPath? {
        var pathToReturn:CGPath?
        let (dx, dy) = (pt.x - last.x, pt.y - last.y)
        length += sqrt(dx * dx + dy * dy)
        if length > minSegment {
            // Detected enough movement. Add a quad segment, if we are not at the edge.
            if !fEdge {
                let ptMid = anchor.middle(pt)
                CGPathAddQuadCurveToPoint(path, nil, anchor.x, anchor.y, ptMid.x, ptMid.y)
                elements.append(SNQuadCurve(cpx: anchor.x, cpy: anchor.y, x: ptMid.x, y: ptMid.y))
                pathToReturn = path
            }
            delta = CGPointMake(pt.x - anchor.x, pt.y - anchor.y)
            anchor = pt
            fEdge = false
            length = 0.0
        } else if !fEdge && delta.x * dx + delta.y * dy < 0 {
            // Detected a "turning back". Add a quard segment, and turn on the fEdge flag.
            //print("Turning Back", elements.count)
            processLast()
            pathToReturn = path
            anchor = last // matter for delta in "Neither" case (does not matter for QuadCurve, see above)
            fEdge = true
            length = 0.0
        } else {
            // Neigher. Return the path with a line to the current point as a transient path.
            let pathTemp = CGPathCreateMutableCopy(path)
            CGPathAddLineToPoint(pathTemp, nil, pt.x, pt.y)
            pathToReturn = pathTemp
            delta = CGPointMake(pt.x - anchor.x, pt.y - anchor.y)
        }
        last = pt
        
        return pathToReturn
    }
    
    private mutating func processLast() {
        if !fEdge, let quad = elements.last as? SNQuadCurve {
            elements.removeLast()
            CGPathAddLineToPoint(path, nil, last.x, last.y) // HACK: Not accurate
            elements.append(SNQuadCurve(cp: quad.cp, pt: last))
        } else {
            CGPathAddQuadCurveToPoint(path, nil, anchor.x, anchor.y, last.x, last.y)
            elements.append(SNQuadCurve(cp: anchor, pt: last))
        }
    }
    
    public mutating func end() -> CGPath {
        processLast()
        return path
    }
}
