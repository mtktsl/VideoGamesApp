//
//  HomeViewModelProtocol.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 24.07.2023.
//

import Foundation
import RAWG_API

protocol HomeViewModelProtocol: AnyObject {
    var viewControllerTitle: String { get }
    var delegate: HomeViewModelDelegate? { get set }
    var dataSource: HomeCollectionDataSource? { get set }
    
    var imageViewPagerCount: Int { get }
    var dataCount: Int { get }
    var isImageViewPagerVisible: Bool { get }
    
    var maximumPageNumber: Int { get }
    var minimumPageNumber: Int { get }
    
    var paginationIndicatorText: String { get }
    
    var orderingIndicatorText: String { get }
    var orderingMoreText: String { get }
    var orderingPickerTitle: String { get }
    var orderingVisibleSegments: [String] { get }
    var orderingMoreSegments: [String] { get }
    
    func queryForGamesList(
        _ searchText: String?,
        orderBy: String?,
        pageNumber: Int
    )
    
    func performDefaultQuery()
    
    func getGameForCell(at index: Int) -> RAWG_GamesListModel?
    func getGameForHeader(at index: Int) -> RAWG_GamesListModel?
    func cellDidSelect(at index: Int)
    func pageControllerDidSelect(at index: Int)
}
