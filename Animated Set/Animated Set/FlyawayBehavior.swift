//
//  FlyawayBehavior.swift
//  Animated Set
//
//  Created by Anna Movsheva on 4/25/19.
//  Copyright © 2019 Anna Movsheva. All rights reserved.
//

import UIKit

class FlyawayBehavior: UIDynamicBehavior {
    
    var snapToRect = CGRect()
    
    var snapTimer = Timer()
    
    var snapButtons = [CardButton]()

    lazy var collisionBehavior: UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        return behavior
    }()
    
    lazy var itemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.elasticity = 1.0
        behavior.resistance = 0
        return behavior
    }()
    
    private func push(_ item: UIDynamicItem) {
        let push = UIPushBehavior(items: [item], mode: .instantaneous)
        push.angle = (2*CGFloat.pi).arc4random
        push.magnitude = CGFloat(5.0) + CGFloat(2.0).arc4random
        push.action = { [unowned push, weak self] in
            self?.removeChildBehavior(push)
        }
        addChildBehavior(push)
    }
    
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
