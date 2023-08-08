//
//  HomeCollectionDataSource.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 8.08.2023.
//

import Foundation
import UIKit

final class HomeCollectionDataSource: NSObject, UICollectionViewDataSource {
    
    weak var viewModel: HomeViewModelProtocol?
    weak var view: HomeViewControllerProtocol?
    
    init(
        view: HomeViewControllerProtocol,
        viewModel: HomeViewModelProtocol
    ) {
        self.viewModel = viewModel
        self.view = view
    }
    
    //MARK: - Number of items
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        let count = viewModel?.dataCount ?? .zero
        if count == .zero {
            view?.showNotFoundView()
        } else {
            view?.hideNotFoundView()
        }
        return count
    }
    
    //MARK: - Dequeue cell
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: GamesListCell.reuseIdentifier,
            for: indexPath
        ) as? GamesListCell
        else { fatalError("Failed to cast GamesListCell") }
        
        cell.viewModel = GamesListCellViewModel(
            dataModel: viewModel?.getGameForCell(at: indexPath.row)
        )
        
        return cell
    }
    
    // MARK: - Dequeue supplementary view
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard let suppView = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ImageViewPagerReusableView.reuseIdentifier,
            for: indexPath
        ) as? ImageViewPagerReusableView
        else {
            fatalError("Failed to cast ImageViewPagerReusableView in HomeViewController")
        }
        
        var imageURLStrings = [String?]()
        var titles = [String?]()
        
        let dataCount = viewModel?.imageViewPagerCount ?? .zero
        
        for i in 0 ..< dataCount {
            let gameData = viewModel?.getGameForHeader(at: i)
            imageURLStrings.append(gameData?.backgroundImageURLString)
            titles.append(gameData?.name)
        }
        
        suppView.viewModel = ImageViewPagerReusableViewModel(
            imageURLStrings: imageURLStrings,
            titles: titles
        )
        
        suppView.contentInset = HomeViewController.Constants.collectionContentInset
        suppView.imageViewPager.delegate = view
        
        return suppView
    }
}
