//
//  EdgeInsets.swift
//  
//
//  Created by nori on 2022/03/11.
//

import CoreGraphics
#if os(iOS)
import UIKit
typealias EdgeInsets = UIEdgeInsets
#else
import AppKit
struct EdgeInsets {

    public var top: CGFloat // specify amount to inset (positive) for each of the edges. values can be negative to 'outset'

    public var left: CGFloat

    public var bottom: CGFloat

    public var right: CGFloat

    public init() {
        self.top = 0
        self.left = 0
        self.bottom = 0
        self.right = 0
    }

    public init(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
    }
}

extension EdgeInsets: Equatable { }

extension EdgeInsets: Codable { }
#endif


