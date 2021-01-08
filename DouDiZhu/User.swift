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
    
    var lastPlayedCards : [Card]?
    
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
    
    func updateCards() {
        
//        for card in handCard.cards {
//            card.updateStyle()
//        }
        _ = handCard.pair
        _ = handCard.threeBelt
        _ = handCard.bomb
        _ = handCard.consequent
        _ = handCard.consequentPair
    }
}

extension User {
    func playCards() -> [Card] {
        
        if let lastCards = CardManager.shared.lastPlayedCards {
            let cardType = CardPattern(cards: lastCards).styles.first
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
            case .consequent:
                for conseq in handCard.consequent {
                    if conseq.count >= lastCards.count {
                        if conseq.maxValue > lastCards.first!.value {
                            return getCards(cards: conseq.cards!, fromCount: lastCards.count, maxer: true)
                        }
                    }
                }
                break
            case .threeBelt:
                for threeBelt in handCard.threeBelt {
                    if threeBelt.cards!.first!.value > lastCards.first!.value {
                        return threeBelt.cards!
                    }
                }
                break
            case .threeBeltOne:
                let lastSep = Card.separated(cards: lastCards, type: .threeBeltOne)
                if lastSep.count == 2 {
                    var threeBeltValue = 0
                    if lastSep.first!.count == 3 {
                        threeBeltValue = lastSep.first!.first!.value
                    }
                    else {
                        threeBeltValue = lastSep.last!.first!.value
                    }
                    for threeBelt in handCard.threeBelt {
                        if threeBelt.cards!.first!.value > threeBeltValue {
                            return threeBelt.cards!
                        }
                    }
                }
                break
            case .threeBeltPair:
                let lastSep = Card.separated(cards: lastCards, type: .threeBeltPair)
                if lastSep.count == 2 {
                    var threeBeltValue = 0
                    if lastSep.first!.count == 3 {
                        threeBeltValue = lastSep.first!.first!.value
                    }
                    else {
                        threeBeltValue = lastSep.last!.first!.value
                    }
                    for threeBelt in handCard.threeBelt {
                        if threeBelt.cards!.first!.value > threeBeltValue {
                            if let pairs = handCard.pair.last {
                                var res : [Card] = threeBelt.cards!
                                res.append(contentsOf: pairs.cards!)
                                return res
                            }
                            else {
                                break
                            }
                        }
                    }
                }
                break
            case .consequentPair:
                break
            default:
                break
            }
        }
        else {
            if (handCard.plane.count > 0) {
                return handCard.plane.first!.cards!
            }
            else if (handCard.consequent.count > 0) {
                return handCard.consequent.first!.cards!
            }
            else if (handCard.pair.count > 0) {
                return handCard.pair.first!.cards!
            }
            else if handCard.sheet.count > 0 {
                return [handCard.sheet.last!]
            }
            else if (handCard.bomb.count > 0) {
                return handCard.bomb.first!.cards!
            }
        }
        return []
    }
    
    
    /// 获取连续的前几个
    /// - Parameters:
    ///   - fromCount: 从第几个开始
    ///   - maxer: true for prefix， false for suffix
    func getCards(cards:[Card], fromCount:Int, maxer:Bool) -> [Card] {
        if cards.count > fromCount  {
            if maxer {
                return Array(cards.prefix(fromCount))
            }
            else {
                return Array(cards.suffix(fromCount))
            }
        }
        else if cards.count == fromCount {
            return cards
        }
        else {
            return []
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
