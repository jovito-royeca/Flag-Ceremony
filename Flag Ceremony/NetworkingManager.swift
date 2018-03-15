//
//  NetworkingManager.swift
//  Flag Ceremony
//
//  Created by Jovit Royeca on 01/11/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import Networking

enum HTTPMethod: String {
    case post  = "Post",
    get  = "Get",
    head = "Head",
    put = "Put"
}

typealias NetworkingResult = (_ result: [[String : Any]], _ error: NSError?) -> Void

class NetworkingManager: NSObject {
    var networkers = [String: Any]()
    
    func doOperation(_ baseUrl: String,
                     path: String,
                     method: HTTPMethod,
                     headers: [String: String]?,
                     paramType: Networking.ParameterType,
                     params: AnyObject?,
                     completionHandler: @escaping NetworkingResult) -> Void {
        
            let networker = networking(forBaseUrl: baseUrl)
            
            if let headers = headers {
                networker.headerFields = headers
            }
            
            switch (method) {
            case .post:
                networker.post(path, parameterType: paramType, parameters: params, completion: {(result) in
                    switch result {
                    case .success(let response):
                        if response.dictionaryBody.count > 0 {
                            completionHandler([response.dictionaryBody], nil)
                        } else if response.arrayBody.count > 0 {
                            completionHandler(response.arrayBody, nil)
                        } else {
                            completionHandler([[String : Any]](), nil)
                        }
                    case .failure(let response):
                        let error = response.error
                        print("Networking error: \(error)")
                        completionHandler([[String : Any]](), error)
                    }
                })
            case .get:
                networker.get(path, parameters: params, completion: {(result) in
                    switch result {
                    case .success(let response):
                        if response.dictionaryBody.count > 0 {
                            completionHandler([response.dictionaryBody], nil)
                        } else if response.arrayBody.count > 0 {
                            completionHandler(response.arrayBody, nil)
                        } else {
                            completionHandler([[String : Any]](), nil)
                        }
                    case .failure(let response):
                        let error = response.error
                        print("Networking error: \(error)")
                        completionHandler([[String : Any]](), error)
                    }
                })
            case .head:
                ()
            case .put:
                networker.put(path, parameterType: paramType, parameters: params, completion: {(result) in
                    switch result {
                    case .success(let response):
                        if response.dictionaryBody.count > 0 {
                            completionHandler([response.dictionaryBody], nil)
                        } else if response.arrayBody.count > 0 {
                            completionHandler(response.arrayBody, nil)
                        } else {
                            completionHandler([[String : Any]](), nil)
                        }
                    case .failure(let response):
                        let error = response.error
                        print("Networking error: \(error)")
                        completionHandler([[String : Any]](), error)
                    }
                })
            }
        
    }
    
    func downloadImage(url: URL, completionHandler: @escaping (_ origURL: URL?, _ image: UIImage?, _ error: NSError?) -> Void) {
        let networker = networking(forUrl: url)
        var path = url.path
        
        if let query = url.query {
            path += "?\(query)"
        }
        
        networker.downloadImage(path, completion: {(result) in
            switch result {
            case .success(let response):
                // skip from iCloud backups!
                do {
                    var destinationURL = try networker.destinationURL(for: path)
                    var resourceValues = URLResourceValues()
                    resourceValues.isExcludedFromBackup = true
                    try destinationURL.setResourceValues(resourceValues)
                }
                catch {}
                completionHandler(url, response.image, nil)
            case .failure(let response):
                let error = response.error
                print("Networking error: \(error)")
                completionHandler(nil, nil, error)
            }
        })
    }
    
    func downloadFile(url: URL, completionHandler: @escaping (Data?, NSError?) -> Void) {
        let networker = networking(forUrl: url)
        let path = url.path
        
        networker.downloadData(path, cacheName: nil, completion: {(result) in
            switch result {
            case .success(let response):
                completionHandler(response.data, nil)
            case .failure(let response):
                let error = response.error
                print("Networking error: \(error)")
                completionHandler(nil, error)
            }
        })
    }
    
    func fileExistsAt(url : URL, completion: @escaping (Bool) -> Void) {
        let checkSession = Foundation.URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 1.0 // Adjust to your needs
        
        let task = checkSession.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if let httpResp: HTTPURLResponse = response as? HTTPURLResponse {
                completion(httpResp.statusCode == 200)
            }
        })
        
        task.resume()
    }
    
    // MARK: Private methods
    private func networking(forBaseUrl url: String) -> Networking {
        var networker:Networking?
//
//        if let n = networkers[url] as? Networking {
//            networker = n
//        } else {
//            let newN = Networking(baseURL: url, configurationType: .default)
//
//            networkers[url] = newN
//            networker = newN
//        }
//
        networker = Networking(baseURL: url, configuration: .default)
        
        return networker!
    }
    
    private func networking(forUrl url: URL) -> Networking {
        var networker:Networking?
        var baseUrl = ""
        if let scheme = url.scheme {
            baseUrl = "\(scheme)://"
        }
        if let host = url.host {
            baseUrl.append(host)
        }
        
//        if let n = networkers[baseUrl] as? Networking {
//            networker = n
//        } else {
//            let newN = Networking(baseURL: baseUrl, configurationType: .default)
//
//            networkers[baseUrl] = newN
//            networker = newN
//        }
        
        networker = Networking(baseURL: baseUrl, configuration: .default)
        return networker!
    }
    
    // MARK: - Shared Instance
    static let sharedInstance = NetworkingManager()
}
