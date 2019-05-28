//
//  ViewController.swift
//  Set
//
//  Created by Anna Movsheva on 2/22/19.
//  Copyright © 2019 Anna Movsheva. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    /// The current set game.
    private var setGame = Set(isPhonePlaying: false)
    
    /// The timer set for when the phone will make its move if the player
    /// is playing against the phone.
    private var timer: Timer? = nil
    
    /// The timer set for when to warn the player that the phone will make a
    /// move soon, if the player is playing against the phone.
    private var warningTimer: Timer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBOutlet weak var tableView: TableView! {
        didSet {
            let swipe = UISwipeGestureRecognizer(target: self,
                                                 action: #selector(dealCards(_:)))
            swipe.direction = .down
            let rotate = UIRotationGestureRecognizer(target: self,
                                                     action: #selector(reshuffle(_:)))
            tableView.addGestureRecognizer(swipe)
            tableView.addGestureRecognizer(rotate)
            updateViewFromModel()
        }
    }
    
    @objc func reshuffle(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            setGame.shuffle()
            updateViewFromModel()
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
        }
        updateViewFromModel()
        updateScore()
    }
    
    /// Updates the card buttons in the View.
    private func updateViewFromModel() {
        var numberOfButtons = tableView.buttonCards.count
        let numberOfUnmatchedShownCards = setGame.unmatchedShownCards.count
        while numberOfButtons < numberOfUnmatchedShownCards {
            let button = tableView.addButtonCard()
            let tapGesture =
                UITapGestureRecognizer(target: self,
                                       action: #selector(touchButton(_:)))
            button.addGestureRecognizer(tapGesture)
            numberOfButtons += 1
        }
        while numberOfButtons > numberOfUnmatchedShownCards {
            let button = tableView.buttonCards.popLast()
            button?.isHidden = true
            numberOfButtons -= 1
        }
        for i in 0..<numberOfUnmatchedShownCards {
            let button = tableView.buttonCards[i]
            let card = setGame.unmatchedShownCards[i]
            button.number = Card.Attributes.allNumber
                .firstIndex(of: card.number)!
            button.shape = Card.Attributes.allShape
                .firstIndex(of: card.shape)!
            button.pattern = Card.Attributes.allPattern
                .firstIndex(of: card.pattern)!
            button.color = Card.Attributes.allColor
                .firstIndex(of: card.color)!
        }
    }
    
    /**
     Method is called if the "Deal 3 More Cards" is touched. If there are
     selected cards that make up a set, they get replaced by new cards.
     Otherwise, three more cards are added to the screen, unless there is no
     room left or no cards left in the deck. Also if there is a valid set of
     cards left on the screen before the button is hit, points are deducted.
     */
    @IBAction private func dealCards(_ sender: UIButton) {
        let isSetLeft = (setGame.setLeft() != nil)
        if setGame.deck.count > 0 {
            setGame.drawThreeMoreCards(isPlayer: true)
            if setGame.isTwoPlayer, !isSetLeft { setTimer() }
            updateViewFromModel()
            updateScore()
        }
    }
    
    
    /// The score label in the View.
    @IBOutlet private weak var Score: UILabel! {
        didSet {
            updateScore()
        }
    }
    
    /// Emojis that represent states of the phone, when playing against phone
    private let emoji = ["🤔", "😁", "😢", "😂"]
    
    /// State of phone, when playing against phone
    private var phoneState = 0
    
    /// Updates the score label in the View
    private func updateScore() {
        let playerScore = setGame.playerScore1.roundToTenth
        if setGame.isTwoPlayer {
            if setGame.deck.count == 0, setGame.setLeft() == nil {
                if setGame.playerScore2 > setGame.playerScore1 {
                    phoneState = 3
                } else {
                    phoneState = 2
                }
            }
            let phoneScore = setGame.playerScore2.roundToTenth
            Score.text =
            "Player: \(playerScore) Phone: \(phoneScore), \(emoji[phoneState])"
        } else {
            Score.text = "Score: \(playerScore)"
        }
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
        timer?.invalidate()
        warningTimer?.invalidate()
        setGame = Set(isPhonePlaying: isPhonePlaying)
        tableView.selectedButtons = []
        updateViewFromModel()
        updateModeLabel()
        updateScore()
        if isPhonePlaying { setTimer() }
    }
    
    /// Gives hint by coloring a valid set of cards blue, when "Hint" button
    /// is hit.
    @IBAction private func giveHint(_ sender: UIButton) {
//        if let set = setGame.setLeft() {
//            for card in set {
//                let index = setGame.shownCards.index(of: card)!
//                let button = cardButtons[index]
//                button.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
//            }
//        }
    }
    
    /// Switches play mode to playing against phone or single-player mode
    /// when "Playing Against iPhone" button is touched
    @IBAction private func touchModeButton(_ sender: UIButton) {
        updateForNewGame(isPhonePlaying: !setGame.isTwoPlayer)
    }
    
    /// The "Playing Against iPhone" button
    @IBOutlet private weak var modeLabel: UIButton! {
        didSet { updateModeLabel() }
    }
    
    /// Updates "Playing Against iPhone" button depending the mode of the game
    private func updateModeLabel() {
        let mode = setGame.isTwoPlayer ? "ON" : "OFF"
        modeLabel.setTitle("Play Against iPhone: \(mode)",
            for: UIControl.State.normal)
    }
    
    /// Makes move for phone and resets timer for next phone move.
    private func phoneTurn() {
        if setGame.phonePlay() {
            updateViewFromModel()
            setTimer()
        } else if setGame.deck.count > 0 {
            setGame.drawThreeMoreCards(isPlayer: false)
            phoneTurn()
        } else {
            setTimer()
        }
    }
    
    /// Updates the score label to warn player that phone will make move soon
    /// and sets timer for when phone will make move
    private func warnPlayer() {
        phoneState = 1
        updateScore()
        timer =
            Timer.scheduledTimer(withTimeInterval: 3, repeats: false,
                                 block: { (timer) in self.phoneTurn() })
    }
    
    /// (Re)sets timer for when to give warning to player that phone will
    /// make a move soon
    private func setTimer() {
        if setGame.isTwoPlayer {
            timer?.invalidate()
            warningTimer?.invalidate()
            phoneState = 0
            updateScore()
            if setGame.deck.count > 0 || (setGame.setLeft() != nil) {
                let warningTime = Int.random(in: 5 ... 10)
                warningTimer =
                    Timer.scheduledTimer(withTimeInterval: TimeInterval(warningTime),
                                         repeats: false,
                                         block: { (timer) in self.warnPlayer() })
            }
        }
    }
    
    
}

extension Double {
    var roundToTenth: Double {
        return Double(Int(self*10)) / 10
    }
}
