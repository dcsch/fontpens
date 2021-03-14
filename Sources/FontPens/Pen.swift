//
//  Pen.swift
//  FontPens
//
//  Created by David Schweinsberg on 8/3/20.
//  Copyright © 2020 David Schweinsberg. All rights reserved.
//

import Foundation

public protocol Pen {
  mutating func move(to: CGPoint)
  mutating func line(to: CGPoint)
  mutating func curve(to: [CGPoint])
  mutating func qCurve(to: [CGPoint])
  mutating func closePath()
  mutating func endPath()
  mutating func addComponent(name: String, transformation: CGAffineTransform) throws
}
