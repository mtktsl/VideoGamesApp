//
//  RAWG_GamesListParameters.swift
//  
//
//  Created by Metin Tarık Kiki on 14.07.2023.
//

import Foundation

public struct RAWG_GamesListParameters {
    
    public let search: String?
    public let ordering: RAWG_GamesListOrderingParameter?
    public let page: Int?
    public let page_size: Int?
    public let key: String?
    
    enum gamesListParameterNames {
        static let search = "search"
        static let ordering = "ordering"
        static let page = "page"
        static let page_size = "page_size"
        static let key = "key"
    }
    
    public init(
        search: String?,
        ordering: RAWG_GamesListOrderingParameter?,
        page: Int?,
        page_size: Int?,
        key: String?
    ) {
        self.search = search
        self.ordering = ordering
        self.page = page
        self.page_size = page_size
        self.key = key
    }
}
