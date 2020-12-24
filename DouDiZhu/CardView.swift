//
//  CardView.swift
//  DouDiZhu
//
//  Created by lizhengang on 2020/12/21.
//

import UIKit

class CardView : UIView {
    
    public static let ratio : Float = 105.0/150.0
    
    var card : Card? {
        willSet {
            
        }
        didSet {
            guard let card = card else {
                imageV.image = nil
                return
            }
            var imageName = card.color.rawValue
            let rawValue = card.value
            imageName.append(rawValue.description)
            let image = UIImage(named: imageName)
            imageV.image = image
        }
    }
    
    let imageV : UIImageView
    
    let index : Int
    
    var selected : Bool = false {
        willSet {
            layer.removeAllAnimations()
        }
        didSet {
            if oldValue != selected {
                UIView.animate(withDuration: 0.3) {
                    if self.selected {
                        self.transform = .init(translationX: 0, y: -20)
                    }
                    else {
                        self.transform = .identity
                    }
                }
            }
        }
    }
    
    init(index:Int) {
        self.imageV = UIImageView(image: nil)
        self.index = index
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
