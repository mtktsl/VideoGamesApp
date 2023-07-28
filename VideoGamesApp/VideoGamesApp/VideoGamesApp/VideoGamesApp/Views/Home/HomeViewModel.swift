//
//  HomeViewModel.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 15.07.2023.
//

import Foundation
import RAWG_API

protocol HomeViewModelDelegate: AnyObject {
    func onSearchResult()
}

final class HomeViewModel {
    private(set) weak var coordinator: MainCoordinatorProtocol?
    weak var delegate: HomeViewModelDelegate?
    
    private var gamesDataTask: URLSessionDataTask?
    
    let service: RAWG_GamesServiceProtocol!
    var data: RAWG_GamesListResponse?
    var filteredList = [RAWG_GamesListModel]()
    
    var pageNumber = 1
    
    var lastSearchText: String?
    var lastSearchPage: Int?
    var lastSearchOrder: String?
    
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
        case .cancelled:
            title = ErrorParameters.networkErrorTitle
            message = ErrorParameters.cancelledResponseMessage
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
        
        coordinator?.popUpAlert(
            title: title,
            message: message,
            okOption: okOption,
            cancelOption: nil,
            onOk: { [weak self] _ in
                guard let self else { return }
                performGetRequest(.init(
                    search: lastSearchText,
                    ordering: RAWG_GamesListOrderingParameter(rawValue: lastSearchOrder ?? ""),
                    page: lastSearchPage,
                    page_size: Constants.pageSize,
                    key: ApplicationConstants.RAWG_API_KEY)
                )
            },
            onCancel: nil
        )
    }
    
    private func performGetRequest(
        _ parameters: RAWG_GamesListParameters,
        filterText: String? = nil
    ) {
        gamesDataTask?.cancel()
        gamesDataTask = service.getGamesList(parameters) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let data):
                self.data = data
                setFilteredList(filterText)
                delegate?.onSearchResult()
                
            case .failure(let error):
                if error != .cancelled {
                    generateError(error)
                }
            }
        }
    }
    
    private func setFilteredList(_ filterText: String? = nil) {
        filteredList = (data?.results ?? []).filter({
            if let name = $0.name?.lowercased() {
                if let filterText {
                    return name.lowercased().contains(
                        filterText
                            .trimmingCharacters(in: .whitespaces)
                            .lowercased()
                    )
                } else {
                    return true
                }
            } else {
                return false
            }
        })
    }
    
    private func navigateToDetail(_ gameID: Int?) {
        if let gameID {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                coordinator?.navigate(to: .detail(gameID: gameID))
            }
        } else {
            generateError(.noResponse)
        }
    }
}

extension HomeViewModel: HomeViewModelProtocol {
   
    var minimumPageNumber: Int {
        return Constants.defaultPage
    }
    
    var maximumPageNumber: Int {
        let dataCount = data?.count ?? 0
        let pageCount: Int = (dataCount / Constants.pageSize)
        + (dataCount % Constants.pageSize != 0 ? 1 : 0)
        return pageCount
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
    
    var paginationIndicatorText: String {
        return Constants.paginationIndicator
    }
    
    var orderingPickerTitle: String {
        return Constants.orderingPickerTitle
    }
    
    var orderingMoreText: String {
        return Constants.orderingMoreText
    }
    
    var orderingIndicatorText: String {
        return Constants.orderingLabelText
    }
    
    var orderingVisibleSegments: [String] {
        var result = Array(
            RAWG_GamesListOrderingParameter.allCases
                .map({ $0.rawValue.firstUpperCased() })
                .prefix(Constants.visibleFilterCount)
                .dropFirst(1)
        )
        result.insert(Constants.orderingDefaultOption, at: 0)
        return result
    }
    
    var orderingMoreSegments: [String] {
        
        //Remove "-" character from descending value and add appropriate text
        let result = RAWG_GamesListOrderingParameter.allCases
            .map({
                var str = $0.rawValue
                if !str.isEmpty && str[str.startIndex] != "-" {
                    return str.firstUpperCased()
                } else if !str.isEmpty {
                    str.remove(at: str.startIndex)
                    return "\(str.firstUpperCased()) \(Constants.orderingReversedText)"
                } else {
                    return ""
                }
            })
        return Array(
            result[Constants.visibleFilterCount ..< result.count]
        )
    }
    
    func queryForGamesList(
        _ searchText: String?,
        orderBy: String?,
        pageNumber: Int
    ) {
        
        let searchTextCount = searchText?.count ?? 0
        let lastTextCount = lastSearchText?.count ?? 0
        
        let isDefault = searchTextCount < Constants.localSearchThreshold
                        && lastTextCount >= Constants.localSearchThreshold
        
        let isLocal = searchTextCount >= Constants.localSearchThreshold
        
        let filterString = isLocal
        ? searchText
        : nil
        
        var orderingParameter = orderBy ?? ""
        orderingParameter = orderingParameter.lowercased()
        
        if orderingParameter.contains(Constants.orderingReversedText.lowercased()) {
            orderingParameter = orderingParameter.replacingOccurrences(
                of: " \(Constants.orderingReversedText.lowercased())",
                with: ""
            )
            orderingParameter.insert("-", at: orderingParameter.startIndex)
        }
        
        if pageNumber != lastSearchPage
            || orderBy != lastSearchOrder
            || orderingMoreSegments.contains(orderBy ?? "--")
        {
            let searchParameters = RAWG_GamesListParameters(
                search: nil,
                ordering: RAWG_GamesListOrderingParameter(rawValue: orderingParameter),
                page: pageNumber,
                page_size: Constants.pageSize,
                key: ApplicationConstants.RAWG_API_KEY
            )
            
            performGetRequest(
                searchParameters,
                filterText: filterString
            )
            
        } else if isDefault {
            setFilteredList(nil)
            delegate?.onSearchResult()
            searchPreference = .defaultOnline
        } else if isLocal {
            setFilteredList(searchText)
            delegate?.onSearchResult()
            searchPreference = .localSearch
        }
        
        lastSearchText = filterString
        lastSearchPage = pageNumber
        lastSearchOrder = orderBy
    }
    
    func performDefaultQuery() {
        let searchParameters = RAWG_GamesListParameters(
            search: nil,
            ordering: Constants.defaultOrdering,
            page: Constants.defaultPage,
            page_size: Constants.pageSize,
            key: ApplicationConstants.RAWG_API_KEY
        )
        
        lastSearchPage = Constants.defaultPage
        
        performGetRequest(
            searchParameters,
            filterText: nil
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
        
        if index >= filteredList.count || index < 0 {
            return nil
        } else {
            return filteredList[index]
        }
    }
    
    func cellDidSelect(at index: Int) {
        let id = getGameForCell(at: index)?.id
        navigateToDetail(id)
    }
    
    func pageControllerDidSelect(at index: Int) {
        let id = getGameForHeader(at: index)?.id
        navigateToDetail(id)
    }
}
