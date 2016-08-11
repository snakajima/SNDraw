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
        return elements.reduce(CGPathCreateMutable()) { (path, element) -> CGMutablePath in
            return element.addToPath(path)
        }
    }
    
    static func polyPathFrom(elements:[SNPathElement]) -> CGPath {
        return elements.reduce(CGPathCreateMutable()) { (path, element) -> CGMutablePath in
            return element.addToPathAsPolygon(path)
        }
    }
    
    static func svgFrom(elements:[SNPathElement]) -> String {
        var prev:SNPathElement? = nil
        return elements.reduce("") { (svn, element) -> String in
            defer { prev = element }
            return svn + element.svgString(prev)
        }
    }
}

public protocol SNPathElement {
    func addToPath(path:CGMutablePath) -> CGMutablePath
    func addToPathAsPolygon(path:CGMutablePath) -> CGMutablePath
    func svgString(prev:SNPathElement?) -> String
    func translatedElement(x:CGFloat, y:CGFloat) -> SNPathElement
}

extension SNPathElement {
    public func addToPathAsPolygon(path:CGMutablePath) -> CGMutablePath {
        return addToPath(path)
    }
}

public struct SNMove:SNPathElement {
    let pt:CGPoint
    init(x:CGFloat, y:CGFloat) {
        pt = CGPointMake(x,y)
    }
    
    public func addToPath(path:CGMutablePath) -> CGMutablePath {
        CGPathMoveToPoint(path, nil, pt.x, pt.y)
        return path
    }
    
    public func svgString(_:SNPathElement?) -> String {
        return "M\(pt.x),\(pt.y)"
    }

    public func translatedElement(x:CGFloat, y:CGFloat) -> SNPathElement {
        return SNMove(x: pt.x + x, y: pt.y + y)
    }
}

public struct SNLine:SNPathElement {
    let pt:CGPoint
    init(x:CGFloat, y:CGFloat) {
        pt = CGPointMake(x,y)
    }

    public func addToPath(path:CGMutablePath) -> CGMutablePath {
        CGPathAddLineToPoint(path, nil, pt.x, pt.y)
        return path
    }

    public func svgString(prev:SNPathElement?) -> String {
        let prefix = prev is SNLine ? " " : "L"
        return "\(prefix)\(pt.x),\(pt.y)"
    }

    public func translatedElement(x:CGFloat, y:CGFloat) -> SNPathElement {
        return SNLine(x: pt.x + x, y: pt.y + y)
    }
}

public struct SNQuadCurve:SNPathElement {
    let cp:CGPoint
    let pt:CGPoint
    init(cpx: CGFloat, cpy: CGFloat, x: CGFloat, y: CGFloat) {
        cp = CGPointMake(cpx, cpy)
        pt = CGPointMake(x, y)
    }

    public func addToPath(path:CGMutablePath) -> CGMutablePath {
        CGPathAddQuadCurveToPoint(path, nil, cp.x, cp.y, pt.x, pt.y)
        return path
    }

    public func addToPathAsPolygon(path:CGMutablePath) -> CGMutablePath {
        CGPathAddLineToPoint(path, nil, cp.x, cp.y)
        CGPathAddLineToPoint(path, nil, pt.x, pt.y)
        return path
    }

    public func svgString(prev:SNPathElement?) -> String {
        let prefix = prev is SNQuadCurve ? " " : "Q"
        return "\(prefix)\(cp.x),\(cp.y),\(pt.x),\(pt.y)"
    }

    public func translatedElement(x:CGFloat, y:CGFloat) -> SNPathElement {
        return SNQuadCurve(cpx: cp.x + x, cpy: cp.y + y, x: pt.x + x, y: pt.y + y)
    }
}

public struct SNBezierCurve:SNPathElement {
    let cp1:CGPoint
    let cp2:CGPoint
    let pt:CGPoint
    init(cp1x: CGFloat, cp1y: CGFloat, cp2x: CGFloat, cp2y: CGFloat,x: CGFloat, y: CGFloat) {
        cp1 = CGPointMake(cp1x, cp1y)
        cp2 = CGPointMake(cp2x, cp2y)
        pt = CGPointMake(x, y)
    }

    public func addToPath(path:CGMutablePath) -> CGMutablePath {
        CGPathAddCurveToPoint(path, nil, cp1.x, cp1.y, cp2.x, cp2.y, pt.x, pt.y)
        return path
    }

    public func addToPathAsPolygon(path:CGMutablePath) -> CGMutablePath {
        CGPathAddLineToPoint(path, nil, cp1.x, cp1.y)
        CGPathAddLineToPoint(path, nil, cp2.x, cp2.y)
        CGPathAddLineToPoint(path, nil, pt.x, pt.y)
        return path
    }

    public func svgString(prev:SNPathElement?) -> String {
        let prefix = prev is SNBezierCurve ? " " : "C"
        return "\(prefix)\(cp1.x),\(cp1.y),\(cp2.x),\(cp2.y)\(pt.x),\(pt.y)"
    }

    public func translatedElement(x:CGFloat, y:CGFloat) -> SNPathElement {
        return SNBezierCurve(cp1x: cp1.x + x, cp1y: cp1.y + y, cp2x: cp2.x + x, cp2y: cp2.y + y, x: pt.x + x, y: pt.y + y)
    }
}

