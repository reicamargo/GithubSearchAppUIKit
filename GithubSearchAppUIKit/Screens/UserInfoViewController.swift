//
//  UserInfoViewController.swift
//  GithubSearchAppUIKit
//
//  Created by Reinaldo Camargo on 29/04/24.
//

import UIKit

class UserInfoViewController: UIViewController {
    
    let headerView = UIView()
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
        view.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.backgroundColor = .systemBackground
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 180)
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
