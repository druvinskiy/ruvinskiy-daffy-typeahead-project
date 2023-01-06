//
//  MealDetailVC.swift
//  RuvinskiyDaffyTypeaheadProject
//
//  Created by David Ruvinskiy on 12/19/22.
//

import UIKit

class MealDetailVC: UITableViewController {
    
    var meal: Meal
    var details: Details?
    let networkManager: NetworkManager
    
    init(meal: Meal, networkManager: NetworkManager) {
        self.meal = meal
        self.networkManager = networkManager
        
        super.init(nibName: nil, bundle: nil)
        
        title = meal.name
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        configureTableView()
        getDetails(meal: meal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func configureViewController() {
        view.backgroundColor = .systemBackground
    }
    
    func configureTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.removeExcessCells()
        tableView.register(IngredientsCell.self, forCellReuseIdentifier: IngredientsCell.reuseID)
        tableView.register(InstructionsCell.self, forCellReuseIdentifier: InstructionsCell.reuseID)
    }
    
    func getDetails(meal: Meal) {
        networkManager.getDetails(endpoint: Endpoint.details(id: meal.id).url) { [weak self] (result: Result<Details, DTError>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.updateUI(with: response)
            case .failure(let error):
                self.presentDTAlertOnMainThread(title: "Something Went Wrong", message: error.rawValue, buttonTitle: "Ok")
            }
        }
    }
    
    func updateUI(with details: Details) {
        self.details = details
        reloadDataOnMainThread()
    }
}

extension MealDetailVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let details = details else { return UITableViewCell() }
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: IngredientsCell.reuseID) as! IngredientsCell
            cell.set(details: details)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: InstructionsCell.reuseID) as! InstructionsCell
            cell.set(details: details)
            return cell
        }
    }
}
