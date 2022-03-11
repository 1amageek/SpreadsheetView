//
//  Color.swift
//  
//
//  Created by nori on 2022/03/11.
//

#if os(iOS)
import UIKit
typealias Color = UIColor
#else
import AppKit
typealias Color = NSColor
#endif

