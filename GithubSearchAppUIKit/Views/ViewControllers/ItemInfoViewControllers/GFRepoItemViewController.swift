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
