//
//  User.swift
//  DouDiZhu
//
//  Created by gg on 2020/12/24.
//

import Foundation

class User: NSObject {
    let handCard : HandCards
    
    var deskView : UserDeskView?
    
    var choiceCtt = 1
    var selectCardType : BtnType = .normal
    
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
    
    func next() -> User {
        if self == CardManager.shared.user {
            return CardManager.shared.rightBoot!
        }
        else if self == CardManager.shared.rightBoot! {
            return CardManager.shared.leftBoot!
        }
        else {
            return CardManager.shared.user!
        }
    }
}

extension User {
    func thinkingLandlord() -> BtnType {
        
        var hash : [Int:Int] = [:]
        hash[1] = handCard.pair.count
        hash[2] = handCard.consequent.count
        hash[3] = handCard.threeBelt.count
        hash[4] = handCard.plane.count
        hash[5] = handCard.bomb.count
        
        var sum = 0
        for i in 1..<6 {
            sum += hash[i]! * i * i
        }
        
        if sum > 40 {
            return .b3
        }
        else if sum > 25 {
            return .b2
        }
        else if sum > 10 {
            return .b1
        }
        else {
            return .cancel
        }
    }
}

extension User {
    override var description: String {
        get {
            if CardManager.shared.user == self {
                return "玩家"
            }
            else if CardManager.shared.leftBoot == self {
                return "左边的"
            }
            else if CardManager.shared.rightBoot == self {
                return "右边的"
            }
            else {
                return "出错的"
            }
        }
    }
}
