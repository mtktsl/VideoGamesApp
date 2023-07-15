//
//  FavoritesViewModel.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 15.07.2023.
//

import Foundation

extension FavoritesViewModel {
    fileprivate enum Constants {
        static let viewControllerTitle = "Favorites"
    }
}

protocol FavoritesViewModelProtocol: AnyObject {
    var viewControllerTitle: String { get }
}

final class FavoritesViewModel {
    private(set) weak var coordinator: MainCoordinatorProtocol!
    
    init(coordinator: MainCoordinatorProtocol!) {
        self.coordinator = coordinator
    }
}

extension FavoritesViewModel: FavoritesViewModelProtocol {
    var viewControllerTitle: String {
        return Constants.viewControllerTitle
    }
}
