//
//  ToolView.swift
//  DouDiZhu
//
//  Created by lizhengang on 2020/12/21.
//

import UIKit

class ToolView: UIView {
    enum ToolType {
        case unknow
        case choicing
        case playing
    }
    
    var type : ToolType
    
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
