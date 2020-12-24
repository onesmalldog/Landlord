//
//  ViewController.swift
//  DouDiZhu
//
//  Created by lizhengang on 2020/12/21.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CardManager.shared.delegate = self
        CardManager.shared.dealCards()
        
        let user = CardManager.shared.user!
        let userDeskV = UserDeskView(frame: .zero)
        userDeskV.handCards = user.handCard
        userDeskV.delegate = self
        userDeskV.cardContainerView.isUserInteractionEnabled = false
        view.addSubview(userDeskV)
        userDeskV.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-40)
            make.leading.trailing.equalToSuperview()
        }
        userDeskV.toolType = .choicing
        
        user.deskView = userDeskV
        
        let leftBoot = CardManager.shared.leftBoot!
        let leftDeskV = OtherUserDeskView(frame: .zero)
        leftDeskV.handCards = leftBoot.handCard
        view.addSubview(leftDeskV)
        leftDeskV.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(44)
            make.top.equalToSuperview().offset(20)
        }
        
        let rightBoot = CardManager.shared.rightBoot!
        let rightDeskV = OtherUserDeskView(frame: .zero)
        rightDeskV.handCards = rightBoot.handCard
        view.addSubview(rightDeskV)
        rightDeskV.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-44)
            make.top.equalToSuperview().offset(20)
        }
        
        var first : User?
        if CardManager.shared.user!.hasLandlordCard {
            first = CardManager.shared.user!
            CardManager.shared.user!.choiceCtt = 1
            CardManager.shared.rightBoot!.choiceCtt = 2
            CardManager.shared.leftBoot!.choiceCtt = 3
        }
        else if CardManager.shared.leftBoot!.hasLandlordCard {
            first = CardManager.shared.leftBoot!
            CardManager.shared.leftBoot!.choiceCtt = 1
            CardManager.shared.user!.choiceCtt = 2
            CardManager.shared.rightBoot!.choiceCtt = 3
        }
        else {
            first = CardManager.shared.rightBoot!
            CardManager.shared.rightBoot!.choiceCtt = 1
            CardManager.shared.leftBoot!.choiceCtt = 2
            CardManager.shared.user!.choiceCtt = 3
        }
        print(first!)
        print("开始选择")
        CardManager.shared.delegate?.nextChoice(user: first!)
    }
}

extension ViewController : CardManagerDelegate {
    
    func didBeganGame(fromUser: User) {
        fromUser.deskView?.toolType = .hidden
        CardManager.shared.user!.deskView!.cardContainerView.isUserInteractionEnabled = true
        print("now began game from")
        print(fromUser)
    }
    
    func nextChoice(user: User) {
        if user == CardManager.shared.user! {
            user.deskView?.toolType = .choicing
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
                CardManager.shared.currentSelectUser = user
                CardManager.shared.delegate?.nextChoice(user: user.next())
            }
            else {
                CardManager.shared.landlord = CardManager.shared.currentSelectUser!
            }
            break
        case .b1:
            CardManager.shared.currentSelectUser = user
            if user.choiceCtt < 3 {
                CardManager.shared.delegate?.nextChoice(user: user.next())
            }
            else {
                CardManager.shared.landlord = user
            }
            break
        case .b2:
            CardManager.shared.currentSelectUser = user
            if user.choiceCtt < 3 {
                CardManager.shared.delegate?.nextChoice(user: user.next())
            }
            else {
                CardManager.shared.landlord = user
            }
            break
        case .b3:
            CardManager.shared.currentSelectUser = user
            CardManager.shared.landlord = user
            break
        default:
            break
        }
    }
}

extension ViewController : UserDeskViewDelegate {
    func didClick(toolView: ToolView, btnType: BtnType) {
        let user = CardManager.shared.user!
        if toolView == CardManager.shared.user!.deskView!.choicingToolV {
            user.selectCardType = btnType
            CardManager.shared.currentSelectUser = user
            switch btnType {
            case .cancel:
                CardManager.shared.delegate?.nextChoice(user: user.next())
                break
            case .b1:
                CardManager.shared.delegate?.nextChoice(user: user.next())
                break
            case .b2:
                CardManager.shared.delegate?.nextChoice(user: user.next())
                break
            case .b3:
                CardManager.shared.landlord = CardManager.shared.user
                break
            default:
                break
            }
            user.deskView?.toolType = .hidden
        }
        else if toolView == CardManager.shared.user!.deskView!.playingToolV {
            
        }
    }
}

extension ViewController {
    override var shouldAutorotate: Bool {
        get {
            return true
        }
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .landscape
        }
    }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        get {
            return .landscapeRight
        }
    }
}
