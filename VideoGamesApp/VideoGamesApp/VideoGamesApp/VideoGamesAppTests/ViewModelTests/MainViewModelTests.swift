//
//  MainViewModelTests.swift
//  VideoGamesAppTests
//
//  Created by Metin Tarık Kiki on 28.07.2023.
//

import Foundation
@testable import VideoGamesApp
import XCTest
import RAWG_API

final class MainViewModelTests: XCTestCase {
    var viewModel: MainViewModelProtocol!
    
    var coreDataService = MockCoreDataManager()
    
    var mockData: RAWG_GameDetails = .init(
        id: 1,
        name: "testName",
        metacritic: 90,
        released: "2023-07-03",
        rating: 3.5
    )
    
    override func setUpWithError() throws {
        viewModel = MainViewModel(
            coreDataService: coreDataService
        )
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        coreDataService.removeGameFromFavorites(
            Int32(mockData.id!)
        )
    }
    
    func testCoreDataFetch() {
        XCTAssertTrue(coreDataService.lastFetch.isEmpty)
        coreDataService.addGameToFavorites(mockData)
        viewModel.fetchCoreData()
        XCTAssertFalse(coreDataService.lastFetch.isEmpty)
    }
}
