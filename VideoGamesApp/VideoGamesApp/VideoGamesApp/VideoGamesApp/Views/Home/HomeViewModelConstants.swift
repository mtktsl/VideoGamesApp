//
//  HomeViewModelConstants.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 24.07.2023.
//

import Foundation
import RAWG_API

extension HomeViewModel {
    
    enum Constants {
        static let viewControllerTitle = "RAWG Games"
        
        static let orderingLabelText = "Order:"
        static let orderingDefaultOption = "Suggested"
        static let orderingMoreText = "More"
        static let orderingPickerTitle = "Order By:"
        
        static let orderingReversedText = "Descending"
        
        static let paginationIndicator = "Page:"
        static let imageViewPagerItemCount: Int = 3
        
        static let localSearchThreshold = 3
        
        static let defaultSearchText: String? = nil
        static let defaultOrdering: RAWG_GamesListOrderingParameter? = nil
        static let defaultPage: Int = 1
        static let pageSize: Int = 50
        
        static let visibleFilterCount = 2
    }
    
    enum SearchPreference {
        case defaultLocal
        case defaultOnline
        case localSearch
        case customSearch
    }
    
    enum ErrorParameters {
        static let networkErrorTitle = "Network Error"
        
        static let responseCodeMessage = "Cannot connect to the server."
        static let noResponseMessage = "Cannot connect to the server."
        static let cancelledResponseMessage = "Web query cancelled."
        static let emptyResponseMessage = "No response from the server."
        static let decodeErrorMessage = "Unknown error. Report the issue to the devs."
        static let typeMissMatchMessage = "Unknown error. Report the issue to the devs."
        
        static let urlError = "Invalid search."
        static let okOption = "OK"
    }
}
