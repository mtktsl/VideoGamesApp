//
//  DetailViewModelProtocol.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 24.07.2023.
//

import Foundation
import RAWG_API

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
    func toggleFavorite()
}
