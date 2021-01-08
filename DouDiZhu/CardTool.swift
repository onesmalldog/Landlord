//
//  CardTool.swift
//  DouDiZhu
//
//  Created by gg on 2021/1/8.
//

import Foundation

enum CardStyleLevel : Int {
    case sheet = 0
    case pair = 1
    
    case threeBelt = 10
    case threeBeltOne = 11
    case threeBeltPair = 12
    
    case consequent = 20
    
    case consequentPair = 25
    
    case plane = 30
    case planeBeltTwo = 31
    case planeBeltTwoPair = 32
    
    case fourBeltTwo = 90
    case fourBeltTwoPair = 91
    
    case bomb = 100
    
    case unsolvable = 999
}

/// 种类，牌型
class CardPattern: NSObject {
    
    public var styles : [CardStyleLevel] {
        get {
            return getStyles()
        }
    }
    
    let cardsHash : [Int:Int]
    let contains : [Int]
    
    private let cards : [Card]
    init(cards:[Card]) {
        self.cards = cards
        var hash : [Int:Int] = [:]
        var containt : [Int] = []
        for card in cards {
            var ctt = hash[card.value]
            if ctt == nil {
                ctt = 1
            }
            else {
                ctt! += 1
            }
            hash[card.value] = ctt!
            if ctt! == 2 {
                containt.append(2)
            }
            else if ctt! == 3 {
                containt.append(3)
                containt.remove(2)
            }
            else if ctt! == 4 {
                containt.append(4)
                containt.remove(3)
            }
        }
        self.cardsHash = hash
        self.contains = containt
        super.init()
    }
}

private extension CardPattern {
    func getStyles() -> [CardStyleLevel] {
        
        var res : [CardStyleLevel] = []
        
        var ctt2 = 0, ctt3 = 0
        for c in contains {
            if c == 2 {
                ctt2 += 1
            }
            else if c == 3 {
                ctt3 += 1
            }
        }
        
        if contains.contains(4) {
            res.append(.bomb)
            if ctt2 > 0 {
                res.append(.fourBeltTwo)
            }
            if ctt2 > 1 {
                res.append(.fourBeltTwoPair)
            }
        }
        
        if contains.contains(3) || contains.contains(4) {
            res.append(.threeBelt)
            if cards.count > 3 {
                res.append(.threeBeltOne)
            }
            if ctt2 > 0 {
                res.append(.threeBeltPair)
            }
        }
        
        if cards.count >= 6 && ctt3 > 1 {
            var hasPlane = false
            var keys : [Int] = []
            for key in cardsHash.keys {
                if cardsHash[key]! >= 3 {
                    keys.append(key)
                }
            }
            for (i, key) in keys.sorted().enumerated() {
                if i < keys.count-1 {
                    let next = keys[i+1]
                    if abs(next - key) == 1 {
                        res.append(.plane)
                        hasPlane = true
                        break
                    }
                }
            }
            if hasPlane {
                if cards.count >= 8 {
                    res.append(.planeBeltTwo)
                }
                if ctt2 > 1 {
                    res.append(.planeBeltTwoPair)
                }
            }
        }
        
        if type(hasConsequent: cards) {
            res.append(.consequent)
        }
        
        if typehascon {
            <#code#>
        }
        
        return res
    }
    
    /// 获取类型
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

/// 种类精确判断
fileprivate extension CardPattern {
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

/// 种类包含判断
fileprivate extension CardPattern {
    func type(hasPair:[Card]) -> Bool {
        if hasPair.count < 2 {
            return false
        }
        if hasPair.count == 2 {
            let c1 = hasPair.first!, c2 = hasPair.last!
            return c1.value == c2.value
        }
        var hash : [Int:Int] = [:]
        for card in hasPair {
            var ctt = hash[card.value]
            if ctt == nil {
                ctt = 1
            }
            else {
                ctt! += 1
                if ctt! == 2 {
                    return true
                }
            }
            hash[card.value] = ctt!
        }
        return false
    }
    func type(has4b2pair:[Card]) -> Bool {
        if has4b2pair.count < 8 {
            return false
        }
        let cards = CardManager.shared.sortDataSource(source: has4b2pair)
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
        
        let values = hash.values
        if values.contains(4) {
            var ctt = 0
            for value in values {
                if value == 2 {
                    ctt += 1
                }
            }
            if ctt > 1 {
                return true
            }
        }
        return false
    }
    func type(has4b2:[Card]) -> Bool {
        if has4b2.count < 6 {
            return false
        }
        var hash : [Int:Int] = [:]
        for card in has4b2 {
            var ctt = hash[card.value]
            if ctt == nil {
                ctt = 1
            }
            else {
                ctt! += 1
            }
            hash[card.value] = ctt!
            if ctt! == 4 {
                return true
            }
        }
        return false
    }
    func type(hasConsequent:[Card]) -> Bool {
        if hasConsequent.count < 5 {
            return false
        }
        var conseqCtt = 0
        /// TODO: has的逻辑需要改
        let firstValue = hasConsequent.first!.value
        for (i, card) in hasConsequent.enumerated() {
            if card.value != firstValue + i {
                if conseqCtt < 5 {
                    return false
                }
                break
            }
            conseqCtt += 1
        }
        return true
    }
    func type(hasConsequentPair:[Card]) -> Bool {
        if hasConsequentPair.count < 6 {
            return false
        }
        var conseqCtt = 0
        let firstValue = hasConsequent.first!.value
        for (i, card) in hasConsequent.enumerated() {
            if card.value != firstValue + i {
                if conseqCtt < 5 {
                    return false
                }
                break
            }
            conseqCtt += 1
        }
        return true
    }
    func type(has3b2:[Card]) -> Bool {
        if has3b2.count < 5 {
            return false
        }
        var hash : [Int:Int] = [:]
        for card in has3b2 {
            var ctt = hash[card.value]
            if ctt == nil {
                ctt = 1
            }
            else {
                ctt! += 1
            }
            hash[card.value] = ctt!
        }
        return hash.values.contains(3) && hash.values.contains(2)
    }
    func type(hasBomb:[Card]) -> Bool {
        if hasBomb.count < 4 {
            return false
        }
        var hash : [Int:Int] = [:]
        for card in hasBomb {
            var ctt = hash[card.value]
            if ctt == nil {
                ctt = 1
            }
            else {
                ctt! += 1
            }
            hash[card.value] = ctt!
            if ctt! == 4 {
                return true
            }
        }
        return false
    }
    func type(has3b1:[Card]) -> Bool {
        if has3b1.count < 4 {
            return false
        }
        var hash : [Int:Int] = [:]
        for card in has3b1 {
            var ctt = hash[card.value]
            if ctt == nil {
                ctt = 1
            }
            else {
                ctt! += 1
            }
            hash[card.value] = ctt!
            if ctt! == 3 {
                return true
            }
        }
        return false
    }
    func type(has3b:[Card]) -> Bool {
        if has3b.count != 3 {
            return false
        }
        
        var hash : [Int:Int] = [:]
        for card in has3b {
            var ctt = hash[card.value]
            if ctt == nil {
                ctt = 1
            }
            else {
                ctt! += 1
            }
            hash[card.value] = ctt!
            if ctt! == 3 {
                return true
            }
        }
        return false
    }
}

private extension CardPattern {
    func hasPair() -> Bool {
        if cards.count < 2 {
            return false
        }
        if cards.count == 2 {
            let c1 = cards.first!, c2 = cards.last!
            return c1.value == c2.value
        }
        return cardsHash.values.contains(2)
    }
    func type(has4b2pair:[Card]) -> Bool {
        if has4b2pair.count < 8 {
            return false
        }
        let cards = CardManager.shared.sortDataSource(source: has4b2pair)
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
        
        let values = hash.values
        if values.contains(4) {
            var ctt = 0
            for value in values {
                if value == 2 {
                    ctt += 1
                }
            }
            if ctt > 1 {
                return true
            }
        }
        return false
    }
    func type(has4b2:[Card]) -> Bool {
        if has4b2.count < 6 {
            return false
        }
        var hash : [Int:Int] = [:]
        for card in has4b2 {
            var ctt = hash[card.value]
            if ctt == nil {
                ctt = 1
            }
            else {
                ctt! += 1
            }
            hash[card.value] = ctt!
            if ctt! == 4 {
                return true
            }
        }
        return false
    }
    func type(hasConsequent:[Card]) -> Bool {
        if hasConsequent.count < 5 {
            return false
        }
        var conseqCtt = 0
        let firstValue = hasConsequent.first!.value
        for (i, card) in hasConsequent.enumerated() {
            if card.value != firstValue + i {
                if conseqCtt < 5 {
                    return false
                }
                break
            }
            conseqCtt += 1
        }
        return true
    }
    func type(has3b2:[Card]) -> Bool {
        if has3b2.count < 5 {
            return false
        }
        var hash : [Int:Int] = [:]
        for card in has3b2 {
            var ctt = hash[card.value]
            if ctt == nil {
                ctt = 1
            }
            else {
                ctt! += 1
            }
            hash[card.value] = ctt!
        }
        return hash.values.contains(3) && hash.values.contains(2)
    }
    func type(hasBomb:[Card]) -> Bool {
        if hasBomb.count < 4 {
            return false
        }
        var hash : [Int:Int] = [:]
        for card in hasBomb {
            var ctt = hash[card.value]
            if ctt == nil {
                ctt = 1
            }
            else {
                ctt! += 1
            }
            hash[card.value] = ctt!
            if ctt! == 4 {
                return true
            }
        }
        return false
    }
    func type(has3b1:[Card]) -> Bool {
        if has3b1.count < 4 {
            return false
        }
        var hash : [Int:Int] = [:]
        for card in has3b1 {
            var ctt = hash[card.value]
            if ctt == nil {
                ctt = 1
            }
            else {
                ctt! += 1
            }
            hash[card.value] = ctt!
            if ctt! == 3 {
                return true
            }
        }
        return false
    }
    func type(has3b:[Card]) -> Bool {
        if has3b.count != 3 {
            return false
        }
        
        var hash : [Int:Int] = [:]
        for card in has3b {
            var ctt = hash[card.value]
            if ctt == nil {
                ctt = 1
            }
            else {
                ctt! += 1
            }
            hash[card.value] = ctt!
            if ctt! == 3 {
                return true
            }
        }
        return false
    }
}
