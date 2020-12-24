//
//  DeskView.swift
//  DouDiZhu
//
//  Created by lizhengang on 2020/12/21.
//

import UIKit

protocol UserDeskViewDelegate {
    func didClick(toolView:ToolView, btnType:BtnType)
}

class DeskView: UIView {
    enum UserToolType {
        case hidden
        case choicing
        case playing
    }
    var handCards : HandCards?
    var toolType : UserToolType = .hidden
    let w = CGFloat(105*0.7), h = CGFloat(150*0.7)
}

class UserDeskView: DeskView {
    
    let margin = 18
    
    var delegate : UserDeskViewDelegate?
    
    let cardContainerView : UIView
    let toolV : UIView
    override var handCards : HandCards? {
        willSet {
            
        }
        didSet {
            guard let handCards = handCards else {
                return
            }
            removeLastCardViewAtIndex(index: handCards.cards.count-1)
            var last : CardView?
            for (i, card) in handCards.cards.enumerated() {
                let cardV = getCardViewFromIndex(index: i)
                cardV.card = card
                if i == handCards.cards.count-2 {
                    last = cardV
                }
                else if i == handCards.cards.count-1 {
                    if last != nil {
                        cardV.snp.remakeConstraints { (make) in
                            make.trailing.equalToSuperview()
                            make.leading.equalTo(last!).offset(margin)
                            make.size.equalTo(CGSize(width: w, height: h))
                            make.top.bottom.equalToSuperview()
                        }
                    }
                    else {
                        cardV.snp.remakeConstraints { (make) in
                            make.leading.trailing.equalToSuperview()
                            make.size.equalTo(CGSize(width: w, height: h))
                            make.top.bottom.equalToSuperview()
                        }
                    }
                }
            }
            
        }
    }
    
    let choicingToolV : ChoicingToolView
    let playingToolV : PlayingToolView
    
    override var toolType : UserToolType {
        willSet {
            if newValue != toolType {
                switch newValue {
                case .choicing:
                    choicingToolV.isHidden = false
                    playingToolV.isHidden = true
                    break
                case .playing:
                    choicingToolV.isHidden = true
                    playingToolV.isHidden = false
                default:
                    choicingToolV.isHidden = true
                    playingToolV.isHidden = true
                    break
                }
            }
        }
        didSet {
            
        }
    }
    
    override init(frame: CGRect) {
        self.toolV = UIView(frame: frame)
        self.cardContainerView = UIView(frame: .zero)
        self.choicingToolV = ChoicingToolView(frame: frame)
        self.playingToolV = PlayingToolView(frame: frame)
        
        super.init(frame: frame)
        
        toolV.backgroundColor = .clear
        
        cardContainerView.backgroundColor = .clear
        addSubview(cardContainerView)
        cardContainerView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-20)
            make.centerX.equalToSuperview()
            make.height.equalTo(h)
        }
        
        addSubview(toolV)
        toolV.snp.makeConstraints { (make) in
            make.bottom.equalTo(cardContainerView.snp_topMargin).offset(-20)
            make.centerX.equalTo(cardContainerView)
            make.height.equalTo(40)
            make.top.equalToSuperview()
        }
        
        toolV.addSubview(choicingToolV)
        choicingToolV.isHidden = true
        choicingToolV.delegate = self
        choicingToolV.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
        toolV.addSubview(playingToolV)
        playingToolV.isHidden = true
        playingToolV.delegate = self
        playingToolV.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
    }
    
    func getCardViewFromIndex(index:Int) -> CardView {
        var last : CardView?
        for cardView in cardContainerView.subviews {
            if cardView.classForCoder == CardView.self {
                let cardV = cardView as! CardView
                if cardV.index == index {
                    return cardV
                }
                else if cardV.index == index-1 {
                    last = cardV
                }
            }
        }
        let cardV = CardView(index: index)
        cardContainerView.addSubview(cardV)
        cardV.snp.makeConstraints { (make) in
            if last != nil {
                make.leading.equalTo(last!).offset(margin)
            }
            else {
                make.leading.equalToSuperview()
            }
            make.size.equalTo(CGSize(width: w, height: h))
            make.top.bottom.equalToSuperview()
        }
        return cardV
    }
    
    func removeLastCardViewAtIndex(index:Int) {
        for cardView in cardContainerView.subviews {
            if cardView.classForCoder == CardView.self {
                let cardV = cardView as! CardView
                if cardV.index == index {
                    cardV.removeFromSuperview()
                    getCardViewFromIndex(index: index)
                }
                else if cardV.index > index {
                    cardV.removeFromSuperview()
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UserDeskView : ToolViewDelegate {
    func didClickBtn(toolView: ToolView, type: BtnType) {
        delegate?.didClick(toolView: toolView, btnType: type)
    }
}

extension UserDeskView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let point = touches.first!.location(in: self)
        if cardContainerView.frame.contains(point) {
            guard let cardV = cardView(point: point) else {
                return
            }
            cardV.selected = !cardV.selected
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let point = touches.first!.location(in: self)
        if cardContainerView.frame.contains(point) {
            guard let cardV = cardView(point: point) else {
                return
            }
            cardV.selected = true
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    func cardView(point:CGPoint) -> CardView? {
        for cardV in cardContainerView.subviews {
            if cardV.classForCoder == CardView.classForCoder() {
                let cardV = cardV as! CardView
                var frame = cardContainerView.convert(cardV.frame, to: self)
                if cardV.index < handCards!.cards.count-1 {
                    frame.size.width = CGFloat(margin)
                }
                if frame.contains(point) {
                    return cardV
                }
            }
        }
        return nil
    }
    func deselectAllCardView() {
        for cardV in cardContainerView.subviews {
            if cardV.classForCoder == CardView.classForCoder() {
                let cardV = cardV as! CardView
                cardV.selected = false
            }
        }
    }
}

class OtherUserDeskView : DeskView {
    
    let cardContainerView : UIView
    
    let margin = 2
    
    override var handCards : HandCards? {
        willSet {
            
        }
        didSet {
            guard let handCards = handCards else {
                return
            }
            removeLastCardViewAtIndex(index: handCards.cards.count-1)
            var last : CardView?
            for (i, card) in handCards.cards.enumerated() {
                let cardV = getCardViewFromIndex(index: i)
                cardV.card = card
                if i == handCards.cards.count-2 {
                    last = cardV
                }
                else if i == handCards.cards.count-1 {
                    if last != nil {
                        cardV.snp.remakeConstraints { (make) in
                            make.trailing.equalToSuperview()
                            make.leading.equalTo(last!).offset(margin)
                            make.size.equalTo(CGSize(width: w, height: h))
                            make.top.bottom.equalToSuperview()
                        }
                    }
                    else {
                        cardV.snp.remakeConstraints { (make) in
                            make.leading.trailing.equalToSuperview()
                            make.size.equalTo(CGSize(width: w, height: h))
                            make.top.bottom.equalToSuperview()
                        }
                    }
                }
            }
            
        }
    }
    
    override init(frame: CGRect) {
        self.cardContainerView = UIView(frame: .zero)
        super.init(frame: frame)
        
        addSubview(cardContainerView)
        cardContainerView.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
    }
    
    func getCardViewFromIndex(index:Int) -> CardView {
        var last : CardView?
        for cardView in cardContainerView.subviews {
            if cardView.classForCoder == CardView.self {
                let cardV = cardView as! CardView
                if cardV.index == index {
                    return cardV
                }
                else if cardV.index == index-1 {
                    last = cardV
                }
            }
        }
        let cardV = CardView(index: index)
        cardV.showBackground = true
        cardContainerView.addSubview(cardV)
        cardV.snp.makeConstraints { (make) in
            if last != nil {
                make.leading.equalTo(last!).offset(margin)
            }
            else {
                make.leading.equalToSuperview()
            }
            make.size.equalTo(CGSize(width: w, height: h))
            make.top.bottom.equalToSuperview()
        }
        return cardV
    }
    
    func removeLastCardViewAtIndex(index:Int) {
        for cardView in cardContainerView.subviews {
            if cardView.classForCoder == CardView.self {
                let cardV = cardView as! CardView
                if cardV.index == index {
                    cardV.removeFromSuperview()
                    getCardViewFromIndex(index: index)
                }
                else if cardV.index > index {
                    cardV.removeFromSuperview()
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
