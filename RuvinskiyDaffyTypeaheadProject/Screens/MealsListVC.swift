//
//  MealsListVC.swift
//  RuvinskiyDaffyTypeaheadProject
//
//  Created by David Ruvinskiy on 12/15/22.
//

import UIKit

class MealsListVC: DTDataLoadingVC {
    
    enum Section { case main }
    
    let networkManager = NetworkManager()
    var meals: [Meal] = []
    var filteredMeals: [Meal] = []
    var isSearching = false
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Meal>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        configureSearchController()
        configureCollectionView()
        getMeals()
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func configureViewController() {
        title = "Meals"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionView.createMealsListVCFlowLayout(in: view))
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(MealCell.self, forCellWithReuseIdentifier: MealCell.reuseID)
    }
    
    func configureSearchController() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search for a meal"
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }
    
    func getMeals() {
        showLoadingView()
        
        networkManager.getMeals { [weak self] (result: Result<[Meal], DTError>) in
            guard let self = self else { return }
            self.dismissLoadingView()
            
            switch result {
            case .success(let meals):
                self.meals = meals.sorted()
                self.updateUI(with: self.meals)
            case .failure(let error):
                self.presentDTAlertOnMainThread(title: "Something Went Wrong", message: error.rawValue, buttonTitle: "Ok")
            }
        }
    }
    
    func updateUI(with meals: [Meal]) {
        let sortedMeals = meals.sorted()
        var snapshot = NSDiffableDataSourceSnapshot<Section, Meal>()
        snapshot.appendSections([.main])
        snapshot.appendItems(sortedMeals)
        DispatchQueue.main.async { self.dataSource.apply(snapshot, animatingDifferences: true) }
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Meal>(collectionView: collectionView) { [weak self] (collectionView, indexPath, meal) -> UICollectionViewCell? in
            guard let self = self else { return UICollectionViewCell() }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MealCell.reuseID, for: indexPath) as! MealCell
            cell.set(meal: meal, networkManager: self.networkManager)
            
            return cell
        }
    }
}

extension MealsListVC: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        dismissEmptyStateView()
        
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
            filteredMeals.removeAll()
            isSearching = false
            updateUI(with: meals)
            return
        }
        
        isSearching = true
        filteredMeals = Meal.filter(meals: meals, filter: filter)
        updateUI(with: filteredMeals)
        
        if filteredMeals.isEmpty {
            showEmptyStateView(with: "No results for query \"\(filter.lowercased())\"", in: self.view)
        }
    }
}

extension MealsListVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let activeArray = isSearching ? filteredMeals : meals
        let meal = activeArray[indexPath.item]
        
        let detailVC = MealDetailVC(meal: meal, networkManager: networkManager)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
