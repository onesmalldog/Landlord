//
//  HandCard.swift
//  DouDiZhu
//
//  Created by gg on 2021/1/8.
//

import Foundation

/// 手牌
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
    
    /// 获取当前手牌所包含的种类
    public var pattern : CardPattern {
        get {
            return CardPattern(cards: cards)
        }
    }
    
    func cardStyle(pattern:CardPattern) -> [CardStyle] {
        let p = self.pattern
        
        if p.styles.count == 0 {
            if pattern.styles.contains(.sheet) {
                return sheet
            }
        }
        else if p.styles.count == 1 {
            let style = p.styles.first!
            if pattern.styles.contains(.sheet) && style == .unsolvable {
                return sheet
            }
        }
        
        var res : [CardStyle] = []
        for style in pattern.styles {
            if p.styles.contains(style) {
                
                switch style {
                case .sheet:
                    res.append(contentsOf: sheet)
                    break
                case .pair:
                    res.append(contentsOf: pair)
                    break
                
                case .threeBelt:
                    res.append(contentsOf: threeBelt)
                    break
                case .threeBeltOne:
                    res.append(contentsOf: threeBelt)
                    break
                case .threeBeltPair:
                    res.append(contentsOf: threeBelt)
                    break
                
                case .consequent:
                    res.append(contentsOf: consequent)
                    break
                
                case .consequentPair:
                    res.append(contentsOf: consequentPair)
                    break
                
                case .plane:
                    res.append(contentsOf: plane)
                    break
                case .planeBeltOne:
                    res.append(contentsOf: plane)
                    break
                case .planeBeltPair:
                    res.append(contentsOf: plane)
                    break
                
                case .fourBeltTwo:
                    res.append(contentsOf: bomb)
                    break
                case .fourBeltTwoPair:
                    res.append(contentsOf: bomb)
                    break
                
                case .bomb:
                    res.append(contentsOf: bomb)
                    break
                default:
                    break
                }
                
            }
        }
        return res
    }
    
    public var sheet : [CardStyleSheet] {
        get {
            var res : [CardStyleSheet] = []
//            for card in cards {
//                if card.style.count == 0 {
//                    res.append(card)
//                }
//            }
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
    
    public let cards : [Card]
    
    init(source:[Card]) {
        self.cards = source
        super.init()
    }
    
    static func removeDiscontinuous(source:[CardStyle]) -> [CardStyle] {
        var res = source
        
        for i in 0..<source.count {
            let c = source[i]
            if c.cards.first!.number == .c2 || c.cards.first!.type == .joker {
                res.remove(at: i)
            }
        }
        return res
    }
    
}

class CardStyleSheet: CardStyle {
    
}

class CardStyleConsequent: CardStyle {
    
    var count : Int {
        get {
            return cards.count
        }
    }
    
    var maxValue : Int {
        get {
            if count == 0 {
                return 0
            }
            return cards.first!.value
        }
    }
    
    var minValue : Int {
        get {
            if count == 0 {
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
                return cards
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
        if cards.count < 5 {
            return []
        }
        if cards.last!.value > 14 {
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
            var plan : [Card] = [c.cards.first!]
            while i < belts.count-1 {
                let next = plans[i+1].cards.first!
                let last = plans[i].cards.first!
                if last.value == 13 && next.value == 1 {
                    plan.append(plans[i+1].cards.first!)
                    i = i+1
                }
                else if next.value - last.value == 1 {
                    plan.append(plans[i+1].cards.first!)
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
    
    var value : Int {
        get {
            guard let res = self.cards.first?.value else {
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
                if next.cards.first!.value - pair.cards.first!.value == 1 {
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
            cards.append(contentsOf: pair.cards)
        }
        super.init(source: cards)
    }
}
