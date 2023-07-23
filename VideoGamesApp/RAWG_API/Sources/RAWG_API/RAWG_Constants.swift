//
//  RAWG_Constants.swift
//  
//
//  Created by Metin Tarık Kiki on 14.07.2023.
//

import Foundation

//"https://api.rawg.io/api/games?search=witcher&ordering=-rating&page=1&page_size=20&key=7fc0f758374f446f91e8f401c684a700"

enum RAWG_Constants {
    
    static let defaultPageNumber: Int = 1
    static let defaultPageSize: Int = 20
    static let fullSizeMediaBaseURL = "https://media.rawg.io/media/games/"
    static let croppedSizeMediaBaseURL = "https://media.rawg.io/media/crop/600/400/games/"
    
    static let gamesURLConfiguration = RAWG_URLConfiguration(
        baseURLString: "https://api.rawg.io",
        routeString: "api/games"
    )
}
