//
//  DetailViewModelTests.swift
//  VideoGamesAppTests
//
//  Created by Metin Tarık Kiki on 28.07.2023.
//

import Foundation
import XCTest
@testable import VideoGamesApp

final class DetailViewModelTests: XCTestCase {
    
    var viewModel: DetailViewModelProtocol!
    
    var coordinator = MockMainCoordinator()
    
    var gamesService = MockRAWG_GamesService()
    
    var coreDataService = MockCoreDataManager()
    
    var notificationService = MockNotificationManager()
    
    let defaultTestGameID = MockRAWG_GamesService.oldGameID
    let futureTestGameID = MockRAWG_GamesService.futureGameID
    
    var testGameID = 3498
    
    override func setUpWithError() throws {

        viewModel = DetailViewModel(
            service: gamesService,
            coreDataService: coreDataService,
            notificationService: notificationService,
            coordinator: coordinator,
            gameID: defaultTestGameID
        )
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
    }
    
    func testDownloadData() {
        XCTAssertNil(viewModel.gameTitle)
        XCTAssertEqual(viewModel.gameDeveloper, DetailViewModel.NilTextIndicators.unknown)
        XCTAssertEqual(viewModel.gamePublisher, DetailViewModel.NilTextIndicators.unknown)
        XCTAssertEqual(viewModel.rawgRating, 0)
        XCTAssertEqual(viewModel.metacriticRating, 0)
        XCTAssertNil(viewModel.gameDescription)
        
        viewModel.downloadData()
        
        XCTAssertNotNil(viewModel.gameTitle)
        XCTAssertNotEqual(viewModel.gameDeveloper, DetailViewModel.NilTextIndicators.unknown)
        XCTAssertNotEqual(viewModel.gamePublisher, DetailViewModel.NilTextIndicators.unknown)
        XCTAssertNotEqual(viewModel.rawgRating, 0)
        XCTAssertNotEqual(viewModel.metacriticRating, 0)
        XCTAssertNotNil(viewModel.gameDescription)
    }

    func testFavorite() {
        
        viewModel.downloadData()
        
        XCTAssertFalse(viewModel.isFavorite)
        
        viewModel.toggleFavorite()
        
        XCTAssertTrue(viewModel.isFavorite)
        XCTAssertTrue(coreDataService.isNotSeen(Int32(defaultTestGameID)))
        
        XCTAssertTrue(coordinator.invokeCountPopUpAlert == 0)
        
        viewModel.toggleFavorite()
        XCTAssertTrue(coordinator.invokeCountPopUpAlert == 1)
        XCTAssertFalse(viewModel.isFavorite)
    }
    
    func testOldGame() {
        viewModel.downloadData()
        XCTAssertFalse(viewModel.isFuture)
    }
    
    func testFutureGame() {
        viewModel = DetailViewModel(
            service: gamesService,
            coreDataService: coreDataService,
            notificationService: notificationService,
            coordinator: coordinator,
            gameID: futureTestGameID
        )
        
        viewModel.downloadData()
        
        XCTAssertTrue(viewModel.isFuture)
        
        //The game is not released yet so there should be no review
        XCTAssertEqual(viewModel.rawgRating, 0)
        XCTAssertEqual(viewModel.metacriticRating, 0)
    }
    
    func testNotification() {
        
        //In order to be able to set a future notification, the game's release date has to be set in the future, not past
        viewModel = DetailViewModel(
            service: gamesService,
            coreDataService: coreDataService,
            notificationService: notificationService,
            coordinator: coordinator,
            gameID: futureTestGameID
        )
        
        viewModel.downloadData()
        
        notificationService.notificationAuth = false
        XCTAssertTrue(coordinator.invokeCountPopUpAlert == 0)
        
        viewModel.requestNotificationAuthorization()
        XCTAssertTrue(coordinator.invokeCountPopUpAlert == 1)
        
        notificationService.checkIfScheduled(String(futureTestGameID), completion: { exists in
            XCTAssertFalse(exists)
        })
        
        notificationService.notificationAuth = true
        viewModel.requestNotificationAuthorization()
        
        XCTAssertTrue(coordinator.invokeCountPopUpAlert > 1)
        
        notificationService.checkIfScheduled(String(futureTestGameID)) { exists in
            XCTAssertTrue(exists)
        }
    }
    
    func testCalendar() {
        viewModel = DetailViewModel(
            service: gamesService,
            coreDataService: coreDataService,
            notificationService: notificationService,
            coordinator: coordinator,
            gameID: futureTestGameID
        )
        
        viewModel.downloadData()
        
        notificationService.notificationAuth = false
        notificationService.calendarAuth = false
        XCTAssertTrue(coordinator.invokeCountPopUpAlert == 0)
        
        viewModel.requestNotificationAuthorization()
        XCTAssertTrue(coordinator.invokeCountPopUpAlert == 1)
        
        XCTAssertTrue(notificationService.calendarScheduleCount == 0)
        
        notificationService.notificationAuth = true
        notificationService.calendarAuth = false
        
        viewModel.requestNotificationAuthorization()
        
        XCTAssertTrue(coordinator.invokeCountPopUpAlert > 1)
        
        XCTAssertTrue(notificationService.calendarScheduleCount == 0)
        
        notificationService.calendarAuth = true
        
        viewModel.requestNotificationAuthorization()
        //it actually toggles the calendar so we need to call it twice here for testing purpose
        viewModel.requestNotificationAuthorization()
        
        XCTAssertTrue(notificationService.calendarScheduleCount > 0)
    }
}
