//
//  DTDataLoadingVC.swift
//  RuvinskiyDaffyTypeaheadProject
//
//  Created by David Ruvinskiy on 12/17/22.
//

import UIKit

class DTDataLoadingVC: UIViewController {
    
    var containerView = UIView()
    var emptyStateView = DTEmptyStateView()
    
    func showLoadingView() {
        containerView = UIView(frame: view.bounds)
        view.addSubview(containerView)
        
        containerView.backgroundColor = .systemBackground
        containerView.alpha = 0
        
        UIView.animate(withDuration: 0.25) { self.containerView.alpha = 0.8 }
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        containerView.addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        
        activityIndicator.startAnimating()
    }
    
    func dismissLoadingView() {
        DispatchQueue.main.async {
            self.containerView.removeFromSuperview()
        }
    }
    
    func showEmptyStateView(with message: String, in view: UIView) {
        DispatchQueue.main.async {
            self.emptyStateView = DTEmptyStateView(message: message)
            self.emptyStateView.frame = view.bounds
            self.view.addSubview(self.emptyStateView)
        }
    }
    
    func dismissEmptyStateView() {
        emptyStateView.removeFromSuperview()
    }
}
