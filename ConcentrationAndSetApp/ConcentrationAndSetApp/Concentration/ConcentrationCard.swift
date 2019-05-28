//
//  Card.swift
//  Concentration
//
//  Created by Anna Movsheva on 2/11/19.
//  Copyright © 2019 Anna Movsheva. All rights reserved.
//

import Foundation

struct ConcentrationCard: Hashable
{
    //var hashValue: Int { return identifier }
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: ConcentrationCard, rhs: ConcentrationCard) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    var isFaceUp = false
    var isMatched = false
    var pickedUp = false
    private var identifier: Int
    
    private static var identifierFactory = 0
    
    private static func getUniqueIdentifier() -> Int {
        identifierFactory += 1
        return identifierFactory
    }
    
    init() {
        self.identifier = ConcentrationCard.getUniqueIdentifier()
    }
    
}
