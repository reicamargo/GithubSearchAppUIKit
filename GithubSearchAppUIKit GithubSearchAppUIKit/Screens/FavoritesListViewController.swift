//
//  FavoritesListViewController.swift
//  GithubSearchAppUIKit GithubSearchAppUIKit
//
//  Created by Reinaldo Camargo on 25/04/24.
//

import UIKit

class FavoritesListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
}
