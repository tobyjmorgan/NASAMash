//
//  APIClient.swift
//  TheAPIAwakens
//
//  Created by redBred LLC on 11/29/16.
//  Copyright © 2016 redBred. All rights reserved.
//

// Many thanks to Pasan Premaratne, who provided most of this code in his Treehouse courses

import Foundation

typealias JSON = [String : AnyObject]
typealias JSONTask = URLSessionDataTask
typealias JSONTaskCompletion = (JSON?, HTTPURLResponse?, APIClientError?) -> Void

enum APIClientError: Error {
    case missingHTTPResponse
    case noDataReturned(Error?)
    case unexpectedHTTPResponseStatusCode(Int)
    case unableToSerializeDataToJSON(Error)
    case unableToParseJSON(JSON)
    case unknownError
}

enum APIResult<T> {
    case success(T)
    case failure(Error)
}

protocol APIEndpoint {
    var baseURL: String { get }
    var path: String { get }
}

extension APIEndpoint {
    var request: URLRequest {
        print(baseURL)
        print(path)
        let url = URL(string: baseURL + path)!
        return URLRequest(url: url)
    }
}

protocol JSONDecodable {
    init?(JSON: JSON)
}

protocol APIClient {
    var configuration: URLSessionConfiguration { get }
    var session: URLSession { get }
    
    init(config: URLSessionConfiguration)
    
    func JSONTaskWithRequest(request: URLRequest, completion: @escaping JSONTaskCompletion) -> JSONTask
    func fetch<T>(request: URLRequest, parse: @escaping (JSON) -> T?, completion: @escaping (APIResult<T>) -> Void)
}

extension APIClient {
    
    func JSONTaskWithRequest(request: URLRequest, completion: @escaping JSONTaskCompletion) -> JSONTask {

        let task = session.dataTask(with: request) { (data, response, error) in
            
            guard let response = response as? HTTPURLResponse else {
                completion(nil, nil, APIClientError.missingHTTPResponse)
                return
            }
            
            guard let data = data else {
                completion(nil, response, APIClientError.noDataReturned(error))
                return
            }

            switch response.statusCode {
            
            case 200:
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? JSON
                    completion(json, response, nil)
                } catch let error {
                    completion(nil, response, APIClientError.unableToSerializeDataToJSON(error))
                }
            
            default:
                completion(nil, response, APIClientError.unexpectedHTTPResponseStatusCode(response.statusCode))
                return
            }
        }
        
        return task
    }
    
    func fetch<T>(request: URLRequest, parse: @escaping (JSON) -> T?, completion: @escaping (APIResult<T>) -> Void) {
        
        let task = JSONTaskWithRequest(request: request) { (json, response, error) in
            
            DispatchQueue.main.async {
                guard let json = json else {
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.failure(APIClientError.unknownError))
                    }
                    return
                }
                
                if let value = parse(json) {
                    completion(.success(value))
                } else {
                    completion(.failure(APIClientError.unableToParseJSON(json)))
                }
            }
        }
        
        task.resume()
    }
    
    func fetch<T>(request: URLRequest, parse: @escaping (JSON) -> [T]?, completion: @escaping (APIResult<[T]>) -> Void) {
        
        let task = JSONTaskWithRequest(request: request) { (json, response, error) in
            
            DispatchQueue.main.async {
                guard let json = json else {
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.failure(APIClientError.unknownError))
                    }
                    return
                }
                
                if let value = parse(json) {
                    completion(.success(value))
                } else {
                    completion(.failure(APIClientError.unableToParseJSON(json)))
                }
            }
        }
        
        task.resume()
    }
}
