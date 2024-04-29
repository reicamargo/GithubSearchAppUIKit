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
    
    var username: String!
    var followers: [Follower] = []
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Follower>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        configureCollectionView()
        configureDataSource()
        
        Task {
            await loadFollowers()
        }
        
    }
    
    private func loadFollowers() async -> Void {
        do {
            self.followers = try await NetworkManager.shared.getFollowers(for: username, page: 1)
            self.updateData()
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
            
            self.presentGFAlertOnMainThread(title: alertItem.title, message: alertItem.message, buttonTitle: "Ok")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UIHelper.createThreeColumnFlowLayout(in: view))
        view.addSubview(collectionView)
        
        collectionView.backgroundColor = .systemBackground
        collectionView.register(FollowerCell.self, forCellWithReuseIdentifier: FollowerCell.reuseID)
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        //navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func configureDataSource() {
        //Diffable data source is used here because there's a filter feature and will change the datasource. If this wasn't a requirement it could use a normal datasource
        dataSource = UICollectionViewDiffableDataSource<Section, Follower>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, follower) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FollowerCell.reuseID, for: indexPath) as! FollowerCell
            cell.set(follower: follower)
            return cell
        })
    }
    
    private func updateData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Follower>()
        snapshot.appendSections([.main])
        snapshot.appendItems(followers)
        dataSource.apply(snapshot, animatingDifferences: true)
        
    }
}
