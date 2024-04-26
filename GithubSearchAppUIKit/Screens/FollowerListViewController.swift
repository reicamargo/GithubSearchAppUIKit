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
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createThreeColumnFlowLayout())
        view.addSubview(collectionView)
        
        collectionView.backgroundColor = .systemBackground
        collectionView.register(FollowerCell.self, forCellWithReuseIdentifier: FollowerCell.reuseID)
    }
    
    private func createThreeColumnFlowLayout() -> UICollectionViewFlowLayout {
        let width = view.bounds.width
        let padding:CGFloat = 12
        let minimumItemSpacing: CGFloat = 10
        //excluding the 2 paddings (leading and trailing) and the 2 min space between cells
        let availableWidth = width - (padding * 2) - (minimumItemSpacing * 2)
        let itemWidth = availableWidth / 3
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        //the height could be hardcoded but it will be always the same in differents devices sizes. To grow as the device screen just added 40 to the width to make a retangle resizable
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth + 40)
        
        return flowLayout
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        //navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func configureDataSource() {
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
