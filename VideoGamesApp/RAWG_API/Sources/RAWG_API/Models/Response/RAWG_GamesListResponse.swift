//
//  RAWG_GamesListResponse.swift
//  
//
//  Created by Metin Tarık Kiki on 14.07.2023.
//

import Foundation

public struct RAWG_GamesListResponse: Decodable {
    public let count: Int?
    public let next: String?
    public let previous: String?

    public let results: [RAWG_GamesListModel]?
}
