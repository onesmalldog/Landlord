//
//  DeskView.swift
//  DouDiZhu
//
//  Created by lizhengang on 2020/12/21.
//

import UIKit

class UserDeskView: UIView {
    
    enum UserToolType {
        case hidden
        case choicing
        case playing
    }
    
    let collectionView : UICollectionView
    let toolV : UIView
    var dataSource : [Card] {
        willSet {
            
        }
        didSet {
            collectionView.contentSize = CGSize(width: CGFloat(dataSource.count*20)+w, height: 0)
        }
    }
    
    let choicingToolV : ChoicingToolView
    let playingToolV : PlayingToolView
    
    var w = CGFloat(105), h = CGFloat(150)
    
    var toolType : UserToolType {
        willSet {
            if newValue != toolType {
                switch newValue {
                case .choicing:
                    choicingToolV.isHidden = false
                    playingToolV.isHidden = true
                    break
                case .playing:
                    choicingToolV.isHidden = true
                    playingToolV.isHidden = false
                default:
                    choicingToolV.isHidden = true
                    playingToolV.isHidden = true
                    break
                }
            }
        }
        didSet {
            
        }
    }
    
    override init(frame: CGRect) {
        self.toolV = UIView(frame: frame)
        let layout = UserDeskLayout()
        layout.scrollDirection = .horizontal
        
        self.w *= 0.7
        self.h *= 0.7
        
        layout.itemSize = CGSize(width: w, height: h)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.dataSource = []
        self.choicingToolV = ChoicingToolView(frame: frame)
        self.playingToolV = PlayingToolView(frame: frame)
        self.toolType = .hidden
        
        super.init(frame: frame)
        
        toolV.backgroundColor = .clear
        
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UserCardCell.classForCoder(), forCellWithReuseIdentifier: "user_card_cellid")
        addSubview(collectionView)
        let y = UIScreen.main.bounds.size.height - h
        let width = UIScreen.main.bounds.size.width - 60*2
        collectionView.frame = CGRect(x: 60, y: y, width: width, height: h)
//        collectionView.snp.makeConstraints { (make) in
//            make.bottom.equalToSuperview().offset(-20)
//            make.leading.equalToSuperview().offset(60)
//            make.trailing.equalToSuperview().offset(-60)
//            make.height.equalTo(h)
//        }
        
        addSubview(toolV)
        toolV.snp.makeConstraints { (make) in
            make.bottom.equalTo(collectionView.snp_topMargin).offset(-40)
            make.leading.trailing.equalTo(collectionView)
            make.height.equalTo(60)
            make.top.equalToSuperview()
        }
        
        toolV.addSubview(choicingToolV)
        choicingToolV.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
        toolV.addSubview(playingToolV)
        playingToolV.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UserDeskView : UICollectionViewDelegate {
    
}
extension UserDeskView : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "user_card_cellid", for: indexPath) as! UserCardCell
        cell.card = dataSource[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        collectionView.bringSubviewToFront(cell)
    }
}

class UserDeskLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
    }
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let origin = super.layoutAttributesForElements(in: rect)
        guard let original = origin else {
            return origin
        }
        for currentAttr in original {
            let oframe = currentAttr.frame
            currentAttr.frame = CGRect(x: CGFloat(20*currentAttr.indexPath.item), y: oframe.origin.y, width: oframe.size.width, height: oframe.size.height)
        }
        return original
    }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

class UserCardCell: UICollectionViewCell {
    var cardView: CardView?
    var card: Card? {
        willSet {
            
        }
        didSet {
            if cardView != nil {
                cardView!.removeFromSuperview()
            }
            cardView = CardView(card: card!)
            addSubview(cardView!)
            cardView?.snp.makeConstraints({ (make) in
                make.leading.trailing.top.bottom.equalToSuperview()
            })
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


