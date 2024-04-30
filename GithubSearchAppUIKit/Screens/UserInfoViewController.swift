//
//  UserInfoViewController.swift
//  GithubSearchAppUIKit
//
//  Created by Reinaldo Camargo on 29/04/24.
//

import UIKit

class UserInfoViewController: UIViewController {
    
    let headerView = UIView()
    let itemViewOne = UIView()
    let itemViewTwo = UIView()
    let sinceLabel = GFBodyLabel(textAlignment: .center)
    var itemViews: [UIView] = []
    
    var username: String!
    private var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        layoutUI()
        
        Task {
            await self.loadUserInfo()
        }

    }
    
    private func loadUserInfo() async {
        do {
            self.user = try await NetworkManager.shared.getUserInfo(for: username)
            self.add(childVC: GFUserInfoHeaderViewController(user: self.user), to: self.headerView)
            self.add(childVC: GFRepoItemViewController(user: self.user), to: self.itemViewOne)
            self.add(childVC: GFFollowerItemViewController(user: self.user), to: self.itemViewTwo)
            sinceLabel.text = "Github user since \(self.user!.createdAt.convertToDisplayFormat())"
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
    
    private func layoutUI() {
        let padding: CGFloat = 20
        let itemHeight: CGFloat = 140
        
        itemViews = [headerView, itemViewOne, itemViewTwo, sinceLabel]
        
        for itemView in itemViews {
            view.addSubview(itemView)
            itemView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                itemView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
                itemView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            ])
        }
        
        
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 180),
            
            itemViewOne.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: padding),
            itemViewOne.heightAnchor.constraint(equalToConstant: itemHeight),
            
            itemViewTwo.topAnchor.constraint(equalTo: itemViewOne.bottomAnchor, constant: padding),
            itemViewTwo.heightAnchor.constraint(equalToConstant: itemHeight),
            
            sinceLabel.topAnchor.constraint(equalTo: itemViewTwo.bottomAnchor, constant: padding),
            sinceLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    private func add(childVC: UIViewController, to containerView: UIView) {
        addChild(childVC)
        containerView.addSubview(childVC.view)
        childVC.view.frame = containerView.bounds
        childVC.didMove(toParent: self)
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    @objc private func dismissVC() {
        dismiss(animated: true)
    }

}
