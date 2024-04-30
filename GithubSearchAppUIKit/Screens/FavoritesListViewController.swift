//
//  FavoritesListViewController.swift
//  GithubSearchAppUIKit
//
//  Created by Reinaldo Camargo on 25/04/24.
//

import UIKit

class FavoritesListViewController: UIViewController {

    private var favorites: [Follower] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        
        Task {
            await loadFavorites()
        }
    }
    
    private func loadFavorites() async {
        showLoadingView()
        
        do {
            self.favorites = try await PersistenceManager.retrieveFavorites()
            print( self.favorites)
        } catch {
            var alertItem: AlertItem
            
            if let persistenceError = error as? PersistenceError {
                alertItem = AlertItem(title: "Something is wrong", message: persistenceError.rawValue)
            } else { alertItem = AlertItemContext.defaultError }
            
            self.presentGFAlertOnMainThread(title: alertItem.title, message: alertItem.message, buttonTitle: "Ok")
        }
        
        dismissLoadingView()
        
    }
}
