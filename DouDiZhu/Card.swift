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

enum CardStyleLevel : Int {
    case sheet = 0
    case pair = 1
    case consequent = 2
    case threeBelt = 3
    case threeBeltOne = 4
    case threeBeltPair = 5
    case consequentPair = 6
    case plane = 10
    case planeBeltOne = 11
    case planeBeltPair = 12
    case fourBeltTwo = 13
    case fourBeltTwoPair = 14
    case bomb = 20
    case unsolvable = 100
}

class Card : NSObject {
    let value : Int
    let color : CardColor
    let number : CardNumber
    let type : CardType
    
    var isLandlord : Bool
    
    var style : [CardStyleLevel] = []
    
    var select = false
    
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
        self.isLandlord = false
        super.init()
        
    }
}

class HandCards: NSObject {
    
    public var cards : [Card]
    
    public var selectedCards : [Card] {
        get {
            var res : [Card] = []
            for card in cards {
                if card.select {
                    res.append(card)
                }
            }
            return res
        }
    }
    
    public var sheet : [Card] {
        get {
            var res : [Card] = []
            for card in cards {
                if card.style.count == 0 {
                    res.append(card)
                }
            }
            return res
        }
    }
    
    public var pair : [CardStylePair] {
        get {
            return CardStylePair.pair(source: self)
        }
    }
    
    public var consequentPair : [CardStyleConsequentPair] {
        get {
            return CardStyleConsequentPair.consequentPair(source: self)
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
        self.cards = CardManager.shared.sortDataSource(source: cards)
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
    
    var count : Int {
        get {
            guard let ctt = cards?.count else {
                return 0
            }
            return ctt
        }
    }
    
    var maxValue : Int {
        get {
            guard let cards = cards else {
                return 0
            }
            if cards.count == 0 {
                return 0
            }
            return cards.first!.value
        }
    }
    
    var minValue : Int {
        get {
            guard let cards = cards else {
                return 0
            }
            if cards.count == 0 {
                return 0
            }
            return cards.last!.value
        }
    }
    
    func larger(than:[Card]) -> [Card] {
        let sort = than.sorted(by: { (a, b) -> Bool in
            return a.value > b.value
        })
        if count < sort.count {
            return []
        }
        else if count == sort.count {
            if maxValue > sort.first!.value {
                return cards!
            }
        }
        else {
            if maxValue > sort.first!.value {
                
            }
            else {
                return []
            }
        }
        return []
    }
    
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
            for card in seq {
                card.style.append(.consequent)
            }
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
                for card in cards! {
                    card.style.append(.bomb)
                }
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
                for card in cards! {
                    card.style.append(.threeBelt)
                }
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
                for card in plan {
                    card.style.append(.plane)
                }
                res.append(CardStylePlane(source: plan))
            }
            plan = []
            i += 1
        }
        return res
    }
}

class CardStylePair: CardStyle {
    
    var value : Int {
        get {
            guard let res = self.cards?.first?.value else {
                return 0
            }
            return res
        }
    }
    
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
                for card in cards! {
                    card.style.append(.pair)
                }
                res.append(CardStylePair(source: cards!))
            }
            hash[c.value] = cards!
        }
        return res
    }
}

class CardStyleConsequentPair: CardStyle {
    static func consequentPair(source:HandCards) -> [CardStyleConsequentPair] {
        if source.cards.count < 6 {
            return []
        }
        var res : [CardStyleConsequentPair] = []
        let pairs : [CardStylePair] = CardStylePair.pair(source: source)
        var pairConsequent : [CardStylePair] = []
        for (i, pair) in pairs.enumerated() {
            if i < pairs.count - 1 {
                let next = pairs[i+1]
                if next.cards!.first!.value - pair.cards!.first!.value == 1 {
                    pairConsequent.append(pair)
                }
                else {
                    if pairConsequent.count > 2 {
                        res.append(CardStyleConsequentPair(pairs: pairConsequent))
                    }
                    else {
                        pairConsequent = []
                    }
                }
            }
        }
        return res
    }
    init(pairs: [CardStylePair]) {
        var cards : [Card] = []
        for pair in pairs {
            cards.append(contentsOf: pair.cards!)
        }
        super.init(source: cards)
    }
}
