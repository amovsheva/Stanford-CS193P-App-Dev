//
//  Set.swift
//  Set
//
//  Created by Anna Movsheva on 4/10/19.
//  Copyright © 2019 Anna Movsheva. All rights reserved.
//

import Foundation

class Set
{
    private(set) var deck = [SetCard]()
    
    private(set) var shownCards = [SetCard]()
    
    private(set) var selectedCards = [SetCard]()
    
    private(set) var matchedCards = [SetCard]()
    
    var unmatchedShownCards : [SetCard] {
        if deck.count > 0 { return shownCards }
        else {
            return shownCards.filter { !matchedCards.contains($0) }
        }
    }
    
    private(set) var playerScore1 = 0.0
    
    private(set) var playerScore2 = 0.0
    
    private var timeSinceLastMatch: Date
    
    private(set) var isTwoPlayer : Bool
    
    
    
    /**
     Creates the Set game, with the standard Set deck, with 12 cards dealt.
     
     - Parameter isPhonePlaying: whether the game is against the phone or single
     player game.
     */
    
    init(isPhonePlaying: Bool) {
        self.isTwoPlayer = isPhonePlaying
        timeSinceLastMatch = Date()
        for n in 0...2 {
            for p in 0...2 {
                for c in 0...2 {
                    for s in 0...2 {
                        deck.append(SetCard(number: n, pattern: p, color: c,
                                            shape: s))
                    }
                }
            }
        }
        for _ in 1...12 {
            shownCards.append(deck.remove(at: deck.count.arc4random))
        }
    }
    
    
    /**
     Draws three more cards from the deck and adds them to the table (replacing
     the selected cards if they make a set). If the user is calling this method
     and there are still available sets on the table for capture, they get
     penalized. If there are a selected cards that make a set, a reward goes to
     who ever calls this method (phone or player).
     
     - Parameter isPlayer: whether the method is called by the user (true) or
     the phone (false)
     */
    public func drawThreeMoreCards(isPlayer: Bool) {
        if isSet(cards: selectedCards) {
            if isPlayer {
                let timeNow = Date()
                let timeItTookToMatch = Double(
                    timeNow.timeIntervalSince(timeSinceLastMatch))
                playerScore1 += 10.0 / timeItTookToMatch
                timeSinceLastMatch = timeNow
            } else {
                playerScore2 += 1
            }
            matchedCards += selectedCards
            if deck.count > 0 {
                for sCard in selectedCards {
                    let index = shownCards.firstIndex(of: sCard)!
                    shownCards[index] = deck.remove(at: deck.count.arc4random)
                }
            }
        } else {
            let set = setLeft()
            if set != nil, isPlayer {
                playerScore1 -= 3
            }
            for _ in 1...3 {
                let newCard = deck.remove(at: deck.count.arc4random)
                shownCards.append(newCard)
            }
        }
        selectedCards = [SetCard]()
    }
    
    /**
     Selects the card if it wasn't previously selected, otherwise deselects it,
     penalizing the player in the processes. If there are selected cards that
     make up a set before the selection, they are removed (and replaced by new
     ones if possible) and the player is rewarded with points. In this case, if
     the card selected was one other previously selected cards, no
     card is selected as a result, otherwise the chosen card is selected.
     
     Only used by player, not phone in "play against phone" mode.
     
     - Parameter card: The card being chosen.
     
     - Returns: A boolean that indicates whether a set has been claimed as a
     result of this selection (true if claimed, false if not).
     */
    public func selection(of card: SetCard) -> Bool {
        if selectedCards.count < 3,
            let indexRemove = selectedCards.firstIndex(of: card) {
            selectedCards.remove(at: indexRemove)
            playerScore1 -= 1
            return false
        } else if selectedCards.count == 3 {
            if isSet(cards: selectedCards) {
                let contained = selectedCards.contains(card)
                drawThreeMoreCards(isPlayer: true)
                if !contained {
                    selectedCards = [card]
                }
                return true
            } else {
                selectedCards = [card]
                playerScore1 -= 3
                return false
            }
        } else {
            selectedCards.append(card)
            return false
        }
    }
    
    public func shuffle() {
        for i in 0..<shownCards.count {
            let randIndex = (shownCards.count - i).arc4random + i
            let card1 = shownCards[i]
            let card2 = shownCards[randIndex]
            shownCards[i] = card2
            shownCards[randIndex] = card1
        }
    }
    
    /**
     Indicates whether the input cards make up a set.
     
     - Parameter cards: A list of cards that are being considered for a set.
     
     - Returns: A boolean that indicates whether the input cards make up a set.
     */
    public func isSet(cards: [SetCard]) -> Bool {
        if cards.count != 3 {
            return false
        }
        var makesSet: (SetCard.Attributes, SetCard.Attributes, SetCard.Attributes) -> Bool
        var eq: (SetCard.Attributes, SetCard.Attributes) -> Int
        eq = { ($0 == $1).int }
        makesSet = { (eq($0, $1) + eq($0, $2) + eq($1, $2)) % 3 == 0  }
        let card0 = cards[0]
        let card1 = cards[1]
        let card2 = cards[2]
        for index in 0...3 {
            if !makesSet(card0.attributes[index], card1.attributes[index],
                         card2.attributes[index]) {
                return false
            }
        }
        return true
    }
    
    /**
     Finds a set that is left on the table.
     
     - Returns: A list of cards that is on the table and makes up a set, or nil
     if there are no sets left on the table
     */
    public func setLeft() -> [SetCard]? {
        let activeIndices = shownCards.indices.filter {
            !matchedCards.contains(shownCards[$0])
        }
        for index1 in 1..<activeIndices.count {
            let card1 = shownCards[activeIndices[index1]]
            for index2 in (index1+1)..<activeIndices.count {
                let card2 = shownCards[activeIndices[index2]]
                for index3 in (index2+1)..<activeIndices.count {
                    let card3 = shownCards[activeIndices[index3]]
                    if isSet(cards: [card1, card2, card3]) {
                        return [card1, card2, card3]
                    }
                }
            }
        }
        return nil
    }
    
    /**
     Phone's move in "Play Against Phone" mode. If there are any sets left,
     they are selected and removed, and the phone is rewarded.
     
     - Returns: A boolean that indicates if the phone successfully captured
     a set.
     */
    public func phonePlay() -> Bool {
        if let cardSet = setLeft() {
            selectedCards = cardSet
            drawThreeMoreCards(isPlayer: false)
            return true
        }
        return false
    }
}

extension Bool {
    var int: Int {  return Int(truncating: NSNumber(value: self)) }
}
