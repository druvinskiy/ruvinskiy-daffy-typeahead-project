//
//  MockURLProtocol.swift
//  RuvinskiyDaffyTypeaheadProjectTests
//
//  Created by David Ruvinskiy on 1/2/23.
//

import XCTest

class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Error?))?
    static var testURLs = [URL?: Data]()
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler, let url = request.url else {
            XCTFail("Received unexpected request")
            return
        }
        do {
            let (response, error) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            
            if let error = error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            if let data = MockURLProtocol.testURLs[url] {
                self.client?.urlProtocol(self, didLoad: data)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {
    }
}
