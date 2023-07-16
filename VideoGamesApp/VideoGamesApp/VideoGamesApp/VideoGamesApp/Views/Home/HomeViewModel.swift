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
        static let imageViewPagerItemCount: Int = 3
    }
}

protocol HomeViewModelDelegate: AnyObject {
    func onSearchResult()
}

protocol HomeViewModelProtocol {
    var viewControllerTitle: String { get }
    var delegate: HomeViewModelDelegate? { get set }
    
    var imageViewPagerCount: Int { get }
    var dataCount: Int { get }
    
    func queryForGamesList(
        _ searchText: String?,
        orderBy: RAWG_GamesListOrderingParameter?
    )
    
    func getGameForCell(at index: Int) -> RAWG_GamesListModel?
    func getGameForHeader(at index: Int) -> RAWG_GamesListModel?
    
    func calculateWideScreenHeight(width: Double) -> Double
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
    
    var imageViewPagerCount: Int {
        let vpCount = Constants.imageViewPagerItemCount
        let dataCount = data?.results?.count ?? 0
        
        return dataCount > vpCount ? vpCount : dataCount
    }
    
    var dataCount: Int {
        let count = data?.results?.count ?? 0
        let result = count - Constants.imageViewPagerItemCount
        return result > 0 ? result : 0
    }
    
    func queryForGamesList(
        _ searchText: String?,
        orderBy: RAWG_GamesListOrderingParameter?
    ) {
        //TODO: make page number user chosen
        let parameters = RAWG_GamesListParameters(
            search: searchText,
            ordering: orderBy,
            page: 1,
            page_size: 20,
            key: ApplicationConstants.RAWG_API_KEY
        )
        
        service.getGamesList(parameters) { [weak self] result in
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
    
    func getGameForCell(at index: Int) -> RAWG_GamesListModel? {
        guard let results = data?.results
        else { return nil}
        
        let finalIndex = index + Constants.imageViewPagerItemCount
        if finalIndex >= results.count || finalIndex < 0 {
            return nil
        } else {
            return results[finalIndex]
        }
    }
    
    func getGameForHeader(at index: Int) -> RAWG_GamesListModel? {
        guard let results = data?.results
        else { return nil}
        
        if index >= results.count || index < 0 {
            return nil
        } else {
            return results[index]
        }
    }
    
    func calculateWideScreenHeight(width: Double) -> Double {
        return width * 9 / 16
    }
}
