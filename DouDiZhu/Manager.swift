//
//  Manager.swift
//  DouDiZhu
//
//  Created by gg on 2020/12/24.
//

import Foundation

protocol CardManagerDelegate {
    func didBeganGame(fromUser:User)
    func nextChoice(user:User)
}

class CardManager: NSObject {
    static let `shared` = CardManager()
    var delegate : CardManagerDelegate?
    
    var landlord : User? {
        willSet {
            
        }
        didSet {
            delegate?.didBeganGame(fromUser: landlord!)
        }
    }
    
    var leftBoot : User?
    var rightBoot : User?
    var user : User?
    
    var table : [Card]?
    
    var currentSelectUser : User?
    
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
        var center : [Card] = []
        
        let landlord = Int(arc4random() % UInt32(all.count))
        let card = all[landlord]
        card.isLandlord = true
        
        while all.count > 3 {
            let random1 = Int(arc4random() % UInt32(all.count))
            left.append(all[random1])
            all.remove(at: random1)
            
            let random2 = Int(arc4random() % UInt32(all.count))
            right.append(all[random2])
            all.remove(at: random2)
            
            let random3 = Int(arc4random() % UInt32(all.count))
            center.append(all[random3])
            all.remove(at: random3)
        }
        
        table = all
        
        user = User(cards: center)
        leftBoot = User(cards: left)
        rightBoot = User(cards: right)
    }
}
