//
//  CardButton.swift
//  Graphical Set
//
//  Created by Anna Movsheva on 3/22/19.
//  Copyright © 2019 Anna Movsheva. All rights reserved.
//

import UIKit

class CardButton: UIView {
    
    
    var number : Int = -1 { didSet{ setNeedsDisplay(); setNeedsLayout() } }
    var pattern : Int = -1 { didSet{ setNeedsDisplay(); setNeedsLayout() } }
    var color : Int = -1 { didSet{ setNeedsDisplay(); setNeedsLayout() } }
    var shape : Int = -1 { didSet{ setNeedsDisplay(); setNeedsLayout() } }
    var cardColor : UIColor = UIColor.white {
        didSet{ setNeedsDisplay(); setNeedsLayout() }
    }
    var faceUp = true { didSet{ setNeedsDisplay() } }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsDisplay()
        setNeedsLayout()
    }
    
    func identicalCard() -> CardButton {
        let button = CardButton()
        button.number = number
        button.pattern = pattern
        button.color = color
        button.shape = shape
        button.cardColor = UIColor.white
        return button
    }
    
    override func draw(_ rect: CGRect) {
        if faceUp {
            let context = UIGraphicsGetCurrentContext()!
            let roundedRect = UIBezierPath(roundedRect: bounds,
                                           cornerRadius: cornerRadius)
            cardColor.setFill()
            roundedRect.fill()
            layer.cornerRadius = cornerRadius
            var path : UIBezierPath
            path = [diamond(), oval(), squiggle(), circle()][shape]
            colorLit.setStroke()
            path.lineWidth = lineThickness
            repeatShape(for: path)
            let pathOverLay = UIBezierPath(cgPath: path.cgPath)
            context.saveGState()
            setPattern(for: path)
            path.addClip()
            path.stroke()
            context.restoreGState()
            pathOverLay.lineWidth = lineThickness
            pathOverLay.stroke()
        } else {
            let roundedRect = UIBezierPath(roundedRect: bounds,
                                           cornerRadius: cornerRadius)
            UIColor.white.setFill()
            roundedRect.fill()
            layer.cornerRadius = cornerRadius
        }
    }
    
    func repeatShape(for path: UIBezierPath) {
        if number == 1 {
            let path2 = UIBezierPath(cgPath: path.cgPath)
            path2.apply(CGAffineTransform.identity
                .translatedBy(x: bounds.width/6, y: 0.0))
            path.apply(CGAffineTransform.identity
                .translatedBy(x: -bounds.width/6, y: 0.0))
            path.append(path2)
        } else if number == 2 {
            let path2 = UIBezierPath(cgPath: path.cgPath)
            let path3 = UIBezierPath(cgPath: path.cgPath)
            path2.apply(CGAffineTransform.identity
                .translatedBy(x: bounds.width/4, y: 0.0))
            path3.apply(CGAffineTransform.identity
                .translatedBy(x: -bounds.width/4, y: 0.0))
            path.append(path2)
            path.append(path3)
        }
    }
    
    func setPattern(for path: UIBezierPath) {
        if pattern == 1 {
            for i in 0..<10 {
                path.move(to: CGPoint(x: bounds.minX,
                                      y: bounds.minY + CGFloat(i) * bounds.height/10))
                path.addLine(to: CGPoint(x: bounds.maxX,
                                         y: bounds.minY + CGFloat(i) * bounds.height/10))
            }
        } else if pattern == 2 {
            colorLit.setFill()
            path.fill()
        }
    }
    
    func diamond() -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.midX,
                              y: bounds.midY - bounds.midY/2))
        path.addLine(to: CGPoint(x: bounds.midX + bounds.midX/8,
                                 y: bounds.height/2))
        path.addLine(to: CGPoint(x: bounds.width/2,
                                 y: bounds.midY + bounds.midY/2))
        path.addLine(to: CGPoint(x: bounds.midX - bounds.midX/8,
                                 y: bounds.midY))
        path.close()
        return path
    }
    
    func oval() -> UIBezierPath {
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: bounds.midX,
                                        y: bounds.midY - bounds.midY/4),
                    radius: bounds.midY/4, startAngle: CGFloat.pi,
                    endAngle: 2*CGFloat.pi, clockwise: true)
        path.addArc(withCenter: CGPoint(x: bounds.midX,
                                        y: bounds.midY + bounds.midY/4),
                    radius: bounds.midY/4, startAngle: 0, endAngle: CGFloat.pi,
                    clockwise: true)
        path.close()
        return path
    }
    
    func squiggle() -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 104.0, y: 15.0))
        path.addCurve(to: CGPoint(x: 63.0, y: 54.0),
                      controlPoint1: CGPoint(x: 112.4, y: 36.9),
                      controlPoint2: CGPoint(x: 89.7, y: 60.8))
        path.addCurve(to: CGPoint(x: 27.0, y: 53.0),
                      controlPoint1: CGPoint(x: 52.3, y: 51.3),
                      controlPoint2: CGPoint(x: 42.2, y: 42.0))
        path.addCurve(to: CGPoint(x: 5.0, y: 40.0),
                      controlPoint1: CGPoint(x: 9.6, y: 65.6),
                      controlPoint2: CGPoint(x: 5.4, y: 58.3))
        path.addCurve(to: CGPoint(x: 36.0, y: 12.0),
                      controlPoint1: CGPoint(x: 4.6, y: 22.0),
                      controlPoint2: CGPoint(x: 19.1, y: 9.7))
        path.addCurve(to: CGPoint(x: 89.0, y: 14.0),
                      controlPoint1: CGPoint(x: 59.2, y: 15.2),
                      controlPoint2: CGPoint(x: 61.9, y: 31.5))
        path.addCurve(to: CGPoint(x: 104.0, y: 15.0),
                      controlPoint1: CGPoint(x: 95.3, y: 10.0),
                      controlPoint2: CGPoint(x: 100.9, y: 6.9))
        path.apply(CGAffineTransform.identity
            .translatedBy(x: -path.bounds.midX,
                          y: -path.bounds.midY))
        path.apply(CGAffineTransform.identity
            .translatedBy(x: bounds.midX, y: bounds.midY)
            .rotated(by: CGFloat.pi/2)
            .scaledBy(x: bounds.midY/path.bounds.size.height/2,
                      y: bounds.midY/path.bounds.size.height/2))
        return path
    }
    
    
    func circle() -> UIBezierPath {
        let path = UIBezierPath()
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        path.addArc(withCenter: center, radius: bounds.height / 4,
                    startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
        return path
    }
}

extension CardButton {
    private struct SizeRatio {
        static let cornerFontSizeToBoundsHeight: CGFloat = 0.085
        static let cornerRadiusToBoundHeight: CGFloat = 0.06
        static let cornerOffsetToCornerRadius: CGFloat = 0.33
        static let faceCardImageSizeToBoundSize: CGFloat = 0.75
        static let lineThicknessToBoundSize: CGFloat = 0.03
    }
    var lineThickness: CGFloat {
        return bounds.height * SizeRatio.lineThicknessToBoundSize
    }
    var cornerRadius: CGFloat {
        return bounds.height * SizeRatio.cornerRadiusToBoundHeight
    }
    var cornerOffset : CGFloat {
        return cornerRadius * SizeRatio.cornerOffsetToCornerRadius
    }
    var cornerFontSize: CGFloat {
        return bounds.height * SizeRatio.cornerFontSizeToBoundsHeight
    }
    var faceCardImageSize: CGFloat {
        return bounds.height * SizeRatio.faceCardImageSizeToBoundSize
    }
    private var colorLit: UIColor {
        switch color {
        case 0: return #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        case 1: return #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        case 2: return #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        default: return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
}
