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
    
    var isLandlord = false
    
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
    func playCards() -> [Card] {
        
        if let lastCards = CardManager.shared.lastPlayedCards {
            let cardType = getCardsType(cards: lastCards)
            switch cardType {
            case .sheet:
                for card in handCard.sheet.reversed() {
                    if card.value > lastCards.first!.value {
                        return [card]
                    }
                }
                for card in handCard.cards.reversed() {
                    if card.value > lastCards.first!.value {
                        return [card]
                    }
                }
                return []
            case .pair:
                for pair in handCard.pair {
                    if pair.value > lastCards.first!.value {
                        return pair.cards!
                    }
                }
                return []
                break
            case .consequent:
                for conseq in handCard.consequent {
                    if conseq.count >= lastCards.count {
                        
                    }
                }
                break
            case .plane:
                break
            case .threeBelt:
                break
            case .consequentPair:
                break
            default:
                break
            }
        }
        else {
            
        }
        return []
    }
    
    func getCardsType(cards:[Card]) -> CardStyleLevel {
        switch cards.count {
        case 1:
            return .sheet
        case 2:
            let isPair = type(isPair: cards)
            if isPair {
                return .pair
            }
            break
        case 3:
            let is3b = type(is3b: cards)
            if is3b {
                return .threeBelt
            }
            break
        case 4:
            let isBomb = type(isBomb: cards)
            if isBomb {
                return .bomb
            }
            let is3b1 = type(is3b1: cards)
            if is3b1 {
                return .threeBeltOne
            }
            break
        case 5:
            let is3b2 = type(is3b2: cards)
            if is3b2 {
                return .threeBeltPair
            }
            let isConsequent = type(isConsequent: cards)
            if isConsequent {
                return .consequent
            }
            break
        case 6:
            let isConsequent = type(isConsequent: cards)
            if isConsequent {
                return .consequent
            }
            let is4b2 = type(is4b2: cards)
            if is4b2 {
                return .fourBeltTwo
            }
            break
        case 8:
            let is4b2pair = type(is4b2pair: cards)
            if is4b2pair {
                return .fourBeltTwoPair
            }
            let isConsequent = type(isConsequent: cards)
            if isConsequent {
                return .consequent
            }
            break
        default:
            let isConsequent = type(isConsequent: cards)
            if isConsequent {
                return .consequent
            }
            break
        }
        return .unsolvable
    }
}

extension User {
    func type(isPair:[Card]) -> Bool {
        if isPair.count != 2 {
            return false
        }
        let c1 = isPair.first!, c2 = isPair.last!
        return c1.value == c2.value
    }
    func type(is4b2pair:[Card]) -> Bool {
        if is4b2pair.count != 8 {
            return false
        }
        let cards = CardManager.shared.sortDataSource(source: is4b2pair)
        var hash : [Int:Int] = [:]
        for card in cards {
            var ctt = hash[card.value]
            if ctt == nil {
                ctt = 1
            }
            else {
                ctt! += 1
            }
            hash[card.value] = ctt!
        }
        if hash.keys.count == 3 {
            var contains4 = false, containsPair = false
            for key in hash.keys {
                let ctt = hash[key]
                if ctt == 4 {
                    contains4 = true
                }
                else if ctt == 2 {
                    containsPair = true
                }
                if contains4 && containsPair {
                    return true
                }
            }
        }
        else if hash.keys.count == 2 {
            return true
        }
        return false
    }
    func type(is4b2:[Card]) -> Bool {
        if is4b2.count != 6 {
            return false
        }
        let cards = CardManager.shared.sortDataSource(source: is4b2)
        var hash : [Int:Int] = [:]
        for card in cards {
            var ctt = hash[card.value]
            if ctt == nil {
                ctt = 1
            }
            else {
                ctt! += 1
            }
            hash[card.value] = ctt!
        }
        if hash.keys.count == 3 {
            for key in hash.keys {
                let ctt = hash[key]
                if ctt == 4 {
                    return true
                }
            }
        }
        else if hash.keys.count == 2 {
            for key in hash.keys {
                let ctt = hash[key]
                if ctt == 4 {
                    return true
                }
            }
        }
        return false
    }
    func type(isConsequent:[Card]) -> Bool {
        if isConsequent.count < 5 {
            return false
        }
        let firstValue = isConsequent.first!.value
        for (i, card) in isConsequent.enumerated() {
            if card.value != firstValue + i {
                return false
            }
        }
        return true
    }
    func type(is3b2:[Card]) -> Bool {
        var hash : [Int:Int] = [:]
        for card in is3b2 {
            var ctt = hash[card.value]
            if ctt == nil {
                ctt = 1
            }
            else {
                ctt! += 1
            }
            hash[card.value] = ctt!
        }
        if hash.keys.count == 2 {
            for key in hash.keys {
                let ctt = hash[key]
                if ctt == 3 || ctt == 2 {
                    return true
                }
            }
        }
        return false
    }
    func type(isBomb:[Card]) -> Bool {
        if isBomb.count != 4 {
            return false
        }
        let value = isBomb.first!.value
        for card in isBomb {
            if card.value != value {
                return false
            }
        }
        return true
    }
    func type(is3b1:[Card]) -> Bool {
        if is3b1.count != 4 {
            return false
        }
        let c1 = is3b1[0], c2 = is3b1[1], c3 = is3b1[2], c4 = is3b1[3]
        if c1.value == c2.value {
            if c1.value == c3.value {
                return c1.value != c4.value
            }
            else if c1.value == c4.value {
                return true
            }
            else {
                return false
            }
        }
        else if c1.value == c3.value {
            if c1.value == c4.value {
                return true
            }
            else {
                return false
            }
        }
        else if c2.value == c3.value {
            if c2.value == c4.value {
                return true
            }
            else {
                return false
            }
        }
        else {
            return false
        }
    }
    func type(is3b:[Card]) -> Bool {
        if is3b.count != 3 {
            return false
        }
        
        let first = is3b.first!.value
        for card in is3b {
            if card.value != first {
                return false
            }
        }
        return true
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
