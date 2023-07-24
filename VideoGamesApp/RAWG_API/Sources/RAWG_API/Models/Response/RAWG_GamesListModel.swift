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
    
    public init(
        name: String? = nil,
        released: String? = nil,
        backgroundImageURLString: String? = nil,
        rating: Double? = nil,
        ratingTop: Double? = nil,
        ratingsCount: Int? = nil,
        metacritic: Int? = nil,
        id: Int? = nil,
        reviewsCount: Int? = nil,
        shortScreenshots: [RAWG_ShortScreenshot]? = nil
    ) {
        self.name = name
        self.released = released
        self.backgroundImageURLString = backgroundImageURLString
        self.rating = rating
        self.ratingTop = ratingTop
        self.ratingsCount = ratingsCount
        self.metacritic = metacritic
        self.id = id
        self.reviewsCount = reviewsCount
        self.shortScreenshots = shortScreenshots
    }
    
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
