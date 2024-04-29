//
//  GFAvatarImageView.swift
//  GithubSearchAppUIKit
//
//  Created by Reinaldo Camargo on 26/04/24.
//

import UIKit

class GFAvatarImageView: UIImageView {

    let placeholderImage = UIImage(resource: .avatarPlaceholder)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        layer.cornerRadius = 10
        clipsToBounds = true
        image = placeholderImage
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func loadImage(from urlString: String) async {
        guard let image = await NetworkManager.shared.downloadImage(from: urlString) else { return }
        
        self.image = image
    }

}
