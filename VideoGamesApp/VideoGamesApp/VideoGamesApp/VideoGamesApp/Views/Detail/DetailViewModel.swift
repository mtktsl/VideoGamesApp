//
//  DetailViewModel.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 18.07.2023.
//

import Foundation
import RAWG_API

protocol DetailViewModelDelegate: AnyObject {
    
    func onImageDownloadSuccess(_ imageData: Data)
    func onImageDownloadFailure()
    
    func onDataDownloadSuccess()
    
    func onFavoriteChange()
}

final class DetailViewModel {
    
    weak var delegate: DetailViewModelDelegate?
    
    private var imageDataTask: URLSessionDataTask?
    private var gamesDataTask: URLSessionDataTask?
    
    let service: RAWG_GamesServiceProtocol
    let coreDataService: CoreDataManagerProtocol
    private(set) weak var coordinator: MainCoordinatorProtocol?
    
    let gameID: Int
    
    var data: RAWG_GameDetails?
    
    init(
        service: RAWG_GamesServiceProtocol,
        coreDataService: CoreDataManagerProtocol,
        coordinator: MainCoordinatorProtocol,
        gameID: Int
    ) {
        self.service = service
        self.coordinator = coordinator
        self.gameID = gameID
        self.coreDataService = coreDataService
    }
    
    private func generateError(
        _ error: RAWG_NetworkError
    ) {
        var errorTitle = ""
        var errorMessage = ""
        let okOption = "Retry"
        let cancelOption = "Cancel"
        
        switch error {
        case .statusCode(_, _):
            errorTitle = AlertParameters.networkErrorTitle
            errorMessage = AlertParameters.responseCodeMessage
        case .noResponse:
            errorTitle = AlertParameters.networkErrorTitle
            errorMessage = AlertParameters.noResponseMessage
        case .emptyResponse:
            errorTitle = AlertParameters.networkErrorTitle
            errorMessage = AlertParameters.emptyResponseMessage
        case .cancelled:
            errorTitle = AlertParameters.networkErrorTitle
            errorMessage = AlertParameters.cancelledResponseMessage
        case .decodeError:
            errorTitle = AlertParameters.networkErrorTitle
            errorMessage = AlertParameters.decodeErrorMessage
        case .typeMissMatchError:
            errorTitle = AlertParameters.networkErrorTitle
            errorMessage = AlertParameters.typeMissMatchMessage
        case .urlError:
            errorTitle = AlertParameters.networkErrorTitle
            errorMessage = AlertParameters.urlError
        }
        
        coordinator?.popUpAlert(
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
    
    private func generateGameDevelopersText() -> String {
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
    
    private func generateGamePublishersText() -> String {
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
    
    private func markAsSeen() {
        guard let id = data?.id else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            coreDataService.markFavoriteAsSeen(Int32(id))
        }
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
        return coreDataService.exists(Int32(gameID))
    }
    
    func downloadData() {
        gamesDataTask?.cancel()
        gamesDataTask = service.getGameDetails(
            gameID,
            apiKey: ApplicationConstants.RAWG_API_KEY
        ) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let data):
                self.data = data
                markAsSeen()
                delegate?.onDataDownloadSuccess()
            case .failure(let error):
                generateError(error)
            }
        }
    }
    
    func downloadImage() {
        imageDataTask?.cancel()
        
        var finalURLString = ""
        
        if let urlString = data?.backgroundImageURLString {
            finalURLString = urlString
        } else if let urlString = data?.backgroundImageAdditionalURLString {
            finalURLString = urlString
        } else {
            delegate?.onImageDownloadFailure()
            return
        }
        
        imageDataTask = service.downloadImage(
            finalURLString,
            isCropped: false,
            usesCache: true
        ) { [weak self] result in
                guard let self else { return }
                
                switch result {
                case .success(let data):
                    delegate?.onImageDownloadSuccess(data)
                case .failure(_):
                    delegate?.onImageDownloadFailure()
                }
            }
    }
    
    func toggleFavorite() {
        
        if isFavorite {
            coordinator?.popUpAlert(
                title: AlertParameters.favoriteWarningTitle,
                message: AlertParameters.favoriteWarningMessage,
                okOption: AlertParameters.favoriteOkOption,
                cancelOption: AlertParameters.favoriteCancelOption,
                onOk: { [weak self] _ in
                    guard let self else { return }
                    coreDataService.removeGameFromFavorites(Int32(gameID))
                    delegate?.onFavoriteChange()
                },
                onCancel: nil
            )
            
        } else if let data {
            coreDataService.addGameToFavorites(data)
            delegate?.onFavoriteChange()
        }
    }
}
