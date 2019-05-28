//
//  ViewController.swift
//  Concentration
//
//  Created by Anna Movsheva on 2/10/19.
//  Copyright © 2019 Anna Movsheva. All rights reserved.
//

import UIKit

class ConcentrationViewController: UIViewController {
    
    private lazy var game = Concentration(numberOfPairsOfCards: numberOfPairsOfCards )
    
    private var numberOfPairsOfCards: Int {
        return (cardButtons.count + 1) / 2
    }
    
    // MARK: Background
    @IBOutlet var backgroundTheme: UIView! {
        didSet {
            updateBackgroundTheme()
        }
    }
    
    
    private func updateBackgroundTheme() {
        if backgroundTheme != nil {
            backgroundTheme.backgroundColor = backgroundColor
        }
    }
    
    // MARK: CardButtons
    
    @IBOutlet private var cardButtons: [UIButton]! {
        didSet {
            updateViewFromModel()
        }
    }
    
    
    @IBAction private func touchCard(_ sender: UIButton) {
        if let cardNumber = cardButtons.firstIndex(of: sender) {
            game.chooseCard(at: cardNumber)
            updateDisplay()
        } else {
            print("chosen card not in cardButtons")
        }
    }
    
    // MARK: Updating layout and view
    
    private func updateViewFromModel() {
        if cardButtons != nil {
            for index in cardButtons.indices {
                let button = cardButtons[index]
                let card = game.cards[index]
                if card.isFaceUp {
                    var font = UIFont.preferredFont(forTextStyle: .body).withSize(button.frame.height * 0.8)
                    font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.alignment = .center
                    let attributedString =
                        NSAttributedString(string: emoji(for: card), attributes: [.paragraphStyle:paragraphStyle,.font:font])
                    button.setAttributedTitle(attributedString, for: UIControl.State.normal)
                    button.backgroundColor = backgroundColor
                } else {
                    button.setAttributedTitle(nil, for: UIControl.State.normal)
                    button.backgroundColor = card.isMatched ? #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 0) : cardColor
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Your Title"
    }
    
    override func viewWillLayoutSubviews() {
        cardButtons.forEach { $0.setNeedsLayout() }
    }
    
    override func viewDidLayoutSubviews() {
        cardButtons.forEach { $0.layoutIfNeeded() }
        updateDisplay()
        updateNewGameButton()
    }
    
    // MARK: Theme, color, and emojis
    
    var themeSet = false
    
    var theme: (UIColor?, UIColor?, String?) {
        didSet {
            //if let ConcentrationViewController as
            //themeName = theme.3 ?? "Spooky"
            emojiChoices = theme.2 ?? ""
            cardColor = theme.1 ?? #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
            backgroundColor = theme.0 ?? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            emoji = [:]
            
            updateDisplay()
        }
    }
    
    private var themeName = "Spooky"
    
    private var cardColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
    
    private var backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    
    private var emojiChoices = "🎃💀👻🕷🧟‍♂️🦇⚰️🧙‍♀️🧛🏻‍♀️"
    
    private var emoji = [ConcentrationCard:String]()
    
    private func emoji(for card: ConcentrationCard) -> String {
        if emoji[card] == nil, emojiChoices.count > 0 {
            let randomStringIndex = emojiChoices
                .index(emojiChoices.startIndex,
                       offsetBy: emojiChoices.count.arc4random)
            emoji[card] = String(emojiChoices.remove(at: randomStringIndex))
        }
        return emoji[card]!
    }
    
    // MARK: NewGameButton
    
    @IBAction private func startNewGame(_ sender: UIButton) {
        emojiChoices = theme.2 ?? "🎃💀👻🕷🧟‍♂️🦇⚰️🧙‍♀️🧛🏻‍♀️"
        emoji = [ConcentrationCard:String]()
        game.reset()
        updateDisplay()
    }
    
    
    // MARK: score
    
    @IBOutlet private weak var scoreLabel: UILabel! {
        didSet {
            updateScoreLabel()
        }
    }
    
    private func updateScoreLabel() {
        if scoreLabel != nil {
            scoreLabel.textColor = cardColor
            let attrib = centeredAttributedString("Score: \(round(10 * game.score) / 10)",
                fontSize: newGame.frame.height * 0.4)
            scoreLabel.attributedText = attrib
        }
    }
    
    // MARK: New Game
    
    @IBOutlet private weak var newGame: UIButton! {
        didSet {
            updateNewGameButton()
        }
    }
    
    private func updateNewGameButton() {
        let attrib = centeredAttributedString("New Game", fontSize: newGame.frame.height * 0.4)
        newGame.setAttributedTitle(attrib, for: UIControl.State.normal)
    }
    
    // MARK: Display
    
    private func updateDisplay() {
        updateViewFromModel()
        updateBackgroundTheme()
        updateScoreLabel()
    }
    
    
    
}

//extension Int {
//    var arc4random: Int {
//        if self > 0 {
//            return Int(arc4random_uniform(UInt32(self)))
//        } else if self < 0 {
//            return -Int(arc4random_uniform(UInt32(-self)))
//        } else {
//            return 0
//        }
//    }
//}
