//
//  HomeViewModel.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 15.07.2023.
//

import Foundation
import RAWG_API

extension HomeViewModel {
    fileprivate enum Constants {
        static let viewControllerTitle = "RAWG Games"
    }
}

protocol HomeViewModelDelegate: AnyObject {
    func onSearchResult()
}

protocol HomeViewModelProtocol {
    var viewControllerTitle: String { get }
    var delegate: HomeViewModelDelegate? { get set }
    
    var dataCount: Int { get }
    
    func queryForGamesList(
        _ searchText: String?,
        orderBy: RAWG_GamesListOrderingParameter?
    )
    
    func getGame(at index: Int) -> RAWG_GamesListModel?
}

final class HomeViewModel {
    private(set) weak var coordinator: MainCoordinatorProtocol!
    weak var delegate: HomeViewModelDelegate?
    
    let service: RAWG_GamesServiceProtocol!
    var data: RAWG_GamesListResponse?
    
    init(
        coordinator: MainCoordinatorProtocol,
        service: RAWG_GamesServiceProtocol
    ) {
        self.coordinator = coordinator
        self.service = service
    }
}

extension HomeViewModel: HomeViewModelProtocol {
    
    
    var viewControllerTitle: String {
        return Constants.viewControllerTitle
    }
    
    var dataCount: Int {
        return data?.results?.count ?? 0
    }
    
    func queryForGamesList(
        _ searchText: String?,
        orderBy: RAWG_GamesListOrderingParameter?
    ) {
        service.getGamesList(
            .init(
                search: searchText,
                ordering: orderBy,
                page: 1,
                page_size: 20,
                key: ApplicationConstants.RAWG_API_KEY)
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                self.data = data
                delegate?.onSearchResult()
            case .failure(_):
                //TODO: POPUP ERROR USING COORDINATOR
                break
            }
        }
    }
    
    func getGame(at index: Int) -> RAWG_GamesListModel? {
        guard let results = data?.results
        else { return nil}
        
        if index >= results.count || index < 0 {
            return nil
        } else {
            return results[index]
        }
    }
}
