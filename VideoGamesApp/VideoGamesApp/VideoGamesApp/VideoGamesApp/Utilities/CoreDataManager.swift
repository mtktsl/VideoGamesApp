//
//  CoreDataManager.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 23.07.2023.
//

import CoreData
import UIKit
import RAWG_API

extension CoreDataManager {
    enum NotificationNames {
        static let error = Notification.Name("CoreDataError")
        static let added = Notification.Name("CoreDataAdded")
        static let removed = Notification.Name("CoreDataRemoved")
    }
}

protocol CoreDataManagerProtocol {
    
    var favoriteGames: [RAWG_GamesListModel] { get }
    
    func addGameToFavorite(_ item: RAWG_GameDetails)
    func removeGameFromFavorites(_ id: Int32)
    func fetchLatestUpdates()
    func exists(_ id: Int32) -> Bool
}

//MARK: - Class definition
class CoreDataManager {
    
    static let shared: CoreDataManagerProtocol = CoreDataManager()
    
    private var context: NSManagedObjectContext? {
        return  (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    }
    
    private var lastFetch = [CORE_FavoriteGameModel]()
    
    private init() {}
    
    private func saveContext(_ context: NSManagedObjectContext) -> Bool {
        do {
            try context.save()
            return true
        } catch {
            return false
        }
    }
    
    private func coreToGamesList(_ model: CORE_FavoriteGameModel) -> RAWG_GamesListModel {
        .init(
            name: model.name,
            released: model.released,
            backgroundImageURLString: model.imageURLString,
            rating: model.rawgRating,
            metacritic: Int(model.metacriticRating),
            id: Int(model.id)
        )
    }
    
    private func gamesListToCore(
        _ model: RAWG_GamesListModel,
        context: NSManagedObjectContext
    ) -> CORE_FavoriteGameModel? {
        
        let newItem = CORE_FavoriteGameModel(context: context)
        
        guard let id = model.id else { return nil }
        
        newItem.id = Int32(id)
        newItem.imageURLString = model.backgroundImageURLString ?? ""
        newItem.name = model.name ?? ""
        newItem.released = model.released ?? ""
        newItem.rawgRating = model.rating ?? 0.0
        newItem.metacriticRating = Int16(model.metacritic ?? 0)
        
        return newItem
    }
    
    private func gameDetailsToCore(
        _ model: RAWG_GameDetails,
        context: NSManagedObjectContext
    ) -> CORE_FavoriteGameModel? {
        let newItem = CORE_FavoriteGameModel(context: context)
        
        guard let id = model.id else { return nil }
        
        newItem.id = Int32(id)
        newItem.imageURLString = model.backgroundImageURLString ?? ""
        newItem.name = model.name ?? ""
        newItem.released = model.released ?? ""
        newItem.rawgRating = model.rating ?? 0.0
        newItem.metacriticRating = Int16(model.metacritic ?? 0)
        
        return newItem
    }
    
    private func notifyError() {
        NotificationCenter.default.post(
            name: NotificationNames.error,
            object: nil
        )
    }
    
    private func notifyAddEvent() {
        NotificationCenter.default.post(
            name: NotificationNames.added,
            object: nil
        )
    }
    
    private func notifyRemoveEvent() {
        NotificationCenter.default.post(
            name: NotificationNames.removed,
            object: nil
        )
    }
}

//MARK: - Protocol Implementation
extension CoreDataManager: CoreDataManagerProtocol {
    
    var favoriteGames: [RAWG_GamesListModel] {
        return lastFetch.map( { coreToGamesList($0) })
    }
    
    func addGameToFavorite(_ item: RAWG_GameDetails) {
        guard let context,
              let _ = gameDetailsToCore(
                item,
                context: context
              )
        else {
            notifyError()
            return
        }
        
        saveContext(context)
        ? notifyAddEvent()
        : notifyError()
        
        fetchLatestUpdates()
    }
    
    func removeGameFromFavorites(_ id: Int32) {
        let item = lastFetch.first(where: { $0.id == id } )
        guard let context else { return }
        if let item {
            
            context.delete(item)
            
            saveContext(context)
            ? notifyRemoveEvent()
            : notifyError()
            
            fetchLatestUpdates()
        } else {
            notifyError()
        }
    }
    
    func fetchLatestUpdates() {
        guard let context = self.context
        else {
            lastFetch = []
            return
        }
        
        if let items = try? context.fetch(CORE_FavoriteGameModel.fetchRequest()) {
            lastFetch = items
        } else {
            lastFetch = []
        }
    }
    
    func exists(_ id: Int32) -> Bool {
        return lastFetch.contains(where: { $0.id == id })
    }
}
