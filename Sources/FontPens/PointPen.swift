//
//  PointPen.swift
//  FontPens
//
//  Created by David Schweinsberg on 12/18/17.
//  Copyright © 2017 David Schweinsberg. All rights reserved.
//

import Foundation

public enum SegmentType: CustomStringConvertible {
  case move
  case line
  case offCurve
  case curve
  case qCurve

  public var description: String {
    switch self {
    case .move:
      return "move"
    case .line:
      return "line"
    case .offCurve:
      return "offcurve"
    case .curve:
      return "curve"
    case .qCurve:
      return "qcurve"
    }
  }
}

public protocol PointPen {
  mutating func beginPath(identifier: String?) throws
  mutating func endPath() throws
  mutating func addPoint(_ pt: CGPoint, segmentType: SegmentType, smooth: Bool, name: String?, identifier: String?) throws
  mutating func addComponent(baseGlyphName: String, transformation: CGAffineTransform, identifier: String?) throws
}
