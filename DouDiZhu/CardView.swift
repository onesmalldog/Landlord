//
//  CardView.swift
//  DouDiZhu
//
//  Created by lizhengang on 2020/12/21.
//

import UIKit

class CardView : UIView {
    
    public static let ratio : Float = 105.0/150.0
    
    let card : Card
    
    let imageV : UIImageView
    
    var selected : Bool = false
    
    init(card:Card) {
        self.card = card
        var imageName = card.color.rawValue
        var rawValue = card.value
        if card.type == .joker {
            rawValue -= 13
        }
        imageName.append(rawValue.description)
        self.imageV = UIImageView(image: UIImage(named: imageName))
        
        super.init(frame: .zero)
        
        addSubview(imageV)
        imageV.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
