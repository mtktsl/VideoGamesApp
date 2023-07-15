//
//  File.swift
//  
//
//  Created by Metin Tarık Kiki on 13.07.2023.
//

import Foundation

struct RAWG_URLConfiguration {
    let baseURLString: String
    let routeString: String
    var querySeperator: String = "&"
    
    func generateGamesListURLString(
        _ parameters: RAWG_GamesListParameters
    ) -> String {
        
        //the reason we seperate the expressions is that the compiler is not able to typecheck long expressions in a reasonable time
        var result = baseURLString
        + "/"
        + routeString
        + "?"
        
        result
        += RAWG_GamesListParameters.gamesListParameterNames.search
        + "=" + (parameters.search?.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "")
        + querySeperator
        
        result
        += RAWG_GamesListParameters.gamesListParameterNames.ordering
        + "=" + (parameters.ordering?.rawValue ?? "")
        + querySeperator
        
        result
        += RAWG_GamesListParameters.gamesListParameterNames.page
        + "=" + String(parameters.page ?? RAWG_Constants.defaultPageNumber)
        + querySeperator
        
        result
        += RAWG_GamesListParameters.gamesListParameterNames.page_size
        + "=" + String(parameters.page_size ?? RAWG_Constants.defaultPageSize)
        + querySeperator
        
        result
        += RAWG_GamesListParameters.gamesListParameterNames.key
        + "=" + (parameters.key ?? "")
        + querySeperator
        
        return result
    }
    
    func generateGameDetailURLString(
        _ gameID: Int,
        key: String
    ) -> String {
        
        baseURLString
        + "/"
        + routeString
        + "/"
        + String(gameID)
        + "?"
        + RAWG_GamesListParameters.gamesListParameterNames.key
        + "="
        + key
    }
}
