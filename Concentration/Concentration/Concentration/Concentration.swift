//
//  Concentration.swift
//  Concentration
//
//  Created by Anna Movsheva on 2/11/19.
//  Copyright © 2019 Anna Movsheva. All rights reserved.
//

import Foundation

class Concentration
{
    private(set) var cards = [Card]()
    
    private(set) var flipCount = 0
    
    private(set) var score = 0.0
    
    private var timeOfFlip: Date?
    
    private var indexOfOneAndOnlyFaceUpCard: Int? {
        get {
            return cards.indices.filter { cards[$0].isFaceUp }.oneAndOnly
        }
        set {
            for index in cards.indices {
                cards[index].isFaceUp = (index == newValue)
            }
        }
    }
    
    init(numberOfPairsOfCards: Int) {
        assert(numberOfPairsOfCards > 0, "Concentration.init(at: \(String(describing: index))): you must have at least one pair of cards")
        for _ in 1...numberOfPairsOfCards {
            let card = Card()
            cards += [card, card]
        }
        var shuffledCards = [Card]()
        for _ in 1...(numberOfPairsOfCards * 2) {
            let randomIndex = Int(arc4random_uniform(UInt32(cards.count)))
            shuffledCards.append(cards.remove(at: randomIndex))
        }
        cards = shuffledCards
    }
    
    func chooseCard(at index: Int) {
        assert(cards.indices.contains(index), "Concentration.chooseCard(at: \(index)): chosen index not in the cards")
        if !cards[index].isMatched {
            if let matchIndex = indexOfOneAndOnlyFaceUpCard {
                let dateNow = Date()
                let timeIntervalSinceFirstFlip = dateNow.timeIntervalSince(timeOfFlip!)
                if matchIndex != index {
                    flipCount += 1
                    if cards[matchIndex] == cards[index] {
                        cards[matchIndex].isMatched = true
                        cards[index].isMatched = true
                        score += 10 * 2.0 / timeIntervalSinceFirstFlip
                    } else {
                        if cards[index].pickedUp {
                            score -= 1.0 * timeIntervalSinceFirstFlip
                        }
                        if cards[matchIndex].pickedUp {
                            score -= 1.0 * timeIntervalSinceFirstFlip
                        }
                    }
                    cards[index].isFaceUp = true
                }
                cards[index].pickedUp = true
                cards[matchIndex].pickedUp = true
            } else {
                flipCount += 1
                indexOfOneAndOnlyFaceUpCard = index
                timeOfFlip = Date()
            }
        }
    }
    
    func reset() {
        for index in cards.indices {
            cards[index].isFaceUp = false
            cards[index].isMatched = false
            cards[index].pickedUp = false
            flipCount = 0
            score = 0
        }
    }
}

extension Collection {
    var oneAndOnly: Element? {
        return count == 1 ? first : nil
    }
}
