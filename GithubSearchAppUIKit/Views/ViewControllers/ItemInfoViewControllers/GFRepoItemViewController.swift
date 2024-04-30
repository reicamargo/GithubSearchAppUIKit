//
//  GFRepoItemViewController.swift
//  GithubSearchAppUIKit
//
//  Created by Reinaldo Camargo on 29/04/24.
//

import UIKit

protocol GFRepoItemViewControllerDelegate {
    func didTapGihubProfile(for user: User)
}


class GFRepoItemViewController: GFItemInfoViewController {

    var delegate: GFRepoItemViewControllerDelegate!
    
    init(user: User, delegate: GFRepoItemViewControllerDelegate!) {
        super.init(user: user)
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureItems()

    }
    
    private func configureItems() {
        itemInfoViewOne.set(itemInfoType: .repos, withCount: user.publicRepos)
        itemInfoViewTwo.set(itemInfoType: .gists, withCount: user.publicGists)
        
        actionButton.set(backgroundColor: .systemPurple, title: "Github profile")
        
    }
    
    override func actionButtonTapped() {
        delegate.didTapGihubProfile(for: user)
    }
}
