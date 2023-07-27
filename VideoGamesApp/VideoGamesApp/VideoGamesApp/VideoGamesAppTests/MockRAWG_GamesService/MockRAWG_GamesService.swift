//
//  MockRAWG_GamesService.swift
//  VideoGamesAppTests
//
//  Created by Metin Tarık Kiki on 26.07.2023.
//

import Foundation
import RAWG_API

final class MockRAWG_GamesService: RAWG_GamesServiceProtocol {
    
}

extension MockRAWG_GamesService {
    func getGamesList(_ parameters: RAWG_API.RAWG_GamesListParameters, completion: @escaping ((Result<RAWG_API.RAWG_GamesListResponse, RAWG_API.RAWG_NetworkError>) -> Void)) -> URLSessionDataTask? {
        let data = Bundle().decode(type: RAWG_GamesListResponse.self, file: "MockGamesList.json")
        
        //TODO: make data optional in bundle
        
        return nil
    }
    
    func getGameDetails(_ gameID: Int, apiKey: String, completion: @escaping ((Result<RAWG_API.RAWG_GameDetails, RAWG_API.RAWG_NetworkError>) -> Void)) -> URLSessionDataTask? {
        return nil
    }
    
    func downloadImage(_ imageURLString: String, isCropped: Bool, completion: @escaping ((Result<Data, RAWG_API.RAWG_NetworkError>) -> Void)) -> URLSessionDataTask? {
        return nil
    }
}
