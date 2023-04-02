//
//  QuartzPen.swift
//  FontPens
//
//  Created by David Schweinsberg on 3/13/21.
//  Copyright © 2021 David Schweinsberg. All rights reserved.
//

import CoreGraphics

public protocol GlyphComponents {
  func readGlyph<T: PointPen>(glyphName: String, pointPen: inout T) throws
}

struct Point {
  var pt: CGPoint
  var type: SegmentType
  var smooth: Bool
  var name: String?
  var identifier: String?
}

public struct QuartzPen: PointPen {
  public let path = CGMutablePath()
  var points = [Point]()
  let glyphComponents: GlyphComponents

  public init(glyphComponents: GlyphComponents) {
    self.glyphComponents = glyphComponents
  }

  public func beginPath(identifier: String?) throws {
  }

  public mutating func endPath() throws {

    // Duplicate points from the beginning of the contour to the end
    // to simplify interating completely through all the points
    var pointsToDuplicate = [Point]()
    for point in points {
      pointsToDuplicate.append(point)
      if point.type != .offCurve {
        break
      }
    }
    points.append(contentsOf: pointsToDuplicate)

    var curvePoints = [Point]()
    for (n, point) in points.enumerated() {
      if n == 0 || point.type == .move {
        assert(curvePoints.count == 0)
        path.move(to: point.pt)
        curvePoints.removeAll()
      } else if point.type == .offCurve {
        curvePoints.append(point)
      } else if point.type == .line {
        assert(curvePoints.count == 0)
        path.addLine(to: point.pt)
        curvePoints.removeAll()
      } else if point.type == .curve {
        if curvePoints.count == 0 {
          path.addLine(to: point.pt)
        } else if curvePoints.count == 1 {
          path.addQuadCurve(to: point.pt, control: curvePoints[0].pt)
        } else if curvePoints.count == 2 {
          path.addCurve(to: point.pt,
                        control1: curvePoints[0].pt,
                        control2: curvePoints[1].pt)
        } else {
          // Error
        }
        curvePoints.removeAll()
      } else if point.type == .qCurve {
        curvePoints.append(point)
        var previousPt = CGPoint(x: 0, y: 0)
        for (n, qpoint) in curvePoints.enumerated() {
          if n > 0 {
            if qpoint.type == .qCurve {
              path.addQuadCurve(to: qpoint.pt, control: previousPt)
            } else {
              path.addQuadCurve(to: QuartzPen.midPoint(previousPt, qpoint.pt),
                                control: previousPt)
            }
          }
          previousPt = qpoint.pt
        }
        curvePoints.removeAll()
      }
    }
    points.removeAll()
  }

  public mutating func addPoint(_ pt: CGPoint,
                       segmentType: SegmentType,
                       smooth: Bool = false,
                       name: String? = nil,
                       identifier: String? = nil) throws {
    points.append(Point(pt: pt, type: segmentType, smooth: smooth, name: name, identifier: identifier))
  }

  public mutating func addComponent(baseGlyphName: String, transformation: CGAffineTransform, identifier: String?) throws {
    var componentPen = QuartzPen(glyphComponents: glyphComponents)
    try glyphComponents.readGlyph(glyphName: baseGlyphName, pointPen: &componentPen)
    path.addPath(componentPen.path, transform: transformation)
  }

  private static func midPoint(_ a: CGPoint, _ b: CGPoint) -> CGPoint {
    return CGPoint(x: a.x + (b.x - a.x) / 2.0,
                   y: a.y + (b.y - a.y) / 2.0)
  }

}
