//
//  RAWG_GameDetails.swift
//  
//
//  Created by Metin Tarık Kiki on 14.07.2023.
//

import Foundation

public struct RAWG_GameDetails: Decodable {
    public let id: Int?
    public let name: String?
    public let nameOriginal: String?
    public let metacritic: Int?
    public let released: String?
    
    public let backgroundImageURLString: String?
    public let backgroundImageAdditionalURLString: String?
    
    public let website: String?
    
    public let rating: Double?
    public let ratingTop: Double?
    
    public let ratings: [RAWG_Rating]?
    
    public let platforms: [RAWG_GamePlatform]?
    
    public let developers: [RAWG_GameDeveloper]?
    public let publishers: [RAWG_GamePublisher]?
    
    public let esrbRating: RAWG_ESRB_Rating?
    
    public let description: String?
    
    public init(
        id: Int? = nil,
        name: String? = nil,
        nameOriginal: String? = nil,
        metacritic: Int? = nil,
        released: String? = nil,
        backgroundImageURLString: String? = nil,
        backgroundImageAdditionalURLString: String? = nil,
        website: String? = nil,
        rating: Double? = nil,
        ratingTop: Double? = nil,
        ratings: [RAWG_Rating]? = nil,
        platforms: [RAWG_GamePlatform]? = nil,
        developers: [RAWG_GameDeveloper]? = nil,
        publishers: [RAWG_GamePublisher]? = nil,
        esrbRating: RAWG_ESRB_Rating? = nil,
        description: String? = nil
    ) {
        self.id = id
        self.name = name
        self.nameOriginal = nameOriginal
        self.metacritic = metacritic
        self.released = released
        self.backgroundImageURLString = backgroundImageURLString
        self.backgroundImageAdditionalURLString = backgroundImageAdditionalURLString
        self.website = website
        self.rating = rating
        self.ratingTop = ratingTop
        self.ratings = ratings
        self.platforms = platforms
        self.developers = developers
        self.publishers = publishers
        self.esrbRating = esrbRating
        self.description = description
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case nameOriginal = "name_original"
        case metacritic
        case released
        case backgroundImageURLString = "background_image"
        case backgroundImageAdditionalURLString = "background_image_additional"
        case website
        case rating
        case ratingTop = "rating_top"
        case ratings
        case platforms
        case developers
        case publishers
        case esrbRating = "esrb_rating"
        case description = "description_raw"
    }
}
