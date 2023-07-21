//
//  DetailViewModel.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 18.07.2023.
//

import Foundation
import RAWG_API

extension DetailViewModel {
    fileprivate enum ErrorParameters {
        static let networkErrorTitle = "Network Error"
        
        static let responseCodeMessage = "Cannot connect to the server."
        static let noResponseMessage = "Cannot connect to the server."
        static let emptyResponseMessage = "No response from the server."
        static let decodeErrorMessage = "Unknown error. Report the issue to the devs."
        static let typeMissMatchMessage = "Unknown error. Report the issue to the devs."
        
        static let urlError = "No entry found for the game."
        static let okOption = "OK"
    }
    
    fileprivate enum IndicatorTexts {
        static let developer = "Developers"
        static let publisher = "Publishers"
        static let releaseDate = "Released"
        static let reviews = "REVIEWS"
        static let rawgRatingTitle = "RAWG"
        static let metacriticTitle = "Metacritic"
    }
    
    fileprivate enum NilTextIndicators {
        static let unknown = "(-unknown-)"
    }
    
    fileprivate enum RatingThresholds {
        static let medium: Double = 2.5
        static let high: Double = 3.75
        static let max: Double = 5.0
    }
    
    fileprivate enum MetacriticThresholds {
        static let medium: Int = 50
        static let high: Int = 75
        static let max: Int = 100
    }
}

protocol DetailViewModelDelegate: AnyObject {
    func onImageDownloadSuccess(_ imageData: Data)
    func onImageDownloadFailure()
    
    func onDataDownloadSuccess()
}

protocol DetailViewModelProtocol: AnyObject {
    
    var delegate: DetailViewModelDelegate? { get set }
    
    var isFavorite: Bool { get }
    
    var gameTitle: String? { get }
    
    var gameDeveloperIndicator: String { get }
    var gameDeveloper: String? { get }
    
    var gamePublisherIndicator: String { get }
    var gamePublisher: String? { get }
    
    var gameReleaseDateIndicator: String { get }
    var gameReleaseDate: String? { get }
    
    var reviewsIndicator: String { get }
    
    var rawgRating: Double { get }
    var rawgRatingText: String { get }
    var rawgRatingLevel: GamesListCellRatingModel { get }
    
    var metacriticRating: Int { get }
    var metacriticRatingText: String { get }
    var metacriticRatingLevel: GamesListCellRatingModel { get }
    
    var gameDescription: String? { get }
    
    func downloadData()
    func downloadImage()
}

final class DetailViewModel {
    
    weak var delegate: DetailViewModelDelegate?
    
    let service: RAWG_GamesServiceProtocol
    private(set) weak var coordinator: MainCoordinatorProtocol?
    
    let gameID: Int
    
    var data: RAWG_GameDetails?
    
    init(
        service: RAWG_GamesServiceProtocol,
        coordinator: MainCoordinatorProtocol,
        gameID: Int
    ) {
        self.service = service
        self.coordinator = coordinator
        self.gameID = gameID
    }
    
    func generateError(
        _ error: RAWG_NetworkError
    ) {
        var errorTitle = ""
        var errorMessage = ""
        let okOption = "Retry"
        let cancelOption = "Cancel"
        
        switch error {
        case .statusCode(_, _):
            errorTitle = ErrorParameters.networkErrorTitle
            errorMessage = ErrorParameters.responseCodeMessage
        case .noResponse:
            errorTitle = ErrorParameters.networkErrorTitle
            errorMessage = ErrorParameters.noResponseMessage
        case .emptyResponse:
            errorTitle = ErrorParameters.networkErrorTitle
            errorMessage = ErrorParameters.emptyResponseMessage
        case .decodeError:
            errorTitle = ErrorParameters.networkErrorTitle
            errorMessage = ErrorParameters.decodeErrorMessage
        case .typeMissMatchError:
            errorTitle = ErrorParameters.networkErrorTitle
            errorMessage = ErrorParameters.typeMissMatchMessage
        case .urlError:
            errorTitle = ErrorParameters.networkErrorTitle
            errorMessage = ErrorParameters.urlError
        }
        
        coordinator?.popupError(
            title: errorTitle,
            message: errorMessage,
            okOption: okOption,
            cancelOption: cancelOption,
            onOk: { [weak self] action in
                guard let self else { return }
                downloadData()
            }, onCancel: { [weak self] action in
                guard let self else { return }
                coordinator?.navigate(to: .back)
            }
        )
    }
    
    func generateGameDevelopersText() -> String {
        var result = ""
        if let count = data?.developers?.count, count > 0 {
            for i in 0 ..< count - 1 {
                if let name = data?.developers?[i].name {
                    result += "\(name)\n"
                }
            }
            result += data?.developers?.last?.name ?? ""
        }
        
        return result
    }
    
    func generateGamePublishersText() -> String {
        var result = ""
        if let count = data?.publishers?.count, count > 0 {
            for i in 0 ..< count - 1 {
                if let name = data?.publishers?[i].name {
                    result += "\(name)\n"
                }
            }
            result += data?.publishers?.last?.name ?? ""
        }
        
        return result
    }
}

extension DetailViewModel: DetailViewModelProtocol {
    
    var gameTitle: String? {
        return data?.name
    }
    
    var gameDeveloperIndicator: String {
        return IndicatorTexts.developer
    }
    
    var gameDeveloper: String? {
        let result = generateGameDevelopersText()
        return !result.isEmpty
        ? result
        : NilTextIndicators.unknown
    }
    
    var gamePublisherIndicator: String {
        return IndicatorTexts.publisher
    }
    
    var gamePublisher: String? {
        let result = generateGamePublishersText()
        return !result.isEmpty
        ? result
        : NilTextIndicators.unknown
    }
    
    var gameReleaseDateIndicator: String {
        return IndicatorTexts.releaseDate
    }
    
    var gameReleaseDate: String? {
        return data?.released ?? NilTextIndicators.unknown
    }
    
    var reviewsIndicator: String {
        return IndicatorTexts.reviews
    }
    
    var rawgRating: Double {
        let rating = data?.rating ?? 0.0
        return rating > RatingThresholds.max
        ? RatingThresholds.max
        : rating < 0.0
        ? 0.0
        : rating
    }
    
    var rawgRatingText: String {
        return "\(IndicatorTexts.rawgRatingTitle)"
    }
    
    var rawgRatingLevel: GamesListCellRatingModel {
        let rating = rawgRating
        if rating > 0 {
            if rating < RatingThresholds.medium {
                return .low
            } else if rating < RatingThresholds.high {
                return .medium
            } else {
                return .high
            }
        } else {
            return .none
        }
    }
    
    var metacriticRating: Int {
        let rating = data?.metacritic ?? 0
        return rating > MetacriticThresholds.max
        ? MetacriticThresholds.max
        : rating < 0
        ? 0
        : rating
    }
    
    var metacriticRatingText: String {
        return "\(IndicatorTexts.metacriticTitle)"
    }
    
    var metacriticRatingLevel: GamesListCellRatingModel {
        let rating = metacriticRating
        if rating > 0 {
            if rating < MetacriticThresholds.medium {
                return .low
            } else if rating < MetacriticThresholds.high {
                return .medium
            } else {
                return .high
            }
        } else {
            return .none
        }
    }
    
    var gameDescription: String? {
        return data?.description
    }
    
    var isFavorite: Bool {
        //TODO: check core data
        return false
    }
    
    func downloadData() {
        service.getGameDetails(
            gameID,
            apiKey: ApplicationConstants.RAWG_API_KEY
        ) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let data):
                self.data = data
                delegate?.onDataDownloadSuccess()
            case .failure(let error):
                generateError(error)
            }
        }
    }
    
    func downloadImage() {

        var finalURLString = ""
        
        if let urlString = data?.backgroundImageURLString {
            finalURLString = urlString
        } else if let urlString = data?.backgroundImageAdditionalURLString {
            finalURLString = urlString
        } else {
            delegate?.onImageDownloadFailure()
            return
        }
        
        service.downloadImage(
            finalURLString) { [weak self] result in
                guard let self else { return }
                
                switch result {
                case .success(let data):
                    delegate?.onImageDownloadSuccess(data)
                case .failure(_):
                    delegate?.onImageDownloadFailure()
                }
            }
    }
}
