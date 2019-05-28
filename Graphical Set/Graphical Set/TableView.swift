//
//  TableView.swift
//  Graphical Set
//
//  Created by Anna Movsheva on 3/19/19.
//  Copyright © 2019 Anna Movsheva. All rights reserved.
//

import UIKit

@IBDesignable
class TableView: UIView {
    
    var selectedButtons = [Int]() {
        didSet {
            setNeedsDisplay();
            setNeedsLayout()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsDisplay()
        setNeedsLayout()
    }
    
    var buttonCards = [CardButton]() {
        didSet{
            grid.cellCount = buttonCards.count
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    
    lazy var grid = createGrid()
    
    func addButtonCard() -> CardButton {
        let button = CardButton()
        button.layer.borderWidth = 1.0
        button.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        button.backgroundColor = UIColor.clear
        button.isOpaque = false
        addSubview(button)
        buttonCards.append(button)
        return button
    }
    
    
    private func deleteThreeButtonCards() {
        for _ in 0..<3 {
            buttonCards.removeLast()
        }
    }
    
    private func createGrid() -> Grid {
        var grid = Grid(layout: Grid.Layout.aspectRatio(2.0), frame: bounds)
        grid.cellCount = buttonCards.count
        return grid
    }
    
    
    private func configureGrid() {
        grid.frame = bounds
    }
    
    func configureButtons() {
        for i in 0..<buttonCards.count {
            let button = buttonCards[i]
            button.frame.origin = grid[i]!.origin
            button.frame = grid[i]!.zoom(by: 0.9)
            if selectedButtons.contains(i) {
                button.cardColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            } else {
                button.cardColor = UIColor.white
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureGrid()
        configureButtons()
    }
    
}

extension Grid {
    private struct SizeRatio {
        static let cornerFontSizeToBoundsHeight: CGFloat = 0.085
        static let cornerRadiusToBoundHeight: CGFloat = 0.06
        static let cornerOffsetToCornerRadius: CGFloat = 0.33
        static let faceCardImageSizeToBoundSize: CGFloat = 0.75
    }
    var cornerRadius: CGFloat {
        return cellSize.height * SizeRatio.cornerRadiusToBoundHeight
    }
    var cornerOffset : CGFloat {
        return cornerRadius * SizeRatio.cornerOffsetToCornerRadius
    }
    var cornerFontSize: CGFloat {
        return cellSize.height * SizeRatio.cornerFontSizeToBoundsHeight
    }
    var faceCardImageSize: CGFloat {
        return cellSize.height * SizeRatio.faceCardImageSizeToBoundSize
    }
}

extension CGRect {
    var leftHalf: CGRect {
        return CGRect(x: minX, y: minY, width: width/2, height: height)
    }
    
    var rightHalf: CGRect {
        return CGRect(x: midX, y: minY, width: width/2, height: height)
    }
    func inset(by size: CGSize) -> CGRect {
        return insetBy(dx: size.width, dy: size.height)
    }
    func sized(to size: CGSize) -> CGRect {
        return CGRect(origin: origin, size: size)
    }
    func zoom(by scale: CGFloat) -> CGRect {
        let newWidth = width * scale
        let newHeight = height * scale
        return insetBy(dx: (width - newWidth)/2, dy: (height - newHeight)/2)
    }
}

extension CGPoint {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x+dx, y: y+dy)
    }
}
