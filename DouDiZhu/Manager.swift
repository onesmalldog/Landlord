//
//  Manager.swift
//  DouDiZhu
//
//  Created by gg on 2020/12/24.
//

import Foundation

class CardManager: NSObject {
    static let `shared` = CardManager()
    
    var landlord : User? {
        willSet {
            
        }
        didSet {
            beganGame(fromUser: landlord!)
        }
    }
    
    var leftBoot : User?
    var rightBoot : User?
    var user : User?
    
    var landlordCachedCards : [Card]?
    
    var lastPlayedCards : [Card]?
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
    
    func sortDataSource(source:[Card]) -> [Card] {
        var sort = source
        sort.sort { (a, b) -> Bool in
            return a.value > b.value
        }
        return sort
    }
}

extension CardManager {
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
        
        landlordCachedCards = all
        
        user = User(cards: center)
        leftBoot = User(cards: left)
        rightBoot = User(cards: right)
    }
    
    func nextChoice(user: User) {
        if user == self.user {
            user.deskView!.toolType = .choicing
            print("等待玩家选择")
            return
        }
        user.deskView?.toolType = .choicing
        var selectType = user.thinkingLandlord()
        if user.choiceCtt > 1 {
            if selectType.rawValue == CardManager.shared.currentSelectUser!.selectCardType.rawValue {
                selectType = BtnType(rawValue: selectType.rawValue+1)!
            }
            else if selectType.rawValue < CardManager.shared.currentSelectUser!.selectCardType.rawValue {
                selectType = .cancel
            }
        }
        print(user)
        print("选择了")
        print(selectType)
        user.selectCardType = selectType
        switch selectType {
        case .cancel:
            if user.choiceCtt < 3 {
                currentSelectUser = user
                nextChoice(user: user.next())
            }
            else {
                landlord = currentSelectUser!
            }
            break
        case .b1:
            currentSelectUser = user
            if user.choiceCtt < 3 {
                nextChoice(user: user.next())
            }
            else {
                landlord = user
            }
            break
        case .b2:
            currentSelectUser = user
            if user.choiceCtt < 3 {
                nextChoice(user: user.next())
            }
            else {
                landlord = user
            }
            break
        case .b3:
            currentSelectUser = user
            landlord = user
            break
        default:
            break
        }
    }
}

extension CardManager {
    
    func beganGame(fromUser: User) {
        currentSelectUser = fromUser
        currentSelectUser!.isLandlord = true
        fromUser.deskView?.toolType = .hidden
        user!.deskView!.cardContainerView.isUserInteractionEnabled = true
        print("now began game from")
        print(fromUser)
        
        nextPlay(user: fromUser)
    }
    
    func nextPlay(user:User) {
        if user == self.user {
            user.deskView!.toolType = .playing
        }
        else {
            let playCards = user.playCards()
            if playCards.count > 0 {
                lastPlayedCards = playCards
            }
            nextPlay(user: user.next())
        }
    }
}

extension CardManager : UserDeskViewDelegate {
    func didClick(toolView: ToolView, btnType: BtnType) {
        let user = CardManager.shared.user!
        if toolView == user.deskView!.choicingToolV {
            user.selectCardType = btnType
            CardManager.shared.currentSelectUser = user
            switch btnType {
            case .cancel:
                nextChoice(user: user.next())
                break
            case .b1:
                nextChoice(user: user.next())
                break
            case .b2:
                nextChoice(user: user.next())
                break
            case .b3:
                landlord = user
                break
            default:
                break
            }
        }
        else if toolView == user.deskView!.playingToolV {
            switch btnType {
            case .alert:
                break
            case .cancel:
                nextPlay(user: user.next())
                break
            case .play:
                lastPlayedCards = user.handCard.selectedCards
                nextPlay(user: user.next())
                break
            default:
                break
            }
        }
        user.deskView!.toolType = .hidden
    }
}
