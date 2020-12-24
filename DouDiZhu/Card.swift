//
//  Card.swift
//  DouDiZhu
//
//  Created by lizhengang on 2020/12/21.
//

import Foundation

enum CardType {
    case normal
    case joker
}

enum CardColor : String {
    case block = "block"
    case heart = "heart"
    case plum = "plum"
    case spade = "spade"
    case joker = "joker"
}

enum CardNumber : Int {
    case c1 = 14
    case c2 = 15
    case c3 = 3
    case c4 = 4
    case c5 = 5
    case c6 = 6
    case c7 = 7
    case c8 = 8
    case c9 = 9
    case c10 = 10
    case c11 = 11
    case c12 = 12
    case c13 = 13
    case cJokerSmall = 20
    case cJokerLarge = 21
}

class Card : NSObject {
    let value : Int
    let color : CardColor
    let number : CardNumber
    let type : CardType
    init(color:CardColor, number:CardNumber) {
        self.color = color
        self.number = number
        self.value = number.rawValue
        if number.rawValue < 20 {
            self.type = .normal
        }
        else {
            self.type = .joker
        }
        super.init()
        
    }
}

class CardManager: NSObject {
    static let `shared` = CardManager()
    
    var leftHandCard : HandCards?
    var rightHandCard : HandCards?
    var userHandCard : HandCards?
    
    var originCards : [Card] {
        get {
            var cards : [Card] = []
            let colors = [CardColor.block, CardColor.heart, CardColor.plum, CardColor.spade]
            for i in 0..<4 {
                for j in 3..<16 {
                    let num = CardNumber(rawValue: j)!
                    let card = Card(color: colors[i], number: num)
                    cards.append(card)
                }
            }
            let smallJoker = Card(color: .joker, number: CardNumber(rawValue: 20)!)
            let largeJoker = Card(color: .joker, number: CardNumber(rawValue: 21)!)
            cards.append(smallJoker)
            cards.append(largeJoker)
            return cards
        }
    }
    
    func dealCards() {
        var all = originCards
        var left : [Card] = []
        var right : [Card] = []
        var user : [Card] = []
        
        while all.count > 3 {
            let random1 = Int(arc4random() % UInt32(all.count))
            left.append(all[random1])
            all.remove(at: random1)
            
            let random2 = Int(arc4random() % UInt32(all.count))
            right.append(all[random2])
            all.remove(at: random2)
            
            let random3 = Int(arc4random() % UInt32(all.count))
            user.append(all[random3])
            all.remove(at: random3)
        }
        userHandCard = HandCards(cards: user)
        leftHandCard = HandCards(cards: left)
        rightHandCard = HandCards(cards: right)
    }
}

class HandCards: NSObject {
    
    public var cards : [Card]
    
    public var pair : [CardStylePair] {
        get {
            return CardStylePair.pair(source: self)
        }
    }
    
    public var consequent : [CardStyleConsequent] {
        get {
            return CardStyleConsequent.consequent(source: self)
        }
    }
    
    public var bomb : [CardStyleBomb] {
        get {
            return CardStyleBomb.bomb(source: self)
        }
    }
    
    public var plane : [CardStylePlane] {
        get {
            return CardStylePlane.plane(source: self)
        }
    }
    
    public var threeBelt : [CardStyleThreeBelt] {
        get {
            return CardStyleThreeBelt.threeBelt(source: self)
        }
    }
    
    init(cards:[Card]) {
        self.cards = cards
        super.init()
        self.cards = sortDataSource(source: cards)
    }
    
    func sortDataSource(source:[Card]) -> [Card] {
        var sort = source
        sort.sort { (a, b) -> Bool in
            return a.value > b.value
        }
        return sort
    }
}

class CardStyle: NSObject {
    
    open var cards : [Card]?
    
    init(source:[Card]) {
        super.init()
        cards = source
    }
    
    static func removeDiscontinuous(source:[CardStyle]) -> [CardStyle] {
        var res = source
        
        for i in 0..<source.count {
            let c = source[i]
            if c.cards!.first!.number == .c2 || c.cards!.first!.type == .joker {
                res.remove(at: i)
            }
        }
        
        return res
    }
    
}

class CardStyleConsequent: CardStyle {
    static func consequent(source:HandCards) -> [CardStyleConsequent] {
        let cards = source.cards
        if cards.last!.value > 14 {
            return []
        }
        if cards.count < 5 {
            return []
        }
        var seq : [Card] = []
        for i in 0..<cards.count {
            let c = cards[i]
            if c.value > 14 {
                continue
            }
            if i == cards.count-1 {
                if seq.count >= 4 {
                    seq.append(c)
                }
                else {
                    seq = []
                }
            }
            else {
                let next = cards[i+1]
                if c.value - next.value == 1 {
                    seq.append(c)
                }
                else {
                    if seq.count >= 4 {
                        seq.append(c)
                        break
                    }
                    else {
                        seq = []
                    }
                }
            }
        }
        if seq.count > 0 {
            return [CardStyleConsequent(source: seq)]
        }
        return []
    }
}

class CardStyleBomb: CardStyle {
    public static func bomb(source:HandCards) -> [CardStyleBomb] {
        let cards = source.cards
        if cards.count < 4 {
            return []
        }
        
        var res : [CardStyleBomb] = []
        var hash : [Int:[Card]] = [:]
        for c in cards {
            var cards = hash[c.value]
            if cards != nil {
                cards!.append(c)
            }
            else {
                cards = [c]
            }
            if cards!.count == 4 {
                res.append(CardStyleBomb(source: cards!))
            }
            hash[c.value] = cards!
        }
        return res
    }
    
}

class CardStyleThreeBelt: CardStyle {
    static func threeBelt(source:HandCards) -> [CardStyleThreeBelt] {
        let cards = source.cards
        if cards.count < 4 {
            return []
        }
        
        var res : [CardStyleThreeBelt] = []
        var hash : [Int:[Card]] = [:]
        for c in cards {
            var cards = hash[c.value]
            if cards != nil {
                cards!.append(c)
            }
            else {
                cards = [c]
            }
            if cards!.count == 3 {
                res.append(CardStyleThreeBelt(source: cards!))
            }
            hash[c.value] = cards!
        }
        return res
    }
}

class CardStylePlane: CardStyleThreeBelt {
    static func plane(source:HandCards) -> [CardStylePlane] {
        let cards = source.cards
        if cards.count < 6 {
            return []
        }
        
        let belts = source.threeBelt
        let plans = removeDiscontinuous(source: belts) as! [CardStyleThreeBelt]
        if plans.count < 2 {
            return []
        }
        
        var res : [CardStylePlane] = []
        var i = 0
        while i<plans.count {
            let c = plans[i]
            var plan : [Card] = [c.cards!.first!]
            while i < belts.count-1 {
                let next = plans[i+1].cards!.first!
                let last = plans[i].cards!.first!
                if last.value == 13 && next.value == 1 {
                    plan.append(plans[i+1].cards!.first!)
                    i = i+1
                }
                else if next.value - last.value == 1 {
                    plan.append(plans[i+1].cards!.first!)
                    i = i+1
                }
                else {
                    break
                }
            }
            if plan.count > 1 {
                res.append(CardStylePlane(source: plan))
            }
            plan = []
            i += 1
        }
        return res
    }
}

class CardStylePair: CardStyle {
    static func pair(source:HandCards) -> [CardStylePair] {
        if source.cards.count < 2 {
            return []
        }
        var res : [CardStylePair] = []
        var hash : [Int:[Card]] = [:]
        for c in source.cards {
            var cards = hash[c.value]
            if cards != nil {
                cards!.append(c)
            }
            else {
                cards = [c]
            }
            if cards!.count == 2 {
                res.append(CardStylePair(source: cards!))
            }
            hash[c.value] = cards!
        }
        return res
    }
}
