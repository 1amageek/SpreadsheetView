//
//  Label.swift
//  
//
//  Created by nori on 2022/03/11.
//

#if os(iOS)
import UIKit
typealias Label = UILabel
#else
import AppKit
typealias Label = NSLabel
#endif

