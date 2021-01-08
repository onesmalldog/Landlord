//
//  Manager.swift
//  DouDiZhu
//
//  Created by gg on 2020/12/24.
//

import Foundation

enum LandlordSelectionType : Int {
    case none = -1
    case b1 = 1
    case b2 = 2
    case b3 = 3
}

class CardManager: NSObject {
    static let `shared` = CardManager()
    
    var landlord : User? {
        didSet {
            landlord!.handCard.cards.append(contentsOf: landlordCachedCards!)
            user!.deskView!.toolType = .hidden
            user!.deskView!.cardContainerView.isUserInteractionEnabled = true
            beganGame(fromUser: landlord!)
        }
    }
    
    var leftBoot : User?
    var rightBoot : User?
    var user : User?
    
    var landlordCachedCards : [Card]?
    
    var lastPlayedCards : [Card]?
    var currentSelectUser : User?
    
    var landlordSelectionType : LandlordSelectionType = .none
    
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
        print("\(user)选择了\(selectType)")
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
        
        print("now began game from\(fromUser)")
        
        nextPlay(user: fromUser)
    }
    
    func nextPlay(user:User) {
        currentSelectUser = user
        if user == self.user {
            if lastPlayedCards == user.lastPlayedCards {
                lastPlayedCards = nil
            }
//            let playCards = user.playCards()
//            if playCards.count > 0 {
//                lastPlayedCards = playCards
//                for card in playCards {
//                    user.handCard.cards.remove(card)
//                }
//                user.lastPlayedCards = playCards
//                user.updateCards()
//                print("\(user)打出了")
//                printArr(cards: playCards)
//                print("剩余")
//                printArr(cards: user.handCard.cards)
//                if user.handCard.cards.count == 0 {
//                    print("\(user)win!")
//                    print("winner winner, chicken dinner")
//                    return
//                }
//            }
//            nextPlay(user: user.next())
        }
        else {
            if lastPlayedCards == user.lastPlayedCards {
                lastPlayedCards = nil
            }
            let playCards = user.playCards()
            if playCards.count > 0 {
                lastPlayedCards = playCards
                for card in playCards {
                    user.handCard.cards.remove(card)
                }
                user.lastPlayedCards = playCards
                user.updateCards()
                print("\(user)打出了")
                printArr(cards: playCards)
                print("剩余")
                printArr(cards: user.handCard.cards)
                if user.handCard.cards.count == 0 {
                    print("\(user)win!")
                    print("winner winner, chicken dinner")
                    return
                }
            }
            nextPlay(user: user.next())
        }
    }
    
    func printArr(cards:[Card]) {
        var values : [Int] = []
        for card in cards {
            values.append(card.value)
        }
        print(values)
    }
}

extension CardManager : UserDeskViewDelegate {
    
    func changeSelect() {
        let user = CardManager.shared.user!
        if validatedCanShow(cards: user.handCard.selectedCards) {
            user.deskView!.toolType = .playingEnable
        }
        else {
            user.deskView!.toolType = .playingDisable
        }
    }
    
    func didClick(toolView: ToolView, btnType: BtnType) {
        let user = CardManager.shared.user!
        if toolView == user.deskView!.choicingToolV {
            user.selectCardType = btnType
            CardManager.shared.currentSelectUser = user
            user.deskView!.toolType = .hidden
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
                user.deskView!.toolType = .hidden
                nextPlay(user: user.next())
                break
            case .play:
                if validatedCanShow(cards: user.handCard.selectedCards) {
                    user.deskView!.toolType = .hidden
                    lastPlayedCards = user.handCard.selectedCards
                    nextPlay(user: user.next())
                }
                break
            default:
                break
            }
        }
    }
    
    func validatedCanShow(cards:[Card]) -> Bool {
        let type = user!.getCardsType(cards: cards)
        if type == .unsolvable {
            return false
        }
        return true
    }
}

extension Array where Element: Equatable {
    mutating func remove(_ object: Element) {
        if let index = firstIndex(of: object) {
            remove(at: index)
        }
    }
}
