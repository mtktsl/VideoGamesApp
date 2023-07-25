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
        static let newItem = Notification.Name("CoreDataNewItem")
    }
    
    enum NotificationType {
        case error
        case favoritesChanged(_ isEmpty: Bool)
    }
}

protocol CoreDataManagerProtocol {
    
    var favoriteGames: [RAWG_GamesListModel] { get }
    
    func addGameToFavorites(_ item: RAWG_GameDetails)
    func removeGameFromFavorites(_ id: Int32)
    func fetchLatestUpdates()
    func exists(_ id: Int32) -> Bool
    func isNotSeen(_ id: Int32) -> Bool
    func markFavoriteAsSeen(_ id: Int32)
}

//MARK: - Class definition
class CoreDataManager {
    
    static let shared: CoreDataManagerProtocol = CoreDataManager()
    
    private var context: NSManagedObjectContext? {
        return  (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    }
    
    private var lastFetch = [CORE_FavoriteGameModel]()
    
    private var newItems = Set<Int?>() {
        didSet {
            notifyObservers(.favoritesChanged(newItems.isEmpty))
        }
    }
    
    private init() {}
    
    private func notifyObservers(_ notificationType: NotificationType) {
        
        var notificationName: Notification.Name!
        var object: Bool? = nil
        
        switch notificationType {
        case .error:
            notificationName = NotificationNames.error
        case .favoritesChanged(let isEmpty):
            notificationName = NotificationNames.newItem
            object = isEmpty
        }
        
        NotificationCenter.default.post(
            name: notificationName,
            object: object
        )
    }
    
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
        isNew: Bool,
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
        newItem.isSeen = !isNew
        
        return newItem
    }
}

//MARK: - Protocol Implementation
extension CoreDataManager: CoreDataManagerProtocol {
    
    var favoriteGames: [RAWG_GamesListModel] {
        return lastFetch.map( { coreToGamesList($0) })
    }
    
    func addGameToFavorites(_ item: RAWG_GameDetails) {
        guard let context,
              let _ = gameDetailsToCore(item,
                                        isNew: true,
                                        context: context)
        else {
            notifyObservers(.error)
            return
        }
        
        if saveContext(context) {
            newItems.insert(item.id)
        } else {
            notifyObservers(.error)
        }

        fetchLatestUpdates()
    }
    
    func removeGameFromFavorites(_ id: Int32) {
        guard let context else { return }
        
        let item = lastFetch.first(where: { $0.id == id } )
        
        if let item {
            context.delete(item)
            
            if saveContext(context) {
                newItems.remove(Int(id))
            } else {
                notifyObservers(.error)
            }
            
            fetchLatestUpdates()
        } else {
            notifyObservers(.error)
        }
    }
    
    func fetchLatestUpdates() {
        lastFetch = []
        newItems = []
        guard let context = self.context
        else { return }
        
        if let items = try? context.fetch(CORE_FavoriteGameModel.fetchRequest()) {
           
            lastFetch = items
            
            for item in lastFetch {
                if !item.isSeen {
                    newItems.insert(Int(item.id))
                }
            }
        }
    }
    
    func exists(_ id: Int32) -> Bool {
        return lastFetch.contains(where: { $0.id == id })
    }
    
    func isNotSeen(_ id: Int32) -> Bool {
        return newItems.contains(Int(id))
    }
    
    func markFavoriteAsSeen(_ id: Int32) {
        guard let context else { return }
        if let item = lastFetch.first(where: { $0.id == id }) {
            item.isSeen = true
            if saveContext(context) {
                newItems.remove(Int(id))
            } else {
                notifyObservers(.error)
            }
        }
    }
}
