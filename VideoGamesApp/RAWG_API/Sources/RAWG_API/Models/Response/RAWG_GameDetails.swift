//
//  RAWG_GameDetails.swift
//  
//
//  Created by Metin Tarık Kiki on 14.07.2023.
//

import Foundation

public struct RAWG_GameDetails: Decodable {
    public let name: String?
    public let nameOriginal: String?
    public let description: String?
    public let metacritic: Int?
    public let released: String?
    
    public let backgroundImageURLString: String?
    public let backgroundImageAdditionalURLString: String?
    
    public let website: String?
    
    public let rating: Double?
    public let ratingTop: Double?
    
    public let ratings: [RAWG_Rating]?
    
    public let platforms: [RAWG_GamePlatform]?
    public let esrbRating: RAWG_ESRB_Rating?
    
    enum CodingKeys: String, CodingKey {
        case name
        case nameOriginal = "name_original"
        case description
        case metacritic
        case released
        case backgroundImageURLString = "background_image"
        case backgroundImageAdditionalURLString = "background_image_additional"
        case website
        case rating
        case ratingTop = "rating_top"
        case ratings
        case platforms
        case esrbRating = "esrb_rating"
    }
}
