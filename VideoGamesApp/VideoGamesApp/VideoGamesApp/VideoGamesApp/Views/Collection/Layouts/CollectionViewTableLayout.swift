//
//  CollectionViewTableLayout.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 15.07.2023.
//

import UIKit

final class CollectionViewTableLayout: UICollectionViewFlowLayout {
    let maxNumColumns: Int
    private(set) var cellHeight: CGFloat
    
    init(maxNumColumns: Int = 1,
         cellHeight: CGFloat = 0,
         sectionInset: UIEdgeInsets = .zero) {
        
        self.maxNumColumns = maxNumColumns
        self.cellHeight = cellHeight
        
        super.init()
        
        self.sectionInset = .zero
        
        /*self.sectionInset =
        sectionInset == .zero
            ? .init(self.minimumInteritemSpacing)
            : sectionInset*/
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        
        if cellHeight == 0 {
            cellHeight = collectionView.bounds.size.height * 0.18
        }
        
        let availableWidth = collectionView.bounds.inset(by: collectionView.layoutMargins).width
        let cellWidth = (availableWidth / CGFloat(maxNumColumns)).rounded(.down)
        - sectionInset.left
        - sectionInset.right
        
        self.itemSize = CGSize(width: cellWidth >= 0
                               ? cellWidth
                               : 1,
                               height: cellHeight)
        
        self.sectionInsetReference = .fromSafeArea
    }
}
