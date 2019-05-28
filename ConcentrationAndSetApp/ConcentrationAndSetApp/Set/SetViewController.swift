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
    
    private var animateForMatchedCards = false
    
    private var dealCardHits = 0
    
    private var dealCardAnimationInProgress = true
    
    
    
    
    
    @IBOutlet weak var tableView: TableView! {
        didSet {
            let rotate = UIRotationGestureRecognizer(target: self,
                                                     action: #selector(reshuffle(_:)))
            tableView.addGestureRecognizer(rotate)
            updateViewFromModel()
        }
    }
    
    
    
    

    
    @objc func reshuffle(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let preshuffleUnmatchedShownCards = setGame.unmatchedShownCards
            setGame.shuffle()
            var newPositions = [Int]()
            for i in 0..<setGame.unmatchedShownCards.count {
                if let newPos = setGame.unmatchedShownCards.firstIndex(of: preshuffleUnmatchedShownCards[i]) {
                    newPositions.append(newPos)
                    let buttonOnHold = tableView.buttonCards[newPos]
                    tableView.buttonCards[newPos] = tableView.buttonCards[i]
                    tableView.buttonCards[i] = buttonOnHold
                }
            }
            
            tableView.buttonCards.forEach { rotate($0, delay: 0.0)}
            
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.6,
                delay: 0,
                options: [],
                animations: { self.tableView.layoutSubviews() },
                completion: nil)
        }
    }
    
    
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
            for _ in numberOfButtons..<numberOfUnmatchedShownCards {
                let button = tableView.addButtonCard()
                let tapGesture =
                    UITapGestureRecognizer(target: self,
                                           action: #selector(touchButton(_:)))
                button.addGestureRecognizer(tapGesture)
                button.alpha = 0
                button.frame = dealDeck.frame
            }
            dealCardsAnimation(for: Array(numberOfButtons..<numberOfUnmatchedShownCards))
        }
    }
    
    private func dealCardsAnimation(for indices: [Int]) {
        indices.forEach { tableView.buttonCards[$0].faceUp = false }
        for i in indices {
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
                    self.rotate(button, delay: Double(count)*0.6)
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
                                animations: { button.faceUp = true},
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
    
    private func rotate(_ button: CardButton, delay time: TimeInterval) {
        let numberOfRev = 2
        let halfRevTime = 0.6 / 2.0 / Double(numberOfRev)
        for i in 0..<numberOfRev {
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: halfRevTime,
                delay: time + Double(i) * halfRevTime * 2.0,
                options: [],
                animations: { button.transform = CGAffineTransform(rotationAngle: CGFloat.pi) },
                completion: { _ in
                    UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: halfRevTime,
                        delay: 0.0,
                        options: [],
                        animations: { button.transform = CGAffineTransform(rotationAngle: CGFloat.pi) },
                        completion: { _ in button.transform = .identity}
                    )
            }
            )
        }
    }
    
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        matchedDeck.alpha = 0
        if flyawayBehavior.snapButtons.isEmpty {
            matchedDeck.alpha = 1
        }
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
    
    // The score label in the View.
    
    @IBOutlet weak var score: UILabel! {
        didSet {
            updateScore()
        }
    }
    
    
    
    
    
    /// Updates the score label in the View
    private func updateScore() {
        let playerScore = setGame.playerScore1.roundToTenth
        score.text = "\(playerScore)"
    }
 
    
    @IBOutlet weak var newGame: UIButton!
    
    
    /// Creates new game when "New Game" button is touched in the View
    @IBAction func NewGame(_ sender: UIButton) {
        setGame = Set(isPhonePlaying: setGame.isTwoPlayer)
        dealCardHits = 0
        dealCardAnimationInProgress = true
        tableView.selectedButtons = []
        tableView.buttonCards.forEach { $0.removeFromSuperview() }
        tableView.buttonCards = []
        updateViewFromModel()
        updateScore()
    }
    
    
    override func viewWillLayoutSubviews() {
        let stack = matchedDeck.superview!
        stack.setNeedsLayout()
        let smallerStack = score.superview!
        smallerStack.setNeedsLayout()
    }
    
    override func viewDidLayoutSubviews() {
        let stack = matchedDeck.superview!
        stack.layoutSubviews()
        let smallerStack = score.superview!
        smallerStack.layoutSubviews()
        flyawayBehavior.snapToRect = matchedDeck.superview!
            .convert(matchedDeck.frame, to: self.view)
        dealDeck.titleLabel?.attributedText = centeredAttributedString("Deal", fontSize: deckFontSize)
        matchedDeck.attributedText = centeredAttributedString("Match", fontSize: deckFontSize)
        score.attributedText = centeredAttributedString(score.attributedText!.string, fontSize: scoreFontSize)
        newGame.titleLabel?.attributedText = centeredAttributedString("New Game", fontSize: newGameFontSize)
        dealDeck.layer.cornerRadius = cornerRadius
        matchedDeck.layer.cornerRadius = cornerRadius
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


extension SetViewController {
    private struct SizeRatio {
        static let cornerRadiusToCellHeight: CGFloat = 0.06
        static let fontSizeToDeckHeight: CGFloat = 0.5
        static let fontSizeToCellHeight: CGFloat = 0.6
    }
    
    private var cornerRadius: CGFloat {
        return dealDeck.frame.height * SizeRatio.cornerRadiusToCellHeight
    }
    
    private var deckFontSize: CGFloat {
        return dealDeck.frame.height * SizeRatio.fontSizeToDeckHeight
    }
    
    private var scoreFontSize: CGFloat {
        return score.frame.height * SizeRatio.fontSizeToCellHeight
    }
    
    private var newGameFontSize: CGFloat {
        return newGame.frame.height * SizeRatio.fontSizeToCellHeight
    }
    
}
extension UIViewController {
    func centeredAttributedString(_ string: String, fontSize: CGFloat) -> NSAttributedString {
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return NSAttributedString(string: string,
                                  attributes: [.paragraphStyle: paragraphStyle,
                                               .font: font,
                                               .strokeColor: UIColor.black])
    }
}

extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(-self)))
        } else {
            return 0
        }
    }
}
