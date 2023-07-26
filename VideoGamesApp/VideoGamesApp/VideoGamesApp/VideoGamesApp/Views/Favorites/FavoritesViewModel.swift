//
//  FavoritesViewModel.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 15.07.2023.
//

import Foundation
import RAWG_API

extension FavoritesViewModel {
    enum Constants {
        static let viewControllerTitle = "Favorites"
    }
}

protocol FavoritesViewModelDelegate: AnyObject {
    func onListUpdate()
}

protocol FavoritesViewModelProtocol: AnyObject {
    
    var delegate: FavoritesViewModelDelegate? { get set}
    
    var viewControllerTitle: String { get }
    
    var itemCount: Int { get }
    
    func updateFavoriteGames(for searchText: String?)
    func filter(for searchText: String?)
    func getGame(at index: Int) -> RAWG_GamesListModel?
    func didSelectGame(at index: Int)
}

final class FavoritesViewModel {
    
    private weak var coordinator: MainCoordinatorProtocol!
    private let coreDataService: CoreDataManagerProtocol
    
    weak var delegate: FavoritesViewModelDelegate?
    
    private var favoriteGames = [RAWG_GamesListModel]()
    private var filteredGames = [RAWG_GamesListModel]()
    
    init(
        coordinator: MainCoordinatorProtocol,
        coreDataService: CoreDataManagerProtocol
    ) {
        self.coordinator = coordinator
        self.coreDataService = coreDataService
    }
}

extension FavoritesViewModel: FavoritesViewModelProtocol {
    
    var viewControllerTitle: String {
        return Constants.viewControllerTitle
    }
    
    var itemCount: Int {
        filteredGames.count
    }
    
    func filter(for searchText: String?) {
        filteredGames = favoriteGames.filter({
            if let searchText,
               !searchText.isEmpty,
               let name = $0.name {
                return name.lowercased().contains(searchText.lowercased())
            } else {
                return true
            }
        })
        delegate?.onListUpdate()
    }
    
    func updateFavoriteGames(for searchText: String?) {
        CoreDataManager.shared.fetchLatestUpdates()
        favoriteGames = CoreDataManager.shared.favoriteGames
        filter(for: searchText)
        delegate?.onListUpdate()
    }
    
    func getGame(at index: Int) -> RAWG_GamesListModel? {
        
        let gamesCount = itemCount
        if index < 0 || index >= gamesCount {
            return nil
        } else {
            return filteredGames[index]
        }
    }
    
    func didSelectGame(at index: Int) {
        guard let id = getGame(at: index)?.id else { return }
        coordinator.navigate(to: .detail(gameID: id))
    }
}
