//
//  User.swift
//  DouDiZhu
//
//  Created by gg on 2020/12/24.
//

import Foundation

class User: NSObject {
    let handCard : HandCards
    
    var hasLandlordCard : Bool {
        get {
            for card in handCard.cards {
                if card.isLandlord {
                    return true
                }
            }
            return false
        }
    }
    
    init(handCard:HandCards) {
        self.handCard = handCard
        super.init()
    }
    init(cards:[Card]) {
        self.handCard = HandCards(cards: cards)
        super.init()
    }
}
