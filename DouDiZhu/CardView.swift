//
//  CardView.swift
//  DouDiZhu
//
//  Created by lizhengang on 2020/12/21.
//

import UIKit

class CardView : UIView {
    
    public static let ratio : Float = 105.0/150.0
    
    var foregroundImage : UIImage?
    
    var backgroundImage : UIImage {
        get {
            return UIImage(named: "bg")!
        }
    }
    
    var card : Card? {
        didSet {
            guard let card = card else {
                imageV.image = nil
                return
            }
            var imageName = card.color.rawValue
            let rawValue = card.value
            imageName.append(rawValue.description)
            foregroundImage = UIImage(named: imageName)
            if !showBackground {
                imageV.image = foregroundImage
            }
        }
    }
    
    let imageV : UIImageView
    
    let maskV : UIView
    
    let index : Int
    
    var showBackground : Bool = false {
        didSet {
            imageV.image = showBackground ? self.backgroundImage : self.foregroundImage!
        }
    }
    
    var selected : Bool = false {
        willSet {
            layer.removeAllAnimations()
        }
        didSet {
            if let card = card {
                card.select = selected
            }
            if oldValue != selected {
                UIView.animate(withDuration: 0.1) {
                    if self.selected {
                        self.transform = .init(translationX: 0, y: -8)
                        self.maskV.alpha = 0.4
                    }
                    else {
                        self.transform = .identity
                        self.maskV.alpha = 0
                    }
                }
            }
        }
    }
    
    init(index:Int) {
        self.imageV = UIImageView(image: nil)
        self.maskV = UIView(frame: .zero)
        self.index = index
        super.init(frame: .zero)
        
        imageV.tintAdjustmentMode = .normal
        imageV.contentMode = .scaleAspectFit
        addSubview(imageV)
        imageV.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
        maskV.alpha = 0
        maskV.backgroundColor = .darkGray
        addSubview(maskV)
        maskV.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
