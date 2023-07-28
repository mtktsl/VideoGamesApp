//
//  FavoritesViewModelTests.swift
//  VideoGamesAppTests
//
//  Created by Metin Tarık Kiki on 28.07.2023.
//

import Foundation
import XCTest
@testable import VideoGamesApp
import RAWG_API

final class FavoritesViewModelTests: XCTestCase {
    
    var viewModel: FavoritesViewModelProtocol!
    
    var coordinator = MockMainCoordinator()
    var coreDataService = MockCoreDataManager()
    
    static let mockDataFilterName = "testName"
    
    var testFilterName: String?
    
    var mockData: RAWG_GameDetails = .init(
        id: 1,
        name: mockDataFilterName,
        metacritic: 90,
        released: "2023-07-03",
        rating: 3.5
    )
    
    var didNavigate: Bool {
        return coordinator.invokeCountNavigate > 0
    }
    
    override func setUpWithError() throws {
        viewModel = FavoritesViewModel(
            coordinator: coordinator,
            coreDataService: coreDataService
        )
        
        coreDataService.addGameToFavorites(mockData)
        
        testFilterName = FavoritesViewModelTests.mockDataFilterName
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        coreDataService.removeGameFromFavorites(Int32(mockData.id!))
    }
    
    func testFetchFavorites() {
        XCTAssertTrue(viewModel.itemCount == 0)
        viewModel.updateFavoriteGames(for: nil)
        XCTAssertTrue(viewModel.itemCount > 0)
    }
    
    func testFilter() {
        viewModel.updateFavoriteGames(for: nil)
        XCTAssertTrue(viewModel.itemCount > 0)
        viewModel.filter(for: "123")
        XCTAssertTrue(viewModel.itemCount == 0)
        viewModel.filter(for: testFilterName)
        XCTAssertTrue(viewModel.itemCount == 1)
    }
    
    func testFavoriteCell() {
        viewModel.updateFavoriteGames(for: nil)
        
        XCTAssertNil(viewModel.getGame(at: 999))
        XCTAssertNotNil(viewModel.getGame(at: 0))
        
        viewModel.didSelectGame(at: 999)
        XCTAssertFalse(didNavigate)
        viewModel.didSelectGame(at: 0)
        XCTAssertTrue(didNavigate)
    }
}
