//
//  FollowerListViewController.swift
//  GithubSearchAppUIKit
//
//  Created by Reinaldo Camargo on 25/04/24.
//

import UIKit

class FollowerListViewController: UIViewController {
    
    enum Section {
        case main
    }
    
    private var username: String!
    var followers: [Follower] = []
    var filteredFollowers: [Follower] = []
    var page = 1
    var hasMoreFollowers = true
    var isSearching = false
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Follower>!
    
    init(username: String) {
        super.init(nibName: nil, bundle: nil)
        self.username = username
        title = username
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        configureCollectionView()
        configureSearchController()
        configureDataSource()
        
        Task {
            await loadFollowers(username: username, page: page)
        }
        
    }
    
    private func loadFollowers(username: String, page: Int) async -> Void {
        showLoadingView()
        
        do {
            let followers = try await NetworkManager.shared.getFollowers(for: username, page: page)
            updateUI(with: followers)
        } catch {
            var alertItem: AlertItem
            if let networkError = error as? NetworkError {
                switch networkError {
                case .invalidURL:
                    alertItem = AlertItemContext.invalidURL
                case .invalidData:
                    alertItem = AlertItemContext.invalidData
                case .invalidResponse:
                    alertItem = AlertItemContext.invalidResponse
                }
            } else { alertItem = AlertItemContext.defaultError }
            
            presentGFAlert(title: alertItem.title, message: alertItem.message, buttonTitle: "Ok")
        }
        
        dismissLoadingView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func updateUI(with followers: [Follower]) {
        if followers.count < 100 {
            self.hasMoreFollowers = false
        }
        
        self.followers.append(contentsOf: followers)
        
        if self.followers.isEmpty {
            let message = "This user doesn't have any followers. Go follow them ;)"
            showEmptyStateView(with: message, in: self.view)
            return
        }
        
        self.updateData(on: followers)
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UIHelper.createThreeColumnFlowLayout(in: view))
        view.addSubview(collectionView)
        collectionView.delegate = self
        
        collectionView.backgroundColor = .systemBackground
        collectionView.register(FollowerCell.self, forCellWithReuseIdentifier: FollowerCell.reuseID)
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        //navigationController?.navigationBar.prefersLargeTitles = true
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
    }
    
    private func configureSearchController() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search for a username"
        navigationItem.searchController = searchController
        
    }
    
    private func configureDataSource() {
        //Diffable data source is used here because there's a filter feature and will change the datasource. If this wasn't a requirement it could use a normal datasource
        dataSource = UICollectionViewDiffableDataSource<Section, Follower>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, follower) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FollowerCell.reuseID, for: indexPath) as! FollowerCell
            cell.set(follower: follower)
            return cell
        })
    }
    
    private func updateData(on followers: [Follower]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Follower>()
        snapshot.appendSections([.main])
        snapshot.appendItems(followers)
        dataSource.apply(snapshot, animatingDifferences: true)
        
    }
}

extension FollowerListViewController: UICollectionViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > (contentHeight - height)/2 {
            guard hasMoreFollowers else { return }
            
            page += 1
            
            Task {
                await loadFollowers(username: username, page: page)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let activeArray = isSearching ? filteredFollowers : followers
        let follower = activeArray[indexPath.item]
        
        let destinationVC = UserInfoViewController()
        destinationVC.username = follower.login
        destinationVC.delegate = self
        
        let navController = UINavigationController(rootViewController: destinationVC)
        present(navController, animated: true)
    }
    
    @objc private func addButtonTapped() {
        Task {
            var alertItem: AlertItem
            showLoadingView()
            
            do {
                let user = try await NetworkManager.shared.getUserInfo(for: username)
                try await addUserToFavorites(user)
                
                alertItem = AlertItemContext.favoriteUpdated
                self.presentGFAlert(title: alertItem.title, message: alertItem.message, buttonTitle: "Ok")
            } catch {
                if let networkError = error as? NetworkError {
                    switch networkError {
                    case .invalidURL:
                        alertItem = AlertItemContext.invalidURL
                    case .invalidData:
                        alertItem = AlertItemContext.invalidData
                    case .invalidResponse:
                        alertItem = AlertItemContext.invalidResponse
                    }
                } else if let persistenceError = error as? PersistenceError {
                    alertItem = AlertItem(title: "Something is wrong", message: persistenceError.rawValue)
                } else { alertItem = AlertItemContext.defaultError }
                
                self.presentGFAlert(title: alertItem.title, message: alertItem.message, buttonTitle: "Ok")
            }
            dismissLoadingView()
        }
    }
    
    private func addUserToFavorites(_ user: User) async throws {
        let favorite = Follower(login: user.login, avatarUrl: user.avatarUrl)
        try await PersistenceManager.update(with: favorite, actionType: .add)
    }
}

extension FollowerListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
            isSearching = false
            filteredFollowers.removeAll()
            updateData(on: followers)
            return
        }
        isSearching = true
        filteredFollowers = followers.filter({ $0.login.localizedCaseInsensitiveContains(filter) })
        updateData(on: filteredFollowers)
    }
}

extension FollowerListViewController: UserInfoViewControllerDelegate {
    func didRequestFollowers(for username: String) {
        //VC reset
        self.username = username
        title = username
        page = 1
        followers.removeAll()
        filteredFollowers.removeAll()
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        Task {
            await loadFollowers(username: username, page: 1)
        }
    }
}
