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
    
    func onNotificationStatus(_ isSet: Bool)
    func onNotificationToggle(_ toggleResult: Bool)
}

final class DetailViewModel {
    
    weak var delegate: DetailViewModelDelegate?
    
    private var imageDataTask: URLSessionDataTask?
    private var gamesDataTask: URLSessionDataTask?
    
    private var currentDate = Date()
    
    let service: RAWG_GamesServiceProtocol
    let coreDataService: CoreDataManagerProtocol
    let notificationService: NotificationManagerProtocol
    private(set) weak var coordinator: MainCoordinatorProtocol?
    
    let gameID: Int
    
    var data: RAWG_GameDetails?
    
    var isNotificationSet = false
    
    init(
        service: RAWG_GamesServiceProtocol,
        coreDataService: CoreDataManagerProtocol,
        notificationService: NotificationManagerProtocol,
        coordinator: MainCoordinatorProtocol,
        gameID: Int
    ) {
        self.service = service
        self.notificationService = notificationService
        self.coreDataService = coreDataService
        self.coordinator = coordinator
        self.gameID = gameID
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
    
    private func generateNotificationError(_ error: NotificationError) {
        
        let title = "Error"
        var message = ""
        let okOption = "OK"
        
        switch error {
        case .missingData:
            message = "Not found enough data for the game to schedule a notification."
        case .notAuthorized:
            message = "Your App Is Not Authorized for sending notifications. Please allow notifications for your application to send notifications."
        case .unknownError:
            message = "Unknown error occured when setting notification."
        }
        
        coordinator?.popUpAlert(
            title: title,
            message: message,
            okOption: okOption,
            cancelOption: nil,
            onOk: { [weak self] _ in
                if error == .notAuthorized {
                    self?.coordinator?.navigate(to: .phoneSettings)
                }
            },
            onCancel: nil
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
    
    private func getDate() -> Date? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = service.defaultDateFormat
        
        if let date = data?.released {
            return formatter.date(from: date)
        } else {
            return nil
        }
    }
    
    //MARK: - Notification Logic
    private func handleNotificationResult(_ success: Bool) {
        if !success {
            generateNotificationError(.unknownError)
            delegate?.onNotificationToggle(isNotificationSet)
        } else {
            coordinator?.popUpAlert(
                title: "Scheduled Notification",
                message: "You'll be notified when the game releases.",
                okOption: "OK",
                cancelOption: nil,
                onOk: nil,
                onCancel: nil
            )
            isNotificationSet = true
            delegate?.onNotificationToggle(true)
            requestAuthForCalendar()
        }
    }
    
    private func showCalendarError(_ message: String) {
        coordinator?.popUpAlert(
            title: "Calendar Error",
            message: message,
            okOption: "Go To Settings",
            cancelOption: "Cancel",
            onOk: { [weak self] _ in
                guard let self else { return }
                coordinator?.navigate(to: .phoneSettings)
            },
            onCancel: nil
        )
    }
    
    private func requestAuthForCalendar() {
        notificationService.requestCalendarAuth { [weak self] isAuthorized in
            guard let self else { return }
            if isAuthorized {
                setCalendar()
            } else {
                let errorMessage = "Your app has no access to your calendar to set game release date event. Please check your permission settings."
                showCalendarError(errorMessage)
            }
        }
    }
    
    private func showCalendarSuccess() {
        coordinator?.popUpAlert(
            title: "Calendar Action",
            message: "Added event reminder to your calendar for the date of release of the game.",
            okOption: "OK",
            cancelOption: nil,
            onOk: nil,
            onCancel: nil
        )
    }
    
    private func setCalendar() {
        
        guard let releaseDate = getDate() else { return }
        
        notificationService.addToCalendar(
            for: releaseDate,
            title: data?.name ?? "",
            body: NotificationConstants.releaseDateNotificationBody
        ) { [weak self] success in
            guard let self else { return }
            if success {
                showCalendarSuccess()
            } else {
                showCalendarError("Unknown error occured when adding calendar reminder for the release date.")
            }
        }
    }
    
    private func cancelNotification() {
        coordinator?.popUpAlert(
            title: "WARNING",
            message: "You are about to cancel the relase date notificaiton for the game",
            okOption: "Confirm",
            cancelOption: "Cancel",
            onOk: { [weak self] _ in
                guard let self else { return }
                notificationService.cancelNotification(
                    id: String(gameID)
                )
                isNotificationSet = false
                delegate?.onNotificationToggle(false)
            },
            onCancel: nil
        )
    }
    
    private func scheduleNotification() {
        
        if let releaseDate = getDate(),
           let gameID = data?.id {
            
            notificationService.scheduleNotification(
                for: releaseDate,
                formatString: service.defaultDateFormat,
                id: String(gameID),
                title: data?.name ?? "",
                body: NotificationConstants.releaseDateNotificationBody
            ) { [weak self] success in
                guard let self else { return }
                handleNotificationResult(success)
            }
            
        } else {
            generateNotificationError(.missingData)
            delegate?.onNotificationToggle(isNotificationSet)
        }
        
        
    }
    
    private func handleNotificationAuthorization(_ isAuthorized: Bool) {
        if isAuthorized {
            if !isNotificationSet
            {
                scheduleNotification()
            } else {
                cancelNotification()
            }
        } else {
            generateNotificationError(.notAuthorized)
            delegate?.onNotificationToggle(isNotificationSet)
        }
    }
    
}

//MARK: - Protocol Implementation
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
    
    var isFuture: Bool {
        if let gameDate = getDate() {
            return gameDate > currentDate
        } else {
            return false
        }
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
    
    func checkNotificationSetStatus() {
        guard let gameID = data?.id else {
            delegate?.onNotificationStatus(false)
            return
        }
        notificationService.checkIfScheduled(
            String(gameID)
        ) { [weak self] exists in
            guard let self else { return }
            isNotificationSet = exists
            delegate?.onNotificationStatus(exists)
        }
    }
    
    func requestNotificationAuthorization() {
        notificationService.requestNotificationAuth(NotificationConstants.notificationOptions
        ) { [weak self] isAuthorized in
            guard let self else { return }
            handleNotificationAuthorization(isAuthorized)
        }
    }
}
