//
//  UIView+Ext.swift
//  RuvinskiyDaffyTypeaheadProject
//
//  Created by David Ruvinskiy on 12/17/22.
//

import UIKit

extension UIView {
    
    func pinToEdges(of superview: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.topAnchor),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor)
        ])
    }
    
    func addSubViews(_ views: UIView...) {
        for view in views { addSubview(view) }
    }
}
