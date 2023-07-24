//
//  HomeViewModelProtocol.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 24.07.2023.
//

import Foundation
import RAWG_API

protocol HomeViewModelProtocol {
    var viewControllerTitle: String { get }
    var delegate: HomeViewModelDelegate? { get set }
    
    var imageViewPagerCount: Int { get }
    var dataCount: Int { get }
    var isImageViewPagerVisible: Bool { get }
    
    var maximumPageNumber: Int { get }
    var minimumPageNumber: Int { get }
    
    func queryForGamesList(
        _ searchText: String?,
        orderBy: RAWG_GamesListOrderingParameter?,
        pageNumber: Int
    )
    
    func performDefaultQuery()
    
    func getGameForCell(at index: Int) -> RAWG_GamesListModel?
    func getGameForHeader(at index: Int) -> RAWG_GamesListModel?
    func cellDidSelect(at index: Int)
    func pageControllerDidSelect(at index: Int)
}
