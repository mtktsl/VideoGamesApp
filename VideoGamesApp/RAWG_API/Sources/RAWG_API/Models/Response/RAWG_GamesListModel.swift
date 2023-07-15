//
//  RAWG_GamesListModel.swift
//  
//
//  Created by Metin Tarık Kiki on 14.07.2023.
//

import Foundation

public struct RAWG_GamesListModel: Decodable {
    public let name: String?
    public let released: String?
    public let backgroundImageURLString: String?
    public let rating: Double?
    public let ratingTop: Double?
    public let ratingsCount: Int?
    public let metacritic: Int?
    public let id: Int?
    public let reviewsCount: Int?
    public let shortScreenshots: [RAWG_ShortScreenshot]?
    
    enum CodingKeys: String, CodingKey {
        case name
        case released
        case backgroundImageURLString = "background_image"
        case rating
        case ratingTop = "rating_top"
        case ratingsCount = "ratings_count"
        case metacritic
        case id
        case reviewsCount = "reviews_count"
        case shortScreenshots = "short_screenshots"
    }
}
