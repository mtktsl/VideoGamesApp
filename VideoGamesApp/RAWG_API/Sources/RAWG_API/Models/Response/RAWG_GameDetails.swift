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
