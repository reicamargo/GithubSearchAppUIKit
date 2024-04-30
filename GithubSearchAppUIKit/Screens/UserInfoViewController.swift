//
//  UserInfoViewController.swift
//  GithubSearchAppUIKit
//
//  Created by Reinaldo Camargo on 29/04/24.
//

import UIKit

protocol UserInfoViewControllerDelegate {
    func didRequestFollowers(for username: String)
}

class UserInfoViewController: UIViewController {
    
    let headerView = UIView()
    let itemViewOne = UIView()
    let itemViewTwo = UIView()
    let sinceLabel = GFBodyLabel(textAlignment: .center)
    var itemViews: [UIView] = []
    
    var username: String!
    var alertItem: AlertItem?
    var delegate: UserInfoViewControllerDelegate!
    

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
            let user = try await NetworkManager.shared.getUserInfo(for: username)
            configureUIElements(with: user)
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
            } else { alertItem = AlertItemContext.defaultError }

            self.presentGFAlert(title: alertItem!.title, message: alertItem!.message, buttonTitle: "Ok")
        }
        
    }
    
    private func configureUIElements(with user: User) {
        
        let repoItemVC = GFRepoItemViewController(user: user, delegate: self)
        let followerItemVC = GFFollowerItemViewController(user: user, delegate: self)
        
        self.add(childVC: GFUserInfoHeaderViewController(user: user), to: self.headerView)
        self.add(childVC: repoItemVC, to: self.itemViewOne)
        self.add(childVC: followerItemVC, to: self.itemViewTwo)
        sinceLabel.text = "Github user since \(user.createdAt.convertToDisplayFormat())"
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
            headerView.heightAnchor.constraint(equalToConstant: 210),
            
            itemViewOne.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: padding),
            itemViewOne.heightAnchor.constraint(equalToConstant: itemHeight),
            
            itemViewTwo.topAnchor.constraint(equalTo: itemViewOne.bottomAnchor, constant: padding),
            itemViewTwo.heightAnchor.constraint(equalToConstant: itemHeight),
            
            sinceLabel.topAnchor.constraint(equalTo: itemViewTwo.bottomAnchor, constant: padding),
            sinceLabel.heightAnchor.constraint(equalToConstant: 30)
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


extension UserInfoViewController: GFRepoItemViewControllerDelegate {
    func didTapGihubProfile(for user: User) {
        guard let url = URL(string: user.htmlUrl) else {
            alertItem = AlertItemContext.invalidGithubUserURL
            self.presentGFAlert(title: alertItem!.title, message: alertItem!.message, buttonTitle: "Ok")
            return
        }
        
        presentSafariVC(with: url)
        
    }
}

extension UserInfoViewController: GFFollowerItemViewControllerDelegate {
    func didTapGetFollowers(for user: User) {
        guard user.followers != 0 else {
            alertItem = AlertItemContext.noFollowers
            self.presentGFAlert(title: alertItem!.title, message: alertItem!.message, buttonTitle: "So sad...")
            return
        }
        
        delegate.didRequestFollowers(for: user.login)
        dismissVC()
    }
    
    
}
