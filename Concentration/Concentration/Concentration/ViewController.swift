//
//  ViewController.swift
//  Concentration
//
//  Created by Anna Movsheva on 2/10/19.
//  Copyright © 2019 Anna Movsheva. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var game = Concentration(numberOfPairsOfCards: numberOfPairsOfCards )
    
    var numberOfPairsOfCards: Int {
        return (cardButtons.count + 1) / 2
    }
    
    // MARK: FlipLabel
    
    private func updateFlipCountLabel() {
        let attributes: [NSAttributedString.Key:Any] = [
            .strokeWidth : 5.0,
            .strokeColor : choosingTheme().1
        ]
        let attributedString = NSAttributedString(string: "Flips: \(game.flipCount)", attributes: attributes)
        flipCountLabel.attributedText = attributedString
    }
    
    @IBOutlet private weak var flipCountLabel: UILabel! {
        didSet {
            updateFlipCountLabel() 
        }
    }
    
    // MARK: Background
    
    @IBOutlet private var backgroundTheme: UIView! {
        didSet {
            updateBackgroundTheme()
        }
    }
    
    private func updateBackgroundTheme() {
        backgroundTheme.backgroundColor = choosingTheme().0
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
    
    private func updateViewFromModel() {
        for index in cardButtons.indices {
            let button = cardButtons[index]
            let card = game.cards[index]
            if card.isFaceUp {
                button.setTitle(emoji(for: card), for: UIControl.State.normal)
                button.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            } else {
                button.setTitle("", for: UIControl.State.normal)
                button.backgroundColor = card.isMatched ? #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 0) : choosingTheme().1
            }
        }
    }
    
    private var themes = [(#colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1),#colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1), "🌝🌛🌜🌚🌕🌖🌗🌔🌓🌒🌑🌘"),
                         (#colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), "🐠🐟🐬🐳🐋🦈🐡🦀🦞🦐🦑🐙"),
                         (#colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1), #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), "🐶🐱🐭🐹🐰🦊🐻🐼🐨🐯🦁🐮🐷🐸🐵"),
                         (#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1), "🤶🏻🎅🏻❄️☃️🎄🦌🐿🌨⛷🏂"),
                         (#colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), "🧝🏻‍♀️🧞‍♀️🧜🏻‍♀️🧚🏻‍♀️🧟‍♂️🧛🏻‍♀️🧙🏻‍♂️🦹🏻‍♀️🦸🏻‍♀️🧜🏻‍♂️🧞‍♂️🧚🏻‍♂️🧟‍♀️"),
                         (#colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1), #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), "🌷🌹🌺🌸🌼🌻🥀💐🌾"),
                         (#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1), "🎃💀👻🕷🧟‍♂️🦇⚰️🧙‍♀️🧛🏻‍♀️")]
    
    private var randomThemeIndex: Int?
    
    public func add(theme: (UIColor, UIColor, String)) {
        themes.append(theme)
    }
    
    private func choosingTheme() -> (UIColor, UIColor, String) {
        if randomThemeIndex == nil {
            randomThemeIndex = themes.count.arc4random
        }
        return themes[randomThemeIndex!]
    }
    
    private var emojiChoices: String?
    
    private var emoji = [Card:String]()
    
    private func emoji(for card: Card) -> String {
        if emojiChoices == nil {
            emojiChoices = choosingTheme().2
        }
        if emoji[card] == nil, emojiChoices!.count > 0 {
            let randomStringIndex = emojiChoices!
                .index(emojiChoices!.startIndex,
                       offsetBy: emojiChoices!.count.arc4random)
            emoji[card] = String(emojiChoices!.remove(at: randomStringIndex))
        }
        return emoji[card]!
    }
    
    // MARK: NewGameButton
    
    @IBAction private func startNewGame(_ sender: UIButton) {
        randomThemeIndex = nil
        emojiChoices = nil
        emoji = [Card:String]()
        game.reset()
        updateDisplay()
    }
    
    
    // MARK: Score
    
    @IBOutlet private weak var scoreLabel: UILabel! {
        didSet {
            updateScoreLabel()
        }
    }
    
    private func updateScoreLabel() {
        scoreLabel.text = "Score: \(round(10 * game.score) / 10)"
        scoreLabel.textColor = choosingTheme().1
    }
    
    // MARK: Display
    
    private func updateDisplay() {
        updateViewFromModel()
        updateFlipCountLabel()
        updateBackgroundTheme()
        updateScoreLabel()
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

