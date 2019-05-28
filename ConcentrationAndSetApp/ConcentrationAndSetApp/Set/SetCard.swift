//
//  SetCard.swift
//  Animated Set
//
//  Created by Anna Movsheva on 4/10/19.
//  Copyright © 2019 Anna Movsheva. All rights reserved.
//

import Foundation

struct SetCard: Equatable, CustomStringConvertible
{
    /// Returns a string representation of the card
    var description: String { return "\((number, pattern, color, shape))" }
    
    /**
     Returns whether the two input cards are equal to one another
     
     - Parameters:
     - lhs: the card on the left hand side of the == sign.
     - rhs: the card on the right hand side of the == sign.
     
     - Returns: A boolean indicating whether the two cards are equal
     */
    static func == (lhs: SetCard, rhs: SetCard) -> Bool {
        for index in 0..<lhs.attributes.count {
            if !(lhs.attributes[index] == rhs.attributes[index]) {
                return false
            }
        }
        return true
    }
    
    /// The number of shapes on the card.
    let number: Attributes
    /// The pattern inside the shapes on the card.
    let pattern: Attributes
    /// The color of the shapes on the card.
    let color: Attributes
    /// The shapes on the card.
    let shape: Attributes
    /// The list of above attributes.
    let attributes: [Attributes]
    
    /**
     Creates a card with the specified shapes, number of shapes, pattern inside
     the shapes, and color of the shapes.
     
     - Parameters:
     - number: An interger from 0 to 2, representing 1 - 3 shapes on the
     card, respectively
     - pattern: An integer from 0 to 2, representing three types of distinct
     patterns (shaded, solid, empty)
     - color: An integer from 0 to 2, representing three different color
     - shape: An integer from 0 to 2, representing three different shapes
     */
    init(number n: Int, pattern p: Int, color c: Int, shape s: Int) {
        
        number = Attributes.number(id: n)
        pattern = Attributes.pattern(id: p)
        color = Attributes.color(id: c)
        shape = Attributes.shape(id: s)
        
        attributes = [number, pattern, color, shape]
    }
    
    
    /**
     Contains enum objects for number, color, pattern, and shape.
     */
    enum Attributes: Equatable, CustomStringConvertible {
        
        /// Returns a string that represents the attribute, like name of color,
        /// a number for the number attribute, a shape string for the shape
        /// attribute, or pattern name for the pattern attribute.
        var description: String {
            switch self {
            case .number(let n): return "\(n + 1)"
            case .color(let c): return ["red", "blue", "green"][c]
            case .pattern(let p): return ["outline", "solid", "shaded"][p]
            case .shape(let s): return ["●", "▲", "■"][s]
            }
        }
        
        /// The number attribute of the card where id attribute can be 0-2
        case number(id: Int)
        /// The color attribute of the card where id attribute can be 0-2
        case color(id: Int)
        /// The pattern attribute of the card where id attribute can be 0-2
        case pattern(id: Int)
        /// The shape attribute of the card where id attribute can be 0-2
        case shape(id: Int)
        
        /// List of all possible types of number attributes
        static var allNumber = [number(id: 0), number(id: 1), number(id: 2)]
        /// List of all possible types of color attributes
        static var allColor = [color(id: 0), color(id: 1), color(id: 2)]
        /// List of all possible types of pattern attributes
        static var allPattern = [pattern(id: 0), pattern(id: 1), pattern(id: 2)]
        /// List of all possible types of shape attributes
        static var allShape = [shape(id: 0), shape(id: 1), shape(id: 2)]
        
        /**
         Determines if the two attributes are equal to one another
         - Parameters:
         - lhs: The attribute on the left hand side of the == sign
         - rhs: The attribute on the right hand side of the == sign
         
         - Returns: A boolean that indicates wether the two attributes are equal
         to one another.
         */
        static func == (lhs: Attributes, rhs: Attributes) -> Bool {
            switch (lhs, rhs) {
            case (.number(let id1), .number(let id2)): return id1 == id2
            case (.color(let id1), .color(let id2)): return id1 == id2
            case (.pattern(let id1), .pattern(let id2)): return id1 == id2
            case (.shape(let id1), .shape(let id2)): return id1 == id2
            default: return false
            }
        }
    }
}
