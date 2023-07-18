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
        
        static let localSearchThreshold = 3
        
        static let defaultSearchText: String? = nil
        static let defaultOrdering: RAWG_GamesListOrderingParameter? = nil
        static let defaultPage: Int = 1
        static let pageSize: Int = 20
    }
    
    fileprivate enum SearchPreference {
        case defaultLocal
        case defaultOnline
        case localSearch
        case customSearch
    }
    
    fileprivate enum ErrorParameters {
        static let networkErrorTitle = "Network Error"
        
        static let responseCodeMessage = "Response code:"
        static let noResponseMessage = "No response from the server."
        static let emptyResponseMessage = "Server returned empty response"
        static let decodeErrorMessage = "Server response was incorrect. Report the issue to the devs."
        static let typeMissMatchMessage = "Type missmatch error. Report the issue to the devs."
        static let urlError = "Invalid URL request."
        
        static let okOption = "OK"
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
    var isImageViewPagerVisible: Bool { get }
    
    var minimumPageNumber: Int { get }
    
    func queryForGamesList(
        _ searchText: String?,
        orderBy: RAWG_GamesListOrderingParameter?,
        pageNumber: Int
    )
    
    func performDefaultQuery(
        _ filterText: String?,
        pageNumber: Int
    )
    
    func getGameForCell(at index: Int) -> RAWG_GamesListModel?
    func getGameForHeader(at index: Int) -> RAWG_GamesListModel?
}

final class HomeViewModel {
    private(set) weak var coordinator: MainCoordinatorProtocol!
    weak var delegate: HomeViewModelDelegate?
    
    let service: RAWG_GamesServiceProtocol!
    var data: RAWG_GamesListResponse?
    var filteredList = [RAWG_GamesListModel]()
    
    var pageNumber = 1
    
    var lastSearchText: String?
    var lastSearchPage: Int?
    
    fileprivate var searchPreference = SearchPreference.defaultOnline
    
    init(
        coordinator: MainCoordinatorProtocol,
        service: RAWG_GamesServiceProtocol
    ) {
        self.coordinator = coordinator
        self.service = service
    }
    
    private func generateError(_ error: RAWG_NetworkError) {
        
        var title = ""
        var message = ""
        var okOption = ""
        
        switch error {
        case .statusCode(let code, _):
            title = ErrorParameters.networkErrorTitle
            message = "\(ErrorParameters.responseCodeMessage) \(code)"
            okOption = ErrorParameters.okOption
        case .noResponse:
            title = ErrorParameters.networkErrorTitle
            message = ErrorParameters.noResponseMessage
            okOption = ErrorParameters.okOption
        case .emptyResponse:
            title = ErrorParameters.networkErrorTitle
            message = ErrorParameters.emptyResponseMessage
            okOption = ErrorParameters.okOption
        case .decodeError:
            title = ErrorParameters.networkErrorTitle
            message = ErrorParameters.decodeErrorMessage
            okOption = ErrorParameters.okOption
        case .typeMissMatchError:
            title = ErrorParameters.networkErrorTitle
            message = ErrorParameters.typeMissMatchMessage
            okOption = ErrorParameters.okOption
        case .urlError:
            title = ErrorParameters.networkErrorTitle
            message = ErrorParameters.urlError
            okOption = ErrorParameters.okOption
        }
        
        coordinator.popupError(
            title: title,
            message: message,
            okOption: okOption,
            cancelOption: nil,
            onOk: nil,
            onCancel: nil
        )
    }
    
    var requestCount = 0
    
    private func performGetRequest(
        _ parameters: RAWG_GamesListParameters,
        filterText: String? = nil
    ) {
        
        print("ONLINE REQUEST", requestCount)
        requestCount += 1
        
        service.getGamesList(parameters) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let data):
                self.data = data
                setFilteredList(filterText)
                delegate?.onSearchResult()
                
            case .failure(let error):
                generateError(error)
            }
        }
    }
    
    private func setFilteredList(_ filterText: String? = nil) {
        filteredList = (data?.results ?? []).filter({
            if let name = $0.name?.lowercased() {
                if let filterText {
                    return name.contains(filterText.lowercased())
                } else {
                    return true
                }
            } else {
                return false
            }
        })
    }
}

extension HomeViewModel: HomeViewModelProtocol {
   
    var minimumPageNumber: Int {
        return Constants.defaultPage
    }
    
    var viewControllerTitle: String {
        return Constants.viewControllerTitle
    }
    
    var imageViewPagerCount: Int {
        
        let vpCount = Constants.imageViewPagerItemCount
        let dataCount = filteredList.count
        
        switch searchPreference {
        
        case .localSearch:
            return .zero
        case .customSearch:
            return .zero
        default:
            return dataCount > vpCount ? vpCount : dataCount
        }
    }
    
    var dataCount: Int {
        let count = filteredList.count
        let result = count - imageViewPagerCount
        return result > 0 ? result : 0
    }
    
    var isImageViewPagerVisible: Bool {
        (lastSearchText?.count ?? 0) < Constants.localSearchThreshold
    }
    
    func queryForGamesList(
        _ searchText: String?,
        orderBy: RAWG_GamesListOrderingParameter?,
        pageNumber: Int
    ) {
        
        //TODO: make page number user chosen
        
        var searchParameters: RAWG_GamesListParameters?
        
        let lastSearchTextCount = lastSearchText?.count ?? 0
        let searchTextCount = searchText?.count ?? 0
        
        if lastSearchTextCount <= Constants.localSearchThreshold {
            if searchTextCount < Constants.localSearchThreshold {
                searchPreference = .defaultLocal
                if pageNumber != lastSearchPage {
                    performDefaultQuery(
                        pageNumber: pageNumber
                    )
                }
                
            } else if searchTextCount == Constants.localSearchThreshold {
                searchPreference = .localSearch
                if pageNumber != lastSearchPage {
                    performDefaultQuery(
                        searchText,
                        pageNumber: pageNumber
                    )
                }
            } else {
                searchPreference = .customSearch
                searchParameters = .init(
                    search: searchText,
                    ordering: orderBy,
                    page: pageNumber,
                    page_size: Constants.pageSize,
                    key: ApplicationConstants.RAWG_API_KEY
                )
            }
        } else {
            if searchTextCount < 3 {
                searchPreference = .defaultOnline
                searchParameters = .init(
                    search: Constants.defaultSearchText,
                    ordering: Constants.defaultOrdering,
                    page: pageNumber,
                    page_size: Constants.pageSize,
                    key: ApplicationConstants.RAWG_API_KEY
                )
                
            } else if searchTextCount == Constants.localSearchThreshold {
                searchPreference = .localSearch
                performDefaultQuery(
                    searchText,
                    pageNumber: pageNumber
                )
            } else {
                searchPreference = .customSearch
                searchParameters = .init(
                    search: searchText,
                    ordering: orderBy,
                    page: pageNumber,
                    page_size: Constants.pageSize,
                    key: ApplicationConstants.RAWG_API_KEY
                )
            }
        }
        
        switch searchPreference {
        case .defaultLocal:
            setFilteredList()
            delegate?.onSearchResult()
        case .localSearch:
            setFilteredList(searchText)
            delegate?.onSearchResult()
        default:
            //The reason we chose to force this is that if it's online search, parameters has to be set or else we want the app to crash to let the devs know about the issue.
            performGetRequest(searchParameters!)
        }
        
        lastSearchText = searchText
        lastSearchPage = pageNumber
    }
    
    func performDefaultQuery(
        _ filterText: String? = nil,
        pageNumber: Int
    ) {
        let searchParameters = RAWG_GamesListParameters(
            search: nil,
            ordering: Constants.defaultOrdering,
            page: pageNumber,
            page_size: Constants.pageSize,
            key: ApplicationConstants.RAWG_API_KEY
        )
        
        performGetRequest(
            searchParameters,
            filterText: filterText
        )
    }
    
    func getGameForCell(at index: Int) -> RAWG_GamesListModel? {
        let results = filteredList
        
        let finalIndex = index + imageViewPagerCount
        if finalIndex >= results.count || finalIndex < 0 {
            return nil
        } else {
            return results[finalIndex]
        }
    }
    
    func getGameForHeader(at index: Int) -> RAWG_GamesListModel? {
        let results = filteredList
        
        if index >= results.count || index < 0 {
            return nil
        } else {
            return results[index]
        }
    }
}
