//
//  RuvinskiyDaffyTypeaheadProjectTests.swift
//  RuvinskiyDaffyTypeaheadProjectTests
//
//  Created by David Ruvinskiy on 1/2/23.
//

import XCTest
@testable import RuvinskiyDaffyTypeaheadProject

final class RuvinskiyDaffyTypeaheadProjectTests: XCTestCase, Mockable {
    
    var networkManager: NetworkManager!
    
    override func setUp() {
        super.setUp()
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        
        let session = URLSession(configuration: config)
        networkManager = NetworkManager(urlSession: session)
        
        MockURLProtocol.testURLs = [
            Endpoint.categories.url : loadData(filename: "CategoryResponse"),
            Endpoint.meals(category: "Beef").url : loadData(filename: "BeefResponse"),
            Endpoint.meals(category: "Chicken").url : loadData(filename: "ChickenResponse"),
            Endpoint.meals(category: "Dessert").url : loadData(filename: "DessertResponse"),
            Endpoint.details(id: "53049").url : loadData(filename: "DetailsResponse")
        ]
    }
    
    override func tearDown() {
        super.tearDown()
        
        networkManager = nil
        MockURLProtocol.testURLs = [:]
    }
    
    func testGetCategories() {
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(), nil)
        }
        
        let exp = XCTestExpectation()
        
        networkManager.getCategories { (result: Result<[RuvinskiyDaffyTypeaheadProject.Category], DTError>) in
            exp.fulfill()
            switch result {
            case .success(_):
                break
            case .failure(_):
                XCTAssert(false)
            }
        }
        
        wait(for: [exp], timeout: 3)
        
        testInvalidURL(networkCall: networkManager.getCategories)
        testUnableToComplete(networkCall: networkManager.getCategories, url: nil, networkCallWithURL: nil)
        test404(networkCall: networkManager.getCategories, url: nil, networkCallWithURL: nil)
        testInvalidData(networkCall: networkManager.getCategories, url: nil, networkCallWithURL: nil)
    }
    
    func testGetAllMeals() {
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(), nil)
        }
        
        let exp = XCTestExpectation()
        
        networkManager.getAllMeals { (result: Result<[Meal], DTError>) in
            exp.fulfill()
            switch result {
            case .success(let meals):
                print(meals)
                break
            case .failure(_):
                XCTAssert(false)
            }
        }
        
        wait(for: [exp], timeout: 3)
        
        testUnableToComplete(networkCall: networkManager.getAllMeals, url: nil, networkCallWithURL: nil)
        test404(networkCall: networkManager.getAllMeals, url: nil, networkCallWithURL: nil)
        testInvalidData(networkCall: networkManager.getAllMeals, url: nil, networkCallWithURL: nil)
    }
    
    func testFilterMeals() {
        let meals = Meal.getSampleMeals()
        
        XCTAssertTrue(Meal.filter(meals: meals, filter: "").count == 0)
        
        XCTAssertTrue(Meal.filter(meals: meals, filter: "Ap") == [
            Meal(id: "53049"),
            Meal(id: "52893"),
            Meal(id: "52768")
        ])
        
        XCTAssertTrue(Meal.filter(meals: meals, filter: "Apam balik") == [
            Meal(id: "53049")
        ])
    }
    
    func testGetDetails() {
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(), nil)
        }
        
        let exp = XCTestExpectation()
        
        let endpoint = Endpoint.details(id: "53049").url
        
        networkManager.getDetails(endpoint: endpoint) { (result: Result<Details, DTError>) in
            exp.fulfill()
            switch result {
            case .success(let details):
                for ingredient in details.ingredients {
                    XCTAssertTrue(!ingredient.name.isEmpty)
                    XCTAssertTrue(!ingredient.measurement.isEmpty)
                }
            case .failure(_):
                XCTAssert(false)
            }
        }
        
        wait(for: [exp], timeout: 3)
        
        testInvalidURL(networkCall: networkManager.getDetails)
        testUnableToComplete(networkCall: nil, url: endpoint, networkCallWithURL: networkManager.getDetails)
        test404(networkCall: nil, url: endpoint, networkCallWithURL: networkManager.getDetails)
        testInvalidData(networkCall: nil, url: endpoint, networkCallWithURL: networkManager.getDetails)
    }
    
    func testInvalidURL<T: Decodable>(networkCall: (URL?, @escaping (Result<T, DTError>) -> Void) -> Void) {
        let exp = XCTestExpectation()
        
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(), nil)
        }
        
        networkCall(URL(string: "invalid url")) {
            (result: Result<T, DTError>) in
            exp.fulfill()
            
            switch result {
            case .success(_):
                XCTAssert(false)
            case .failure(let error):
                XCTAssertTrue(error == .invalidURL)
            }
        }
        
        wait(for: [exp], timeout: 3)
    }
    
    func testUnableToComplete<T: Decodable>(networkCall: ((@escaping (Result<T, DTError>) -> Void) -> Void)?,
                                            url: URL?,
                                            networkCallWithURL: ((URL?, @escaping (Result<T, DTError>) -> Void) -> Void)?) {
        let exp = XCTestExpectation()
        
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(), DTError.unableToComplete)
        }
        
        let completion = {
            (result: Result<T, DTError>) in
            exp.fulfill()
            
            switch result {
            case .success(_):
                XCTAssert(false)
            case .failure(let error):
                XCTAssertTrue(error == .unableToComplete)
            }
        }
        
        if let networkCallWithURL = networkCallWithURL {
            networkCallWithURL(url, completion)
        } else if let networkCall = networkCall {
            networkCall(completion)
        }
        
        wait(for: [exp], timeout: 3)
    }
    
    func test404<T: Decodable>(networkCall: ((@escaping (Result<T, DTError>) -> Void) -> Void)?,
                               url: URL?,
                               networkCallWithURL: ((URL?, @escaping (Result<T, DTError>) -> Void) -> Void)?) {
        let exp = XCTestExpectation()
        
        MockURLProtocol.requestHandler = { request in
            XCTAssertNotNil(request.url)
            
            let response = HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil)
            return (response ?? HTTPURLResponse(), nil)
        }
        
        let completion = {
            (result: Result<T, DTError>) in
            exp.fulfill()
            
            switch result {
            case .success(_):
                XCTAssert(false)
            case .failure(let error):
                XCTAssertTrue(error == .invalidResponse)
            }
        }
        
        if let networkCallWithURL = networkCallWithURL {
            networkCallWithURL(url, completion)
        } else if let networkCall = networkCall {
            networkCall(completion)
        }
        
        wait(for: [exp], timeout: 3)
    }
    
    func testInvalidData<T: Decodable>(networkCall: ((@escaping (Result<T, DTError>) -> Void) -> Void)?,
                                       url: URL?,
                                       networkCallWithURL: ((URL?, @escaping (Result<T, DTError>) -> Void) -> Void)?) {
        let exp = XCTestExpectation()
        
        MockURLProtocol.requestHandler = { request in
            MockURLProtocol.testURLs[request.url] = nil
            return (HTTPURLResponse(), nil)
        }
        
        let completion = {
            (result: Result<T, DTError>) in
            exp.fulfill()
            
            switch result {
            case .success(_):
                XCTAssert(false)
            case .failure(let error):
                XCTAssertTrue(error == .invalidData)
            }
        }
        
        if let networkCallWithURL = networkCallWithURL {
            networkCallWithURL(url, completion)
        } else if let networkCall = networkCall {
            networkCall(completion)
        }
        
        wait(for: [exp], timeout: 3)
    }
}
