//
//  HomeViewModelTests.swift
//  VideoGamesAppTests
//
//  Created by Metin Tarık Kiki on 26.07.2023.
//

import XCTest
@testable import VideoGamesApp

final class HomeViewModelTests: XCTestCase {
    
    var viewModel: HomeViewModelProtocol!
    var coordinator = MockMainCoordinator()
    
    var isDataExists: Bool {
        viewModel.dataCount > 0
    }
    
    override func setUpWithError() throws {
        viewModel = HomeViewModel(
            coordinator: coordinator,
            service: MockRAWG_GamesService()
        )
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
    }
    
    func testDefaultQuery() {
        XCTAssertFalse(isDataExists)
        viewModel.performDefaultQuery()
        XCTAssertTrue(isDataExists)
    }
    
    func testFilter() {
        viewModel.performDefaultQuery()
        XCTAssertTrue(viewModel.dataCount > 0)
        
        let oldCount = viewModel.dataCount
        viewModel.queryForGamesList(
            "1",
            orderBy: nil,
            pageNumber: 1
        )
        XCTAssertTrue(oldCount == viewModel.dataCount)
        
        viewModel.queryForGamesList(
            "12",
            orderBy: nil,
            pageNumber: 1
        )
        XCTAssertTrue(oldCount == viewModel.dataCount)
        
        viewModel.queryForGamesList(
            "123",
            orderBy: nil,
            pageNumber: 1
        )
        XCTAssertFalse(oldCount == viewModel.dataCount)
    }
    
    func testHeaderVisibility() {
        
        viewModel.performDefaultQuery()
        
        XCTAssertTrue(viewModel.isImageViewPagerVisible)
        
        viewModel.queryForGamesList("", orderBy: nil, pageNumber: 1)
        XCTAssertTrue(viewModel.isImageViewPagerVisible)
        
        viewModel.queryForGamesList("1", orderBy: nil, pageNumber: 1)
        XCTAssertTrue(viewModel.isImageViewPagerVisible)
        
        viewModel.queryForGamesList("12", orderBy: nil, pageNumber: 1)
        XCTAssertTrue(viewModel.isImageViewPagerVisible)
        
        //Starting from 3 letters, viewPager should be invisible
        viewModel.queryForGamesList("123", orderBy: nil, pageNumber: 1)
        XCTAssertFalse(viewModel.isImageViewPagerVisible)
    }
    
    func testDidSelect() {
        viewModel.performDefaultQuery()
        
        let firstCell = viewModel.getGameForCell(at: 0)
        
        XCTAssertEqual(coordinator.invokeCountNavigate, 0)
        viewModel.cellDidSelect(at: 0)
        XCTAssertEqual(coordinator.invokeCountNavigate, 1)
        
        let firstHeader = viewModel.getGameForHeader(at: 0)
        viewModel.pageControllerDidSelect(at: 0)
        XCTAssertEqual(coordinator.invokeCountNavigate, 2)
        
        XCTAssertNotNil(firstCell)
        XCTAssertNotNil(firstHeader)
    }
}
