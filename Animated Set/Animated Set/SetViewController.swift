//
//  ViewController.swift
//  Set
//
//  Created by Anna Movsheva on 2/22/19.
//  Copyright © 2019 Anna Movsheva. All rights reserved.
//

import UIKit

class SetViewController: UIViewController, UIDynamicAnimatorDelegate {
    
    lazy var animator: UIDynamicAnimator = {
        let animator = UIDynamicAnimator(referenceView: view)
        animator.delegate = self
        return animator
    }()
    
    lazy var flyawayBehavior: FlyawayBehavior = {
        let behavior = FlyawayBehavior(in: animator)
        behavior.snapToRect = matchedDeck.superview!.convert(matchedDeck.frame,
                                                             to: self.view)
        return behavior
    }()
    
    /// The current set game.
    private var setGame = Set(isPhonePlaying: false)

    private var snapTimer = Timer()
    
    private var animateForMatchedCards = false
    
    private var dealCardHits = 0
    
    private var dealCardAnimationInProgress = true
    
    @IBOutlet weak var tableView: TableView! {
        didSet {
//            let rotate = UIRotationGestureRecognizer(target: self,
//                                                     action: #selector(reshuffle(_:)))
//            tableView.addGestureRecognizer(rotate)
            updateViewFromModel()
        }
    }
    
//    @objc func reshuffle(_ sender: UITapGestureRecognizer) {
//        if sender.state == .ended {
//            setGame.shuffle()
//            updateViewFromModel()
//        }
//    }
    
    
    /**
     Method that is called when a card button of the game touched in the View.
     Selects the card button if it isn't selected already. Deselects it if it
     is selected already, unless the selected cards make up a set. In that case
     the selected cards are cleared, and replaced by new cards if any are left
     in the deck.
     */
    @objc func touchButton(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let button = sender.view as! CardButton
            let index = tableView.buttonCards.firstIndex(of: button)!
            let card = setGame.unmatchedShownCards[index]
            let _ = setGame.selection(of: card)
            tableView.selectedButtons = []
            for card in setGame.selectedCards {
                let cardIndex = setGame.unmatchedShownCards.firstIndex(of: card)!
                tableView.selectedButtons.append(cardIndex)
            }
            if setGame.isSet(cards: setGame.selectedCards) {
                let _ = setGame.selection(of: setGame.selectedCards[0])
                animateForMatchedCards = true
            }
            updateViewFromModel()
            updateScore()
        }
    }
    
    /// Updates the card buttons in the View.
    private func updateViewFromModel() {
        var numberOfButtons = tableView.buttonCards.count
        let numberOfUnmatchedShownCards = setGame.unmatchedShownCards.count
        if animateForMatchedCards {
            animateForMatchedCards = false
            let indicesOfButtonsToAnimate = tableView.selectedButtons
            tableView.selectedButtons = []
            indicesOfButtonsToAnimate.forEach {
                let newButton = tableView.buttonCards[$0].identicalCard()
                newButton.frame = tableView.buttonCards[$0].frame
                newButton.frame.origin = newButton.frame.origin
                    .offsetBy(dx: tableView.frame.minX, dy: tableView.frame.minY)
                newButton.layer.borderWidth = 1.0
                newButton.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                newButton.backgroundColor = UIColor.clear
                newButton.isOpaque = false
                tableView.superview?.addSubview(newButton)
                flyawayBehavior.addItem(newButton)
                tableView.buttonCards[$0].alpha = 0
            }
            if numberOfButtons <= numberOfUnmatchedShownCards {
                for i in indicesOfButtonsToAnimate {
                    let button = tableView.buttonCards[i]
                    let card = setGame.unmatchedShownCards[i]
                    button.number = SetCard.Attributes.allNumber
                        .firstIndex(of: card.number)!
                    button.shape = SetCard.Attributes.allShape
                        .firstIndex(of: card.shape)!
                    button.pattern = SetCard.Attributes.allPattern
                        .firstIndex(of: card.pattern)!
                    button.color = SetCard.Attributes.allColor
                        .firstIndex(of: card.color)!
                }
                dealCardsAnimation(for: indicesOfButtonsToAnimate)
            } else {
                indicesOfButtonsToAnimate.forEach {
                    tableView.buttonCards[$0].alpha = 1
                }
                let selectedButtonIndicesDes = indicesOfButtonsToAnimate.sorted(by: >)
                for index in selectedButtonIndicesDes {
                    let button = self.tableView.buttonCards.remove(at: index)
                    button.removeFromSuperview()
                    numberOfButtons -= 1
                }
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 1.0,
                    delay: 0,
                    options: [],
                    animations: { self.tableView.layoutSubviews() },
                    completion: nil)
            }
        } else if numberOfButtons < numberOfUnmatchedShownCards {
                for i in numberOfButtons..<numberOfUnmatchedShownCards {
                    let button = tableView.addButtonCard()
                    let tapGesture =
                        UITapGestureRecognizer(target: self,
                                               action: #selector(touchButton(_:)))
                    button.addGestureRecognizer(tapGesture)
                    button.alpha = 0
                    button.frame = dealDeck.frame
                    let card = setGame.unmatchedShownCards[i]
                    button.number = SetCard.Attributes.allNumber
                        .firstIndex(of: card.number)!
                    button.shape = SetCard.Attributes.allShape
                        .firstIndex(of: card.shape)!
                    button.pattern = SetCard.Attributes.allPattern
                        .firstIndex(of: card.pattern)!
                    button.color = SetCard.Attributes.allColor
                        .firstIndex(of: card.color)!
                }
                dealCardsAnimation(for: Array(numberOfButtons..<numberOfUnmatchedShownCards))
        }
    }
    
    private func dealCardsAnimation(for indices: [Int]) {
        indices.forEach { tableView.buttonCards[$0].faceUp = false }
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.5,
            delay: 0.0,
            options: [],
            animations: { self.tableView.layoutSubviews() },
            completion: { _ in
                var count = 0
                for i in indices {
                    let button = self.tableView.buttonCards[i]
                    button.alpha = 1
                    button.frame.size = self.dealDeck.frame.size
                    button.frame.origin = self.dealDeck.superview!.frame.origin
                        .offsetBy(dx: -self.tableView.frame.minX, dy: -self.tableView.frame.minY)
                    UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: 0.6,
                        delay: Double(count)*0.6,
                        options: [],
                        animations: { self.tableView.layoutSubviews() },
                        completion: { _ in
                            UIView.transition(
                                with: button,
                                duration: 0.5,
                                options: [.transitionFlipFromLeft],
                                animations: {
                                    button.faceUp = true},
                                completion: { _ in
                                    if i == indices.last {
                                        self.dealCardAnimationInProgress = false
                                        if self.dealCardHits > 0 {
                                            self.dealCardHits -= 1
                                            self.dealCards(self.dealDeck)
                                        }
                                    }
                            })
                    })
                    count += 1
                }
        }
        )
    }
    
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        for button in flyawayBehavior.snapButtons {
            UIView.transition(
                with: button,
                duration: 0.5,
                options: [.transitionFlipFromLeft],
                animations: {
                    button.faceUp = !button.faceUp
            },
                completion: { _ in
                    self.matchedDeck.alpha = 1
                    button.isHidden = true
                    button.removeFromSuperview()
                    self.flyawayBehavior.removeItem(button)
            })
        }
        flyawayBehavior.snapButtons = []
    }
    
    
    
    /**
     Method is called if the "Deal 3 More Cards" is touched. If there are
     selected cards that make up a set, they get replaced by new cards.
     Otherwise, three more cards are added to the screen, unless there is no
     room left or no cards left in the deck. Also if there is a valid set of
     cards left on the screen before the button is hit, points are deducted.
     */
    @IBAction private func dealCards(_ sender: UIButton) {
        dealCardHits += 1
        if setGame.deck.count > 0, !dealCardAnimationInProgress {
            dealCardAnimationInProgress = true
            dealCardHits -= 1
            setGame.drawThreeMoreCards(isPlayer: true)
            tableView.selectedButtons = []
            updateViewFromModel()
            updateScore()
        }
    }
    
    @IBOutlet weak var dealDeck: UIButton! {
        didSet {
            dealDeck.layer.borderWidth = 1.0
            dealDeck.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            dealDeck.layer.cornerRadius = dealDeck.frame.height * 0.06
        }
    }
    
    @IBOutlet weak var matchedDeck: UILabel! {
        didSet {
            matchedDeck.layer.borderWidth = 1.0
            matchedDeck.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            matchedDeck.layer.cornerRadius = dealDeck.frame.height * 0.06
        }
    }
    
    /// The score label in the View.
    @IBOutlet private weak var Score: UILabel! {
        didSet {
            updateScore()
        }
    }

    
    /// Updates the score label in the View
    private func updateScore() {
        let playerScore = setGame.playerScore1.roundToTenth
        Score.text = "\(playerScore)"
    }
    
    /// Creates new game when "New Game" button is touched in the View
    @IBAction private func NewGame(_ sender: UIButton) {
        updateForNewGame(isPhonePlaying: setGame.isTwoPlayer)
    }
    
    /**
     Creates either a new single-player game or a new against-phone game.
     
     - Parameter isPhonePlaying: A boolean that indicates whether the player
     will play against the phone or not in this new game.
     */
    private func updateForNewGame(isPhonePlaying: Bool) {
        setGame = Set(isPhonePlaying: isPhonePlaying)
        dealCardHits = 0
        dealCardAnimationInProgress = true
        tableView.selectedButtons = []
        tableView.buttonCards.forEach { $0.removeFromSuperview() }
        tableView.buttonCards = []
        updateViewFromModel()
        updateScore()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        flyawayBehavior.snapToRect = matchedDeck.superview!.convert(matchedDeck.frame,
                                                                    to: self.view)
    }
    
}

extension Double {
    var roundToTenth: Double {
        return Double(Int(self*10)) / 10
    }
}

extension CGFloat {
    var arc4random: CGFloat {
        return self * (CGFloat(arc4random_uniform(UInt32.max))/CGFloat(UInt32.max))
    }
}
