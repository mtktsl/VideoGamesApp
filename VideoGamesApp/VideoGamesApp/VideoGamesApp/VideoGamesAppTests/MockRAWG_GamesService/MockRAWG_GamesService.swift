//
//  MockRAWG_GamesService.swift
//  VideoGamesAppTests
//
//  Created by Metin Tarık Kiki on 26.07.2023.
//

import Foundation
@testable import RAWG_API

final class MockRAWG_GamesService {
    var defaultDateFormat: String = "yyyy-MM-dd"
    var cache = BasicCache<String, Data>(capacity: 20)
    
    let gamesListJSON = "MockGamesList"
    let futureGameDetailJSON = "MockFutureGameDetails"
    let oldGameDetailJSON = "MockGameDetails"
    
    static let availableDetails: [Int] = [963218, 3498]
    static let oldGameID = 3498
    static let futureGameID = 963218
}

extension MockRAWG_GamesService: RAWG_GamesServiceProtocol {
    func getGamesList(_ parameters: RAWG_API.RAWG_GamesListParameters, completion: @escaping ((Result<RAWG_API.RAWG_GamesListResponse, RAWG_API.RAWG_NetworkError>) -> Void)) -> URLSessionDataTask? {
        do {
            let data = try Bundle(for: type(of: self)).jsonDecode(
                decodeType: RAWG_GamesListResponse.self,
                file: gamesListJSON,
                extenstion: ".json"
            )
            completion(.success(data))
        } catch {
            completion(.failure(.decodeError))
        }
        
        return nil
    }
    
    func getGameDetails(_ gameID: Int, apiKey: String, completion: @escaping ((Result<RAWG_API.RAWG_GameDetails, RAWG_API.RAWG_NetworkError>) -> Void)) -> URLSessionDataTask? {
        
        if !MockRAWG_GamesService.availableDetails.contains(gameID) {
            completion(.failure(.noResponse))
            return nil
        }
        
        do {
            let data = try Bundle(for: type(of: self)).jsonDecode(
                decodeType: RAWG_GameDetails.self,
                file: gameID == MockRAWG_GamesService.oldGameID
                ? oldGameDetailJSON
                : futureGameDetailJSON,
                extenstion: ".json"
            )
            completion(.success(data))
        } catch {
            completion(.failure(.decodeError))
        }
        
        return nil
    }
    
    func downloadImage(
        _ imageURLString: String,
        isCropped: Bool,
        usesCache: Bool,
        completion: @escaping ((Result<Data, RAWG_API.RAWG_NetworkError>) -> Void)
    ) -> URLSessionDataTask? {
        
        if let data = cache.get(imageURLString) {
            completion(.success(data))
        } else {
            cache.cache((key: imageURLString, value: Data()))
            completion(.failure(.noResponse))
        }
        
        return nil
    }
    
}
