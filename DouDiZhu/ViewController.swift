//
//  ViewController.swift
//  DouDiZhu
//
//  Created by lizhengang on 2020/12/21.
//

import UIKit

class ViewController: UIViewController {

    let choicingToolView = ChoicingToolView(frame: .zero)
    let playingToolView = PlayingToolView(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CardManager.shared.dealCards()
        let user = CardManager.shared.user!
        let userDeskV = UserDeskView(frame: .zero)
        userDeskV.handCards = user.handCard
        view.addSubview(userDeskV)
        userDeskV.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-40)
            make.leading.trailing.equalToSuperview()
        }
        
        choicingToolView.delegate = self
        view.addSubview(choicingToolView)
        choicingToolView.snp.makeConstraints { (make) in
            make.centerX.equalTo(userDeskV)
            make.bottom.equalTo(userDeskV.snp_topMargin).offset(-10)
            make.height.equalTo(60)
        }
        playingToolView.delegate = self
        view.addSubview(playingToolView)
        playingToolView.snp.makeConstraints { (make) in
            make.centerX.equalTo(userDeskV)
            make.bottom.equalTo(userDeskV.snp_topMargin).offset(-10)
            make.height.equalTo(60)
        }
        
        if user.hasLandlordCard {
            
        }
    }

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

extension ViewController : ToolViewDelegate {
    func didClickBtn(toolView: ToolView, type: BtnType) {
        if toolView == choicingToolView {
            
        }
        else if toolView == playingToolView {
            
        }
    }
}
