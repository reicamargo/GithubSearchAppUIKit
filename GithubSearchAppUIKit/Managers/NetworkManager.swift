//
//  NetworkManager.swift
//  GithubSearchAppUIKit
//
//  Created by Reinaldo Camargo on 26/04/24.
//

import SwiftUI

class NetworkManager {
    static let shared = NetworkManager()
    let baseURL = "https://api.github.com/users/"
    
    private init() {}
    
    func getFollowers(for username: String, page: Int) async throws -> [Follower] {
        let endpoint =  "\(baseURL)\(username)/followers?per_page100&page=\(page)"
        
        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        do {
            let json = JSONDecoder()
            json.keyDecodingStrategy = .convertFromSnakeCase
            return try json.decode([Follower].self, from: data)
        } catch {
            throw NetworkError.invalidData
        }
    }
}

enum NetworkError: Error {
    case invalidURL
    case invalidData
    case invalidResponse
}
