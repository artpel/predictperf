//
//  Animations.swift
//  Phileas
//
//  Created by Arthur Péligry on 16/10/2017.
//  Copyright © 2017 Arthur Péligry. All rights reserved.
//

import Foundation
import Spring

class Animations {
    
    static func fadeOut(viewGiven: SpringView) {
        viewGiven.animation = "fadeOut"
        viewGiven.animation = "fadeOut"
        viewGiven.curve = "spring"
        viewGiven.force =  2.3
        viewGiven.duration =  3
        viewGiven.animate()
        
    }
    
    static func fadeIn(viewGiven: SpringView) {
        viewGiven.isHidden = false
        viewGiven.animation = "fadeIn"
        viewGiven.animation = "fadeIn"
        viewGiven.curve = "spring"
        viewGiven.force =  2.0
        viewGiven.duration =  5
        viewGiven.animate()
    }
    
    static func adFadeIn(viewGiven: SpringView) {
        viewGiven.isHidden = false
        viewGiven.animation = "fadeIn"
        viewGiven.animation = "fadeIn"
        viewGiven.curve = "spring"
        viewGiven.force =  2.0
        viewGiven.duration =  2.0
        viewGiven.animate()
    }
    
    static func pop(viewGiven: SpringView) {
        viewGiven.isHidden = false
        viewGiven.animation = "fadeInLeft"
        viewGiven.curve = "spring"
        viewGiven.force =  0.2
        viewGiven.duration =  1
        viewGiven.animate()
    }
    
    static func wobble(viewGiven: SpringView) {
        viewGiven.isHidden = false
        viewGiven.animation = "wobble"
        viewGiven.curve = "spring"
        viewGiven.force =  0.2
        viewGiven.duration =  1
        viewGiven.animate()
    }
    
    
    static func shake(viewGiven: SpringView) {
        viewGiven.isHidden = false
        viewGiven.animation = "shake"
        viewGiven.curve = "spring"
        viewGiven.force =  0.2
        viewGiven.duration =  1
        viewGiven.animate()
    }
    
    
    static func animateCells(tableView: UITableView) {
        // Animation
        let cells = tableView.visibleCells
        let tableViewHeight = tableView.bounds.size.height
        for cell in cells {
            cell.transform = CGAffineTransform(translationX: 0, y: tableViewHeight)
        }
        
        var delayCounter = 0
        for cell in cells {
            UIView.animate(withDuration: 1.25, delay: Double(delayCounter) * 0.05, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                cell.transform = CGAffineTransform.identity
            }, completion: nil)
            delayCounter += 1
        }
    }
    
}
