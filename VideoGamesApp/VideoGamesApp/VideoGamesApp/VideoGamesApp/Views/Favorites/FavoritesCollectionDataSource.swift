//
//  FavoritesCollectionDataSource.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 8.08.2023.
//

import Foundation
import UIKit

final class FavoritesCollectionDataSource: NSObject, UICollectionViewDataSource {
    
    weak var viewModel: FavoritesViewModelProtocol?
    
    init(
        viewModel: FavoritesViewModelProtocol
    ) {
        self.viewModel = viewModel
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        
        if let count = viewModel?.itemCount {
            collectionView.backgroundView?.isHidden = count > 0
            return count
        } else {
            return .zero
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: GamesListCell.reuseIdentifier,
            for: indexPath
        ) as? GamesListCell else {
            fatalError("Failed to cast GamesListCell in FavoritesViewController.")
        }
        
        let data = viewModel?.getGame(at: indexPath.row)
        cell.viewModel = GamesListCellViewModel(
            dataModel: data
        )
        return cell
    }
    
}
