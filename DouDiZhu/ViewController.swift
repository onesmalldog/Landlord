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
        
        let userDeskV = UserDeskView(frame: .zero)
        userDeskV.dataSource = CardManager.shared.originCards
        view.addSubview(userDeskV)
        userDeskV.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-40)
            make.leading.trailing.equalToSuperview()
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

