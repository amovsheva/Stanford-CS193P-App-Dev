//
//  FlyawayBehavior.swift
//  Animated Set
//
//  Created by Anna Movsheva on 4/25/19.
//  Copyright © 2019 Anna Movsheva. All rights reserved.
//

import UIKit

class FlyawayBehavior: UIDynamicBehavior {
    
    /// Rectangle in the view to switch the cards will snap to after flying around
    var snapToRect = CGRect()
    
    /// List of CardButtons that are currently behave according to FlyawayBehavior
    var snapButtons = [CardButton]()
    
    /// Returns the collision behavior part of FlyawayBehavior
    private lazy var collisionBehavior: UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        return behavior
    }()
    
    /// Returns the specific behavior that describes how each item behaves
    private lazy var itemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.elasticity = 1.0
        behavior.resistance = 0
        return behavior
    }()
    
    /**
     Adds a push to the input item.
     
     - Parameters: item: a UIDynamicItem, that is going to recieve an
     instantaneous push in a random direction with a force of random magnitude
     between 5 and 7 units
     */
    private func push(_ item: UIDynamicItem) {
        let push = UIPushBehavior(items: [item], mode: .instantaneous)
        push.angle = (2*CGFloat.pi).arc4random
        push.magnitude = CGFloat(5.0) + CGFloat(2.0).arc4random
        push.action = { [unowned push, weak self] in
            self?.removeChildBehavior(push)
        }
        addChildBehavior(push)
    }
    
    
    /**
     Stops the bouncing around movement of the input item and snaps it to
     the location specified by snapToRect, transforming it to the size of the
     rect.
     
     - Parameters: item: UIDynamicItem, that is going to experience the snap
     to the snapToRect
     */
    private func snap(for item: UIDynamicItem) {
        removeItem(item)
        let button = item as! CardButton
        snapButtons.append(button)
        addChildBehavior(UISnapBehavior(item: item,
                                        snapTo: CGPoint(x: snapToRect.midX,
                                                        y: snapToRect.midY)))
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.5,
            delay: 0,
            options: [],
            animations: {
                button.transform = .identity
                button.bounds = self.snapToRect
        },
            completion: nil
        )
    }
    
    /**
     Applies collision, item behavior, and an instantaneous push to the input
     item and sets a timer to snap the item to snapToRect CGRect after an
     interval of time
     
     - Parameters: item: UIDynamicItem, the item that will have the behaviors
     applied to
     */
    func addItem(_ item: UIDynamicItem) {
        collisionBehavior.addItem(item)
        itemBehavior.addItem(item)
        push(item)
        let _ = Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: false,
            block: { (timer) in self.snap(for: item) }
        )
    }
    
    
    /**
     Removes collision and item behaviors from the input item
     
     - Parameters: item: UIDynamicItem, the item that will have the behaviors
     removed
     */
    func removeItem(_ item: UIDynamicItem) {
        collisionBehavior.removeItem(item)
        itemBehavior.removeItem(item)
    }
    
    override init() {
        super.init()
        addChildBehavior(itemBehavior)
        addChildBehavior(collisionBehavior)
    }
    
    convenience init(in animator: UIDynamicAnimator) {
        self.init()
        animator.addBehavior(self)
    }
}
