//
//  PersistenceManager.swift
//  GithubSearchAppUIKit
//
//  Created by Reinaldo Camargo on 30/04/24.
//

import Foundation

enum PersistenceManager {
    static private let defaults = UserDefaults.standard
    
    enum PersistenceActionType {
        case add, remove
    }
    
    enum Keys {
        static let favorites = "favorites"
    }
    
    static func retrieveFavorites() async throws -> [Follower] {
        guard let favoritesData = defaults.object(forKey: Keys.favorites) as? Data else { return [] }
        
        do {
            let json = JSONDecoder()
            return try json.decode([Follower].self, from: favoritesData)
        } catch {
            throw PersistenceError.invalidFavoriteData
        }
    }
    
    static func save(favorites: [Follower]) async throws {
        do {
            let enconder = JSONEncoder()
            let encodedFavorites = try enconder.encode(favorites)
            defaults.set(encodedFavorites, forKey: Keys.favorites)
            return
        } catch {
            throw PersistenceError.unableToFavorite
        }
    }
    
    static func update(with favorite: Follower, actionType: PersistenceActionType) async throws {
        var favorites = try await retrieveFavorites()
        
        switch actionType {
            case .add:
                guard !favorites.contains(favorite) else { throw PersistenceError.alreadyFavorited }
                
                favorites.append(favorite)
            case .remove:
                guard let index = favorites.firstIndex(of: favorite) else { throw PersistenceError.unableToUnfavorite }
                
                favorites.remove(at: index)
        }
        
        try await save(favorites: favorites)
        
    }
}

enum PersistenceError: String, Error {
    case invalidFavoriteData = "Unable to get favorites."
    case unableToFavorite = "There was an error favoriting this user. Please try again."
    case alreadyFavorited = "This user is already your favorite. You must REALLY like them!"
    case unableToUnfavorite = "There was an error removing this user from your favorites. Please try again."
    
}
