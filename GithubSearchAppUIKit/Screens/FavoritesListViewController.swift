//
//  FavoritesListViewController.swift
//  GithubSearchAppUIKit
//
//  Created by Reinaldo Camargo on 25/04/24.
//

import UIKit

class FavoritesListViewController: UIViewController {

    private var favorites: [Follower] = []
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task {
            await loadFavorites()
        }
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "Favorites"
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.rowHeight = 80
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FavoriteCell.self, forCellReuseIdentifier: FavoriteCell.reuseID)
    }
    
    private func loadFavorites() async {
        showLoadingView()
        
        do {
            let favorites = try await PersistenceManager.retrieveFavorites()
            
            if favorites.isEmpty {
                showEmptyStateView(with: "No favorites?\nAdd one on the follower screen", in: self.view)
            } else {
                self.favorites = favorites
                self.tableView.reloadData()
                self.view.bringSubviewToFront(self.tableView)
            }
            
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

extension FavoritesListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteCell.reuseID) as! FavoriteCell
        let favorite = favorites[indexPath.row]
        cell.set(favorite: favorite)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let favorite = favorites[indexPath.row]
        let destVC = FollowerListViewController(username: favorite.login)
        
        navigationController?.pushViewController(destVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let favorite = favorites[indexPath.row]
        
        Task {
            do {
                try await PersistenceManager.update(with: favorite, actionType: .remove)
                
                favorites.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
                
                if favorites.isEmpty {
                    showEmptyStateView(with: "No favorites?\nAdd one on the follower screen", in: self.view)
                }
            } catch {
                var alertItem: AlertItem
                
                if let persistenceError = error as? PersistenceError {
                    alertItem = AlertItem(title: "Something is wrong", message: persistenceError.rawValue)
                } else { alertItem = AlertItemContext.defaultError }
                
                self.presentGFAlertOnMainThread(title: alertItem.title, message: alertItem.message, buttonTitle: "Ok")
            }
        }
        
        
    }
    
}
