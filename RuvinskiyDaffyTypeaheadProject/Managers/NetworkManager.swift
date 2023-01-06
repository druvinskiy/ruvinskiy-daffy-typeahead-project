//
//  NetworkManager.swift
//  RuvinskiyDaffyTypeaheadProject
//
//  Created by David Ruvinskiy on 12/17/22.
//

import UIKit

class NetworkManager {
    
    private var baseUrl: String
    private var urlSession: URLSession
    let cache = NSCache<NSString, UIImage>()
    
    init(baseUrl: String = "https://www.themealdb.com/api/json/v1/1/", urlSession: URLSession = URLSession.shared) {
        self.baseUrl = baseUrl
        self.urlSession = urlSession
    }
    
    func getCategories(completed: @escaping (Result<[Category], DTError>) -> Void) {
        getCategories(endpoint: Endpoint.categories.url, completed: completed)
    }
    
    func getCategories(endpoint: URL?, completed: @escaping (Result<[Category], DTError>) -> Void) {
        fetchGenericJSONData(url: endpoint) { (result: Result<CategoryResponse, DTError>) in
            switch result {
            case .success(let response):
                completed(.success(response.categories))
            case .failure(let error):
                completed(.failure(error))
            }
        }
    }
    
    func getAllMeals(completed: @escaping (Result<[Meal], DTError>) -> Void) {
        getCategories {
            [weak self] (result: Result<[Category], DTError>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let categories):
                self.getAllMeals(for: categories, completed: completed)
            case .failure(let error):
                completed(.failure(error))
            }
        }
    }
    
    private func getAllMeals(for categories: [Category], completed: @escaping (Result<[Meal], DTError>) -> Void) {
        let dispatchGroup = DispatchGroup()
        var meals = [Meal]()
        var failure: DTError?
        
        for category in categories {
            dispatchGroup.enter()
            self.getMeals(endpoint: Endpoint.meals(category: category.name).url) { (result: Result<[Meal], DTError>) in
                dispatchGroup.leave()
                switch result {
                case .success(let response):
                    meals += response
                case .failure(let error):
                    failure = error
                    break
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            guard let failure = failure else {
                completed(.success(meals))
                return
            }
            
            completed(.failure(failure))
        }
    }
    
    private func getMeals(endpoint: URL?, completed: @escaping (Result<[Meal], DTError>) -> Void) {
        fetchGenericJSONData(url: endpoint) { (result: Result<MealResponse, DTError>) in
            switch result {
            case .success(let response):
                completed(.success(response.meals))
            case .failure(let error):
                completed(.failure(error))
            }
        }
    }
    
    func getDetails(endpoint: URL?, completed: @escaping (Result<Details, DTError>) -> Void) {
        fetchGenericJSONData(url: endpoint) { (result: Result<Details, DTError>) in
            switch result {
            case .success(let details):
                completed(.success(details))
            case .failure(let error):
                completed(.failure(error))
            }
        }
    }
    
    func fetchGenericJSONData<T: Decodable>(url: URL?, completed: @escaping (Result<T, DTError>) -> Void) {
        guard let url = url else {
            completed(.failure(.invalidURL))
            return
        }
        
        let task = urlSession.dataTask(with: URLRequest(url: url)) { data, response, error in
            if let _ = error {
                completed(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completed(.failure(.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let decodedResponse = try decoder.decode(T.self, from: data)
                completed(.success(decodedResponse))
            } catch {
                completed(.failure(.invalidData))
            }
        }
        
        task.resume()
    }
    
    func downloadImage(from urlString: String, completed: @escaping (UIImage?) -> Void) {
        let cacheKey = NSString(string: urlString)
        
        if let image = cache.object(forKey: cacheKey) {
            completed(image)
            return
        }
        
        guard let url = URL(string: urlString) else {
            completed(nil)
            return
        }
        
        let task = urlSession.dataTask(with: url) { [self] data, response, error in
            guard error == nil,
                  let response = response as? HTTPURLResponse, response.statusCode == 200,
                  let data = data,
                  let image = UIImage(data: data) else {
                completed(nil)
                return
            }
            
            self.cache.setObject(image, forKey: cacheKey)
            completed(image)
        }
        
        task.resume()
    }
}
