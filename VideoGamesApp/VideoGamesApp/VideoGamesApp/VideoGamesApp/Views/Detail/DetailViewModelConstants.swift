//
//  DetailViewModelConstants.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 24.07.2023.
//

import Foundation

extension DetailViewModel {
    
    enum AlertParameters {
        static let networkErrorTitle = "Network Error"
        static let favoriteWarningTitle = "Warning"
        
        static let favoriteWarningMessage = "You are about to remove the game from favorites."
        
        static let responseCodeMessage = "Cannot connect to the server."
        static let noResponseMessage = "Cannot connect to the server."
        static let emptyResponseMessage = "No response from the server."
        static let cancelledResponseMessage = "Web query cancelled."
        static let decodeErrorMessage = "Unknown error. Report the issue to the devs."
        static let typeMissMatchMessage = "Unknown error. Report the issue to the devs."
        
        static let urlError = "No entry found for the game."
        
        static let errorOkOption = "OK"
        static let favoriteOkOption = "Confirm"
        static let favoriteCancelOption = "Cancel"
    }
    
    enum IndicatorTexts {
        static let developer = "Developer(s)"
        static let publisher = "Publisher(s)"
        static let releaseDate = "Released"
        static let reviews = "REVIEWS"
        static let rawgRatingTitle = "RAWG:"
        static let metacriticTitle = "Metacritic:"
    }
    
    enum NilTextIndicators {
        static let unknown = "(-unknown-)"
    }
    
    enum RatingThresholds {
        static let medium: Double = 2.5
        static let high: Double = 3.75
        static let max: Double = 5.0
    }
    
    enum MetacriticThresholds {
        static let medium: Int = 50
        static let high: Int = 75
        static let max: Int = 100
    }
}
