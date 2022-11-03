//
//  BoundsPen.swift
//  FontPens
//
//  Created by David Schweinsberg on 8/3/20.
//  Copyright © 2020 David Schweinsberg. All rights reserved.
//

import CoreGraphics

func calcCubicParameters(_ pt1: CGPoint,
                         _ pt2: CGPoint,
                         _ pt3: CGPoint,
                         _ pt4: CGPoint) -> (CGPoint, CGPoint, CGPoint, CGPoint) {
  let dx = pt1.x
  let dy = pt1.y
  let cx = (pt2.x - dx) * 3.0
  let cy = (pt2.y - dy) * 3.0
  let bx = (pt3.x - pt2.x) * 3.0 - cx
  let by = (pt3.y - pt2.y) * 3.0 - cy
  let ax = pt4.x - dx - cx - bx
  let ay = pt4.y - dy - cy - by
  return (CGPoint(x: ax, y: ay),
          CGPoint(x: bx, y: by),
          CGPoint(x: cx, y: cy),
          CGPoint(x: dx, y: dy))
}

func solveQuadratic(a: CGFloat, b: CGFloat, c: CGFloat) -> [CGFloat] {
  let epsilon = 1e-10
  if fabs(Double(a)) < epsilon {
    if fabs(Double(b)) < epsilon {
      return []
    } else {
      return [-c / b];
    }
  } else {
    let dd = b * b - 4.0 * a * c
    if dd >= 0.0 {
      let rdd = sqrt(dd)
      return [(-b + rdd) / 2.0 / a, (-b - rdd) / 2.0 / a]
    } else {
      return []
    }
  }
}

func calcCubicPoints(pt1: CGPoint,
                     pt2: CGPoint,
                     pt3: CGPoint,
                     pt4: CGPoint,
                     point: (CGPoint) -> Void) {

  let (a, b, c, d) = calcCubicParameters(pt1, pt2, pt3, pt4);

  // Calculate first derivative
  let ax3 = a.x * 3.0
  let ay3 = a.y * 3.0
  let bx2 = b.x * 2.0
  let by2 = b.y * 2.0

  let xRoots = solveQuadratic(a: ax3, b: bx2, c: c.x)
  var roots = xRoots.filter { 0.0 <= $0 && $0 < 1.0 }

  let yRoots = solveQuadratic(a: ay3, b: by2, c: c.y)
  roots += yRoots.filter { 0.0 <= $0 && $0 < 1.0 }

  point(pt1);
  point(pt4);
  for t in roots {
    point(CGPoint(x: a.x * t * t * t + b.x * t * t + c.x * t + d.x,
                  y: a.y * t * t * t + b.y * t * t + c.y * t + d.y))
  }
}

public class BoundsPen: Pen {

  var bounds = CGRect.null
  private var currentPoint = CGPoint.zero

  func add(point: CGPoint) {
    if bounds == .null {
      bounds = CGRect(x: point.x, y: point.y, width: 0, height: 0)
    } else if !bounds.contains(point) {
      bounds = bounds.union(CGRect(x: point.x, y: point.y, width: 0, height: 0))
    }
    currentPoint = point
  }

  public func move(to point: CGPoint) {
    add(point: point);
  }

  public func line(to point: CGPoint) {
    add(point: point);
  }

  func curve(to point: CGPoint, control1: CGPoint, control2: CGPoint) {
    calcCubicPoints(pt1: currentPoint, pt2: control1, pt3: control2, pt4: point) {
      (pt: CGPoint) in self.add(point: pt)
    }
  }

  func qCurve(to point: CGPoint, control: CGPoint) {

  }

  public func curve(to points: [CGPoint]) {
    if points.count == 3 {
      curve(to: points[2], control1: points[0], control2: points[1])
    } else if points.count == 2 {
      qCurve(to: points[1], control: points[0])
    } else if points.count == 1 {
      line(to: points[0])
    }
  }

  public func qCurve(to: [CGPoint]) { }

  public func closePath() { }

  public func endPath() { }

  public func addComponent(name: String, transformation: CGAffineTransform) throws { }
}
