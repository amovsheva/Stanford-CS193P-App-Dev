//
//  ConcentrationThemeChooserViewController.swift
//  Concentration Multiple MVC
//
//  Created by Anna Movsheva on 5/3/19.
//  Copyright © 2019 Anna Movsheva. All rights reserved.
//

import UIKit

class ConcentrationThemeChooserViewController: UIViewController, UISplitViewControllerDelegate {
    
    private let themes: [(UIColor?, UIColor?, String?)] = [
        (#colorLiteral(red: 0.9994240403, green: 0.9555344182, blue: 0.7188570205, alpha: 1), #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.4060378477, alpha: 1), "🌝🌛🌜🌚🌕🌖🌗🌔🌓🌒🌑🌘"),
        (#colorLiteral(red: 0.9092225501, green: 1, blue: 0.9357194445, alpha: 1), #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), "🐠🐟🐬🐳🐋🦈🐡🦀🦞🦐🦑🐙"),
        (#colorLiteral(red: 0.8027318851, green: 0.8862745166, blue: 0.7645280367, alpha: 1), #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1), "🐶🐱🐭🐹🐰🦊🐻🐼🐨🐯🦁🐮🐷🐸🐵"),
        (#colorLiteral(red: 0.823437916, green: 0.9898272219, blue: 1, alpha: 1), #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), "🤶🏻🎅🏻❄️☃️🎄🦌🐿🌨⛷🏂"),
        (#colorLiteral(red: 0.9098039269, green: 0.7664001664, blue: 0.8139649026, alpha: 1), #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1), "🧝🏻‍♀️🧞‍♀️🧜🏻‍♀️🧚🏻‍♀️🧟‍♂️🧛🏻‍♀️🧙🏻‍♂️🦹🏻‍♀️🦸🏻‍♀️🧜🏻‍♂️🧞‍♂️🧚🏻‍♂️🧟‍♀️"),
        (#colorLiteral(red: 0.9764705896, green: 0.9174001825, blue: 0.7730247918, alpha: 1), #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), "🌷🌹🌺🌸🌼🌻🥀💐🌾"),
        (#colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1), #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1), "🎃💀👻🕷🧟‍♂️🦇⚰️🧙‍♀️🧛🏻‍♀️")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(splitViewController?.viewControllers ?? "nothin")
    }
    override func viewDidLayoutSubviews() {
        //print(splitViewController?.viewControllers ?? "nothin")
    }
    
    
    override func awakeFromNib() {
        splitViewController?.delegate = self
    }
    
    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController) -> Bool {
        //print("what")
        if let cvc = secondaryViewController as? ConcentrationViewController {
            if !cvc.themeSet {
                return true
            }
        }
        return false
    }
    
    @IBOutlet var themeButtons: [UIButton]!
    
    
    
    @IBAction func changeTheme(_ sender: Any) {
        if let cvc = splitViewDetailConcentrationViewController {
            if let index = themeButtons.firstIndex(of: (sender as? UIButton)!) {
                let theme = themes[index]
                cvc.theme = theme
            }
        } else if let cvc = lastSeguedToConcentrationViewController {
            if let index = themeButtons.firstIndex(of: (sender as? UIButton)!) {
                let theme = themes[index]
                cvc.theme = theme
            }
            navigationController?.pushViewController(cvc, animated: true)
        } else {
            performSegue(withIdentifier: "Choose Theme", sender: sender)
        }
    }
    

    
    private var splitViewDetailConcentrationViewController: ConcentrationViewController? {
        return splitViewController?.viewControllers.last as? ConcentrationViewController
    }
    
    // MARK: - Navigation
    
    private var lastSeguedToConcentrationViewController: ConcentrationViewController?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Choose Theme" {
            if let index = themeButtons.firstIndex(of: (sender as? UIButton)!) {
                let theme = themes[index]
                if let cvc = segue.destination as? ConcentrationViewController {
                    cvc.theme = theme
                    cvc.themeSet = true
                    lastSeguedToConcentrationViewController = cvc
                }
            }
        }
    }
    
}
