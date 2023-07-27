//
//  MockCoreDataManager.swift
//  VideoGamesAppTests
//
//  Created by Metin Tarık Kiki on 26.07.2023.
//

import Foundation
@testable import VideoGamesApp
import RAWG_API

extension MockCoreDataManager {
    enum MockData {
        static var favoriteGames: [RAWG_GamesListModel] = []
    }
}

final class MockCoreDataManager {
    var newGames = Set<Int>()
    var lastFetch = [RAWG_GamesListModel]()
}

extension MockCoreDataManager: CoreDataManagerProtocol {
    var favoriteGames: [RAWG_GamesListModel] {
        return lastFetch
    }
    
    func addGameToFavorites(_ item: RAWG_GameDetails) {
        MockData.favoriteGames.append(
            .init(
                name: item.name,
                released: item.released,
                backgroundImageURLString: item.backgroundImageURLString,
                rating: item.rating,
                metacritic: item.metacritic
            )
        )
        if let id = item.id {
            newGames.insert(id)
        }
        fetchLatestUpdates()
    }
    
    func removeGameFromFavorites(_ id: Int32) {
        MockData.favoriteGames.removeAll(where: {
            if let favID = $0.id {
                return favID == id
            } else {
                return false
            }
        })
        fetchLatestUpdates()
    }
    
    func fetchLatestUpdates() {
        lastFetch = MockData.favoriteGames
    }
    
    func exists(_ id: Int32) -> Bool {
        return favoriteGames.contains(where: {
            if let favID = $0.id {
                return favID == id
            } else {
                return false
            }
        })
    }
    
    func isNotSeen(_ id: Int32) -> Bool {
        return newGames.contains(Int(id))
    }
    
    func markFavoriteAsSeen(_ id: Int32) {
        newGames.remove(Int(id))
    }
    
    
}
