//
//  SNPath.swift
//  SNDraw
//
//  Created by satoshi on 8/5/16.
//  Copyright © 2016 Satoshi Nakajima. All rights reserved.
//

import UIKit

public protocol SNPathElement {
}

public struct SNMove:SNPathElement {
    let pt:CGPoint
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
