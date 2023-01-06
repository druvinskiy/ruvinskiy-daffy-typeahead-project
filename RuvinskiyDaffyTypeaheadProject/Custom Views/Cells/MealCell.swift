//
//  MealCell.swift
//  RuvinskiyDaffyTypeaheadProject
//
//  Created by David Ruvinskiy on 12/17/22.
//

import UIKit

class MealCell: UICollectionViewCell {
    static let reuseID = "MealCell"
    
    let mealImageView = DTMealImageView(frame: .zero)
    let nameLabel = DTTitleLabel(textAlignment: .center, fontSize: 16)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    func set(meal: Meal, networkManager: NetworkManager) {
        nameLabel.text = meal.id
        mealImageView.networkManager = networkManager
        mealImageView.downloadImage(fromURL: meal.thumbnailUrl)
    }
    
    private func configure() {
        addSubViews(mealImageView, nameLabel)
        let padding: CGFloat = 8
        
        NSLayoutConstraint.activate([
            mealImageView.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            mealImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            mealImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            mealImageView.heightAnchor.constraint(equalTo: mealImageView.widthAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: mealImageView.bottomAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            nameLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
