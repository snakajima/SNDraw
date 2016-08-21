//
//  SNPath.swift
//  SNDraw
//
//  Created by satoshi on 8/5/16.
//  Copyright © 2016 Satoshi Nakajima. All rights reserved.
//

import UIKit

extension CGPath {
    func forEach(@noescape body: @convention(block) (CGPathElement) -> Void) {
        typealias Body = @convention(block) (CGPathElement) -> Void
        func callback(info: UnsafeMutablePointer<Void>, element: UnsafePointer<CGPathElement>) {
            let body = unsafeBitCast(info, Body.self)
            body(element.memory)
        }
        let unsafeBody = unsafeBitCast(body, UnsafeMutablePointer<Void>.self)
        CGPathApply(self, unsafeBody, callback)
    }
}

extension CGPoint {
    func middle(from:CGPoint) -> CGPoint {
        return CGPoint(x: (self.x + from.x)/2, y: (self.y + from.y)/2)
    }

    func delta(from:CGPoint) -> CGPoint {
        return CGPoint(x: self.x - from.x, y: self.y - from.y)
    }
    
    func dotProduct(with:CGPoint) -> CGFloat {
        return self.x * with.x + self.y * with.y
    }
    
    func distance2(from:CGPoint) -> CGFloat {
        let delta = self.delta(from)
        return delta.dotProduct(delta)
    }
    
    func distance(from:CGPoint) -> CGFloat {
        return sqrt(self.distance2(from))
    }

    func translate(x:CGFloat, y:CGFloat) -> CGPoint {
        return CGPoint(x: self.x + x, y: self.y + y)
    }
}


public struct SNPath {
    static func pathFrom(elements:[SNPathElement]) -> CGMutablePath {
        return elements.reduce(CGPathCreateMutable()) { (path, element) -> CGMutablePath in
            return element.addToPath(path)
        }
    }
    
    static func polyPathFrom(elements:[SNPathElement]) -> CGMutablePath {
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

    static func elementsFrom(path:CGPath) -> [SNPathElement] {
        var elements = [SNPathElement]()
        path.forEach { e in
            switch(e.type) {
            case .MoveToPoint:
                elements.append(SNMove(pt: e.points[0]))
            case .AddLineToPoint:
                elements.append(SNLine(pt: e.points[0]))
            case .AddQuadCurveToPoint:
                elements.append(SNQuadCurve(cp: e.points[0], pt: e.points[1]))
            case .AddCurveToPoint:
                elements.append(SNBezierCurve(cp1: e.points[0], cp2: e.points[1], pt: e.points[2]))
            case .CloseSubpath:
                elements.append(SNCloseSubpath())
            }
        }
        return elements
    }
    
    static let regexSVG = try! NSRegularExpression(pattern: "[a-z][0-9\\-\\.,\\s]*", options: NSRegularExpressionOptions.CaseInsensitive)
    static let regexNUM = try! NSRegularExpression(pattern: "[\\-]*[0-9\\.]+", options: NSRegularExpressionOptions())
    static func elementsFrom(svg:String) -> [SNPathElement] {
        var elements = [SNPathElement]()
        var pt = CGPointZero
        var cp = CGPointZero // last control point for S command
        var prevIndex = svg.startIndex // for performance
        var prevOffset = 0
        let matches = SNPath.regexSVG.matchesInString(svg, options: NSMatchingOptions(), range: NSMakeRange(0, svg.characters.count))
        matches.forEach { match in
            var start = prevIndex.advancedBy(match.range.location - prevOffset)
            let cmd = svg[start..<start.advancedBy(1)]
            start = start.advancedBy(1)
            let end = start.advancedBy(match.range.length-1)
            prevIndex = end
            prevOffset = match.range.location + match.range.length
            
            let params = svg[start..<end]
            let nums = SNPath.regexNUM.matchesInString(params, options: [], range: NSMakeRange(0, params.characters.count))
            let p = nums.map({ (num) -> CGFloat in
                let start = params.startIndex.advancedBy(num.range.location)
                let end = start.advancedBy(num.range.length)
                return CGFloat((params[start..<end] as NSString).floatValue)
            })
            switch(cmd) {
            case "m":
                if p.count == 2 {
                    elements.append(SNMove(x: pt.x+p[0], y: pt.y+p[1]))
                    pt.x += p[0]
                    pt.y += p[1]
                }
            case "M":
                if p.count == 2 {
                    elements.append(SNMove(x: p[0], y: p[1]))
                    pt.x = p[0]
                    pt.y = p[1]
                }
            case "z", "Z":
                elements.append(SNCloseSubpath())
            case "c":
                var i = 0
                while(p.count >= i+6) {
                    elements.append(SNBezierCurve(cp1x: pt.x+p[i], cp1y: pt.y+p[i+1], cp2x: pt.x+p[i+2], cp2y: pt.y+p[i+3], x: pt.x+p[i+4], y: pt.y+p[i+5]))
                    cp.x = pt.x+p[i+2]
                    cp.y = pt.y+p[i+3]
                    pt.x += p[i+4]
                    pt.y += p[i+5]
                    i += 6
                }
            case "C":
                var i = 0
                while(p.count >= i+6) {
                    elements.append(SNBezierCurve(cp1x: p[i], cp1y: p[i+1], cp2x: p[i+2], cp2y: p[i+3], x: p[i+4], y: p[i+5]))
                    cp.x = p[i+2]
                    cp.y = p[i+3]
                    pt.x = p[i+4]
                    pt.y = p[i+5]
                    i += 6
                }
            case "q":
                var i = 0
                while(p.count >= i+4) {
                    elements.append(SNQuadCurve(cpx: pt.x+p[i], cpy: pt.y+p[i+1], x: pt.x+p[i+2], y: pt.y+p[i+3]))
                    cp.x = pt.x+p[i]
                    cp.y = pt.y+p[i+1]
                    pt.x += p[i+2]
                    pt.y += p[i+3]
                    i += 4
                }
            case "Q":
                var i = 0
                while(p.count >= i+4) {
                    elements.append(SNQuadCurve(cpx: p[i], cpy: p[i+1], x: p[i+2], y: p[i+3]))
                    cp.x = p[i]
                    cp.y = p[i+1]
                    pt.x = p[i+2]
                    pt.y = p[i+3]
                    i += 4
                }
            case "s":
                var i = 0
                while(p.count >= i+4) {
                    elements.append(SNBezierCurve(cp1x: pt.x * 2 - cp.x, cp1y: pt.y * 2 - cp.y, cp2x: pt.x+p[i], cp2y: pt.y+p[i+1], x: pt.x+p[i+2], y: pt.y+p[i+3]))
                    cp.x = pt.x + p[i]
                    cp.y = pt.y + p[i+1]
                    pt.x += p[i+2]
                    pt.y += p[i+3]
                    i += 4
                }
            case "S":
                var i = 0
                while(p.count >= i+4) {
                    elements.append(SNBezierCurve(cp1x: pt.x * 2 - cp.x, cp1y: pt.y * 2 - cp.y, cp2x: p[i], cp2y: p[i+1], x: p[i+2], y: p[i+3]))
                    cp.x = p[i]
                    cp.y = p[i+1]
                    pt.x = p[i+2]
                    pt.y = p[i+3]
                    i += 4
                }
            case "l":
                var i = 0
                while(p.count >= i+2) {
                    elements.append(SNLine(x: pt.x+p[i], y: pt.y+p[i+1]))
                    pt.x += p[i]
                    pt.y += p[i+1]
                    i += 2
                }
            case "L":
                var i = 0
                while(p.count >= i+2) {
                    elements.append(SNLine(x: p[i], y: p[i+1]))
                    pt.x = p[i]
                    pt.y = p[i+1]
                    i += 2
                }
            case "v":
                var i = 0
                while(p.count >= i+1) {
                    elements.append(SNLine(x: pt.x, y: pt.y+p[i]))
                    pt.y += p[i]
                    i += 1
                }
            case "V":
                var i = 0
                while(p.count >= i+1) {
                    elements.append(SNLine(x: pt.x, y: p[i]))
                    pt.y = p[i]
                    i += 1
                }
            case "h":
                var i = 0
                while(p.count >= i+1) {
                    elements.append(SNLine(x: pt.x+p[i], y: pt.y))
                    pt.x += p[i]
                    i += 1
                }
            case "H":
                var i = 0
                while(p.count >= i+1) {
                    elements.append(SNLine(x: p[i], y: pt.y))
                    pt.x = p[i]
                    i += 1
                }
            default:
                print("SNPath unsupported command", cmd)
                break
            }
        }
        return elements
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

public struct SNCloseSubpath:SNPathElement {
    public func addToPath(path:CGMutablePath) -> CGMutablePath {
        CGPathCloseSubpath(path)
        return path
    }
    public func svgString(prev:SNPathElement?) -> String {
        return "Z"
    }
    public func translatedElement(x:CGFloat, y:CGFloat) -> SNPathElement {
        return self
    }
}

public struct SNMove:SNPathElement {
    let pt:CGPoint
    init(x:CGFloat, y:CGFloat) {
        pt = CGPointMake(x,y)
    }
    init(pt:CGPoint) {
        self.pt = pt
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
    init(pt:CGPoint) {
        self.pt = pt
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
    init(cp:CGPoint, pt:CGPoint) {
        self.cp = cp
        self.pt = pt
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
    init(cp1:CGPoint, cp2:CGPoint, pt:CGPoint) {
        self.cp1 = cp1
        self.cp2 = cp2
        self.pt = pt
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

