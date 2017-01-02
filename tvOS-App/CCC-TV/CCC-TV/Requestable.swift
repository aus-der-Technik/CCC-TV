//
//  Requestable.swift
//  CCCtv
//
//  Created by Kris Simon on 13/12/15.
//  Copyright © 2015 aus der Technik. All rights reserved.
//

import Foundation
import SwiftyJSON

let apiUrl = "https://api.media.ccc.de/public"

enum RequestError {
    case JsonError
    case RequestError
    case MissingContextError
}

protocol Requestable {
    var jsonData: JSON { get set }
    var requestUrl: String { get }
    
    //init()
}


extension Requestable {
    
    mutating func performRequest(completionHandler: @escaping (RequestError?, JSON?)->()) {
        let url = NSURL(string: "\(apiUrl)\(requestUrl)")
        
        let configuration = URLSessionConfiguration.default
        
        let request = URLRequest(url: url! as URL)
        
        let session = URLSession(
            configuration: configuration
            , delegate: SessionDelegate()
            , delegateQueue: OperationQueue.main
        )
        
        let task = session.dataTask(with: request) {
            (data: NSData?, response: URLResponse?, error: NSError?) -> Void in
            
            if error != nil {
                NSLog(error!.localizedDescription)
                completionHandler( RequestError.RequestError, nil)
            } else {
                let json = JSON(data: data!)
                if json.error != nil {
                    NSLog(json.error!.localizedDescription)
                    completionHandler(RequestError.JsonError, nil)
                } else {
                    self.jsonData = json
                    completionHandler(nil, json)
                }
            }
        }
        task.resume()
    }
    
}

class SessionDelegate: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
    
    func URLSession(session: URLSession, task: NSURLSessionTask, didReceiveChallenge challenge: URLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        if let trust = challenge.protectionSpace.serverTrust {
            completionHandler(
                NSURLSessionAuthChallengeDisposition.UseCredential
                , NSURLCredential(forTrust: trust)
            )
        } else {
            completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, nil)
        }
    }
    
    func URLSession(session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest?) -> Void) {
        let newRequest : NSURLRequest? = request
        completionHandler(newRequest)
    }
}

