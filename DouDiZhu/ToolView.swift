//
//  ToolView.swift
//  DouDiZhu
//
//  Created by lizhengang on 2020/12/21.
//

import UIKit

enum BtnType : Int {
    case normal = -1
    case cancel = 0
    case b1 = 1
    case b2 = 2
    case b3 = 3
    
    case alert = 10
    case play = 11
}

protocol ToolViewDelegate {
    func didClickBtn(toolView:ToolView, type:BtnType)
}

class PlayBtn: UIButton {
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                self.layer.borderColor = UIColor.blue.cgColor
            }
            else {
                self.layer.borderColor = UIColor.darkGray.cgColor
            }
        }
    }
}

class ToolView: UIView {
    enum ToolType {
        case unknow
        case choicing
        case playing
    }
    
    var type : ToolType
    
    var delegate : ToolViewDelegate?
    
    override init(frame: CGRect) {
        self.type = .unknow
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(btn:UIButton) {
        btn.setTitleColor(.black, for: .normal)
        btn.setTitleColor(.darkGray, for: .disabled)
        btn.addTarget(self, action: #selector(btnClick(sender:)), for: .touchUpInside)
        btn.layer.borderWidth = 2
        btn.layer.borderColor = UIColor.blue.cgColor
    }
    @objc func btnClick(sender:UIButton) {
        
    }
}

class ChoicingToolView: ToolView {
    let contentV = UIView()
    let cancelBtn = UIButton(type: .custom)
    let oneBtn = UIButton(type: .custom)
    let twoBtn = UIButton(type: .custom)
    let threeBtn = UIButton(type: .custom)
    override init(frame: CGRect) {
        super.init(frame: frame)
        type = .choicing
        
        addSubview(contentV)
        contentV.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
        contentV.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { (make) in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(80)
        }
        
        contentV.addSubview(oneBtn)
        oneBtn.snp.makeConstraints { (make) in
            make.leading.equalTo(cancelBtn.snp_trailingMargin).offset(40)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(cancelBtn)
        }
        
        contentV.addSubview(twoBtn)
        twoBtn.snp.makeConstraints { (make) in
            make.leading.equalTo(oneBtn.snp_trailingMargin).offset(20)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(cancelBtn)
        }
        
        addSubview(threeBtn)
        threeBtn.snp.makeConstraints { (make) in
            make.leading.equalTo(twoBtn.snp_trailingMargin).offset(20)
            make.top.bottom.trailing.equalToSuperview()
            make.width.equalTo(cancelBtn)
        }
        
        cancelBtn.btnType = .cancel
        oneBtn.btnType = .b1
        twoBtn.btnType = .b2
        threeBtn.btnType = .b3
        
        cancelBtn.setTitle("不叫", for: .normal)
        oneBtn.setTitle("一分", for: .normal)
        twoBtn.setTitle("二分", for: .normal)
        threeBtn.setTitle("三分", for: .normal)
        
        configure(btn: cancelBtn)
        configure(btn: oneBtn)
        configure(btn: twoBtn)
        configure(btn: threeBtn)
    }
    
    @objc override func btnClick(sender:UIButton) {
        var type : BtnType = .normal
        if sender == cancelBtn {
            type = .cancel
        }
        else if sender == oneBtn {
            type = .b1
        }
        else if sender == twoBtn {
            type = .b2
        }
        else if sender == threeBtn {
            type = .b3
        }
        delegate?.didClickBtn(toolView: self, type: type)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PlayingToolView: ToolView {
    
    let contentV = UIView()
    let cancelBtn = UIButton(type: .custom)
    let alertBtn = UIButton(type: .custom)
    let playBtn = PlayBtn(type: .custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        type = .playing
        
        addSubview(contentV)
        contentV.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
        contentV.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { (make) in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(80)
        }
        
        contentV.addSubview(alertBtn)
        alertBtn.snp.makeConstraints { (make) in
            make.leading.equalTo(cancelBtn.snp_trailingMargin).offset(40)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(cancelBtn)
        }
        
        contentV.addSubview(playBtn)
        playBtn.snp.makeConstraints { (make) in
            make.leading.equalTo(alertBtn.snp_trailingMargin).offset(20)
            make.top.bottom.trailing.equalToSuperview()
            make.width.equalTo(cancelBtn)
        }
        
        cancelBtn.btnType = .cancel
        alertBtn.btnType = .alert
        playBtn.btnType = .play
        
        cancelBtn.setTitle("不出", for: .normal)
        alertBtn.setTitle("提示", for: .normal)
        playBtn.setTitle("出牌", for: .normal)
        
        configure(btn: cancelBtn)
        configure(btn: alertBtn)
        configure(btn: playBtn)
    }
    
    @objc override func btnClick(sender:UIButton) {
        var type : BtnType = .normal
        if sender == cancelBtn {
            type = .cancel
        }
        else if sender == alertBtn {
            type = .alert
        }
        else if sender == playBtn {
            type = .play
        }
        delegate?.didClickBtn(toolView: self, type: type)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIButton {
    var btnType : BtnType {
        set {
            objc_setAssociatedObject(self, "_kTool_btnType_", newValue.rawValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            guard let res = objc_getAssociatedObject(self, "_kTool_btnType_") else {
                return .normal
            }
            return BtnType(rawValue: (res as! Int))!
        }
    }
}
