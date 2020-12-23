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
    typealias completeBlock = () -> (Void)
    func dealCards() -> [[Card]] {
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
        return [user, left, right]
    }
}

class HandCards: NSObject {
    
    public var cards : [Card]
    
    public var pair : [Card] {
        get {
            return pair(source: cards)
        }
    }
    
    public var consequent : [Card] {
        get {
            return consequent(source: cards)
        }
    }
    
    public var bomb : [[Card]] {
        get {
            return bomb(source: cards)
        }
    }
    
    init(cards:[Card]) {
        self.cards = cards
        super.init()
        self.cards = sortDataSource(source: cards)
    }
    
    
    func pair(source:[Card]) -> [Card] {
        var res : [Card] = []
        if source.count < 2 {
            return res
        }
        var hash : [Int:Int] = [:]
        for c in source {
            var ctt = hash[c.value]
            if ctt != nil {
                ctt! += 1
            }
            else {
                ctt = 1
            }
            if ctt == 2 {
                res.append(c)
            }
            hash[c.value] = ctt!
        }
        return res
    }
    
    func plane(source:[Card]) -> [[Card]] {
        if source.count < 6 {
            return []
        }
        let sorted = removeDiscontinuous(source: sortDataSource(source: source))
        var belts = threeBelt(source: sorted)
        if belts.count < 2 {
            return []
        }
        
        var res : [[Card]] = []
        var i = 0
        while i<belts.count {
            let c = belts[i]
            var plan : [[Card]] = [c]
            while i < belts.count-1 {
                let next = belts[i+1].first!
                let last = belts[i].first!
                if last.value == 13 && next.value == 1 {
                    plan.append(belts[i+1])
                    i = i+1
                }
                else if next.value - last.value == 1 {
                    plan.append(belts[i+1])
                    i = i+1
                }
                else {
                    break
                }
            }
            if plan.count > 1 {
//                res.append(plan)
            }
            plan = []
            i += 1
        }
        
        return res
    }
    
    func threeBelt(source:[Card]) -> [[Card]] {
        if source.count < 3 {
            return []
        }
        var values : [Int] = []
        var hash : [Int:Int] = [:]
        for c in source {
            var ctt = hash[c.value]
            if ctt != nil {
                ctt! += 1
            }
            else {
                ctt = 1
            }
            if ctt == 3 {
                values.append(c.value)
            }
            hash[c.value] = ctt!
        }
        var res : [[Card]] = []
        for value in values {
            var belt : [Card] = []
            for c in source {
                if value == c.value {
                    belt.append(c)
                }
            }
            res.append(belt)
        }
        return res
    }
    
    func bomb(source:[Card]) -> [[Card]] {
        if source.count < 4 {
            return []
        }
        var values : [Int] = []
        var hash : [Int:Int] = [:]
        for c in source {
            var ctt = hash[c.value]
            if ctt != nil {
                ctt! += 1
            }
            else {
                ctt = 1
            }
            if ctt == 4 {
                values.append(c.value)
            }
            hash[c.value] = ctt!
        }
        var res : [[Card]] = []
        for value in values {
            var bomb : [Card] = []
            for c in source {
                if value == c.value {
                    bomb.append(c)
                }
            }
            res.append(bomb)
        }
        
        return res
    }
    
    func consequent(source:[Card]) -> [Card] {
        let sorted = sortDataSource(source: source)
        var res : [Card] = []
        if sorted.first!.value > 14 {
            return res
        }
        if sorted.count < 5 {
            return res
        }
        
        for i in 0..<sorted.count {
            let c = sorted[i]
            if i < sorted.count-1 {
                let next = sorted[i+1]
                if c.value == 13 {
                    if next.value == 1 {
                        res.append(c)
                        res.append(next)
                        break
                    }
                    else if next.value == 13 {
                        continue
                    }
                    else {
                        if res.count >= 4 {
                            res.append(c)
                            break
                        }
                        res = []
                        break
                    }
                }
                
                if c.value - next.value > 1 {
                    if res.count >= 4 {
                        res.append(c)
                        break
                    }
                    res = []
                    continue
                }
                else if c.value - next.value == 0 {
                    continue
                }
                else {
                    res.append(c)
                }
            }
            else {
                if res.count >= 4 {
                    res.append(c)
                    break
                }
                else {
                    res = []
                    break
                }
            }
        }
        return res
    }
    
    func removeDiscontinuous(source:[Card]) -> [Card] {
        var res = source
        
        for i in 0..<source.count {
            let c = source[i]
            if c.number == .c2 || c.type == .joker {
                res.remove(at: i)
            }
        }
        
        return res
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
}

class CardStyleConsequent: CardStyle {
    
}

class CardStyleBomb: CardStyle {
    
}

class CardStyleThreeBelt: CardStyle {
    
}

class CardStylePlane: CardStyle {
    
}

class CardStylePair: CardStyle {
    
}
