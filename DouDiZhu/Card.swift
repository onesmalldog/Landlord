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
        super.init()
        
    }
}

extension Card {
    static func separated(cards:[Card], type:CardStyleLevel) -> [[Card]] {
        
        switch type {
        case .fourBeltTwo:
            fallthrough
        case .fourBeltTwoPair:
            fallthrough
        case .threeBeltOne:
            fallthrough
        case .threeBeltPair:
            var hash : [Int : [Card]] = [:]
            for card in cards {
                var res = hash[card.value]
                if res == nil {
                    res = [card]
                }
                else {
                    res!.append(card)
                }
                hash[card.value] = res
            }
            var res : [[Card]] = []
            for value in hash.keys {
                res.append(hash[value]!)
            }
            return res
        default:
            return [cards]
        }
    }
}
