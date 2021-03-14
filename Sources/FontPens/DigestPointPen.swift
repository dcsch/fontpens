//
//  DigestPointPen.swift
//  FontPens
//
//  Created by David Schweinsberg on 3/13/21.
//  Copyright © 2021 David Schweinsberg. All rights reserved.
//

import Foundation

public struct DigestPointPen: PointPen {

  public enum DigestEntry: Equatable {
    case beginPath(String?)
    case endPath
    case point(CGPoint, SegmentType, Bool, String?, String?)
    case component(String, CGAffineTransform, String?)
  }
  
  public var digest = [DigestEntry]()
  
  public mutating func beginPath(identifier: String?) {
    digest.append(.beginPath(identifier))
  }
  public mutating func endPath() {
    digest.append(.endPath)
  }
  public mutating func addPoint(_ pt: CGPoint, segmentType: SegmentType, smooth: Bool, name: String? = nil, identifier: String? = nil) {
    digest.append(.point(pt, segmentType, smooth, name, identifier))
  }
  public mutating func addComponent(baseGlyphName: String, transformation: CGAffineTransform, identifier: String?) {
    digest.append(.component(baseGlyphName, transformation, identifier))
  }
}
