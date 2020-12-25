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
        
        CardManager.shared.dealCards()
        
        let user = CardManager.shared.user!
        let userDeskV = UserDeskView(frame: .zero)
        userDeskV.handCards = user.handCard
        userDeskV.delegate = CardManager.shared
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
        CardManager.shared.nextChoice(user: first!)
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
