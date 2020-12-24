//
//  ToolView.swift
//  DouDiZhu
//
//  Created by lizhengang on 2020/12/21.
//

import UIKit

enum BtnType {
    case normal
    case cancel
    case b1
    case b2
    case b3
}

protocol ToolViewDelegate {
    func didClickBtn(toolView:ToolView, type:BtnType)
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
            make.centerX.top.bottom.equalToSuperview()
        }
        
        contentV.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { (make) in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(80)
        }
        
        contentV.addSubview(oneBtn)
        oneBtn.snp.makeConstraints { (make) in
            make.leading.equalTo(cancelBtn).offset(40)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(cancelBtn)
        }
        
        contentV.addSubview(twoBtn)
        twoBtn.snp.makeConstraints { (make) in
            make.leading.equalTo(oneBtn).offset(20)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(cancelBtn)
        }
        
        addSubview(threeBtn)
        threeBtn.snp.makeConstraints { (make) in
            make.leading.equalTo(twoBtn).offset(20)
            make.top.bottom.trailing.equalToSuperview()
            make.width.equalTo(cancelBtn)
        }
        
        cancelBtn.addTarget(self, action: #selector(btnClick(sender:)), for: .touchUpInside)
        oneBtn.addTarget(self, action: #selector(btnClick(sender:)), for: .touchUpInside)
        twoBtn.addTarget(self, action: #selector(btnClick(sender:)), for: .touchUpInside)
        threeBtn.addTarget(self, action: #selector(btnClick(sender:)), for: .touchUpInside)
        
        cancelBtn.btnType = .cancel
        oneBtn.btnType = .b1
        twoBtn.btnType = .b2
        threeBtn.btnType = .b3
    }
    
    @objc func btnClick(sender:UIButton) {
        delegate?.didClickBtn(toolView: self, type: sender.btnType)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PlayingToolView: ToolView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        type = .playing
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIButton {
    var btnType : BtnType {
        set {
            objc_setAssociatedObject(self, "_kTool_btnType_", newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            guard let res = objc_getAssociatedObject(self, "_kTool_btnType_") else {
                return .normal
            }
            return (res as! BtnType)
        }
    }
}
