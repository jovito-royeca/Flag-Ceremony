//
//  Scraper.swift
//  Flag Ceremony
//
//  Created by Jovit Royeca on 23/11/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import Foundation
import Firebase
import Networking

class Scraper : NSObject {
    let ref = FIRDatabase.database().reference()
    
    func insertCountries() {
        let baseURL = CountriesURL
        let path = "/info/all.json"
        let method:HTTPMethod = .Get
        let headers:[String: String]? = nil
        let paramType:Networking.ParameterType = .json
        let params = "?x=100" as AnyObject
        let completionHandler = { (result: [[String : Any]], error: NSError?) -> Void in
            if let error = error {
                print("error: \(error)")
            } else {
                if let data = result.first {
                    if let countries = data["Results"] as? [String: [String: Any]] {
                        for (key,value) in countries {
                            let country = self.ref.child("countries").child(key)
                            for (key2,value2) in value {
                                country.child(key2).setValue(value2)
                            }
                        }
                    }
                }
            }
        }
        
        NetworkingManager.sharedInstance.doOperation(baseURL, path: path, method: method, headers: headers, paramType: paramType, params: params, completionHandler: completionHandler)
    }
    
    func insertAnthems() {
        if let path = Bundle.main.path(forResource: "anthems", ofType: "json", inDirectory: "data") {
            if FileManager.default.fileExists(atPath: path) {
                
                if let data = NSData(contentsOf: URL(fileURLWithPath: path)) {
                    do {
                        let dictionary = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? NSDictionary
                        
                        for (key,value) in dictionary! {
                            if let key2 = key as? String,
                                let value2 = value as? [String: Any] {
                                
                                let anthem = self.ref.child("anthems").child(key2)
                                for (key3,value3) in value2 {
                                    anthem.child(key3).setValue(value3)
                                }
                            }
                        }
                    } catch let error {
                        print("Error!! \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func downloadAnthems() {
        ref.child("countries").observeSingleEvent(of: .value, with: { (snapshot) in
            let countries = snapshot.value as? [String: [String: Any]] ?? [:]
            
            for (key,value) in countries {
                let country = Country.init(key: key, dict: value)
                
                if let url = URL(string: "\(HymnsURL)/\(key.lowercased()).mp3") {
                    let docsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                    let localPath = "\(docsPath)/\(key.lowercased()).mp3"
                    
                    if country.getAudioURL() == nil {
                        let existsHandler = { (fileExistsAtServer: Bool) -> Void in
                            if fileExistsAtServer {
                                print ("downloading... \(country.name!)")
                                let completionHandler = { (data: Data?, error: NSError?) -> Void in
                                    if let error = error {
                                        print("error: \(error)")
                                    } else {
                                        do {
                                            try data!.write(to: URL(fileURLWithPath: localPath))
                                            print("saved: \(localPath)")
                                            self.updateCountry(key: key, hasAnthemFile: true)
                                        } catch {
                                            
                                        }
                                    }
                                }
                                
                                NetworkingManager.sharedInstance.downloadFile(url: url, completionHandler: completionHandler)
                            } else {
                                self.updateCountry(key: key, hasAnthemFile: false)
                            }
                        }
                        NetworkingManager.sharedInstance.fileExistsAt(url: url, completion: existsHandler);
                    
                    } else {
                        self.updateCountry(key: key, hasAnthemFile: true)
                    }
                    
                }
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func updateCountry(key: String, hasAnthemFile: Bool) {
        let countryRef = ref.child("countries").child(key)
        
        countryRef.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if var post = currentData.value as? [String : Any] {
                post[Country.Keys.HasAnthemFile] = NSNumber(value: hasAnthemFile)
                
                // Set value and report transaction success
                currentData.value = post
                
                return FIRTransactionResult.success(withValue: currentData)
            }
            return FIRTransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Shared Instance
    static let sharedInstance = Scraper()
}