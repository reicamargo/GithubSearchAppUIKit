//
//  UIView+Ext.swift
//  GithubSearchAppUIKit
//
//  Created by Reinaldo Camargo on 30/04/24.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        for view in views {
            addSubview(view)
        }
    }
}
