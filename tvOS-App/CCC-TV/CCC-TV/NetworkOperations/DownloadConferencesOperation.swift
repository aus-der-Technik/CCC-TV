//
//  DownloadConferencesOperation.swift
//  CCCtv
//
//  Created by Kris Simon on 10/12/15.
//  Copyright © 2015 aus der Technik. All rights reserved.
//

import Foundation
import SwiftyJSON

class DownloadConferencesOperation: Operation {

    private var _finished: Bool = false {
        willSet {
            self.willChangeValueForKey("isFinished");
        }
        didSet {
            self.didChangeValueForKey("isFinished");
        }
    }
    override var isFinished: Bool {
        get {
            return _finished
        }
    }
    
    let dateFormatter = DateFormatter()
    
    override init(){
        dateFormatter.dateFormat = "yyyy-MM-dd'T'kk:mm:ss.SSSxxxxx"
    }
    
    override func main() {
        var conferencesRequest = ConferencesRequest()
        conferencesRequest.performRequest(){
            (err: RequestError?, data: JSON?)->() in
            
            if let data = data {
                let _data = data["conferences"]
                for (_,subJson):(String, JSON) in _data {
                    let acronym = subJson["acronym"].stringValue
                    NSLog("** Download conference \(acronym)")
                    allConferences = allConferences.filter({$0.acronym != acronym})

                    let conference = Conference(
                          title: subJson["title"].stringValue
                        , acronym: subJson["acronym"].stringValue
                        , logo_url: NSURL(string: subJson["logo_url"].stringValue)!
                        , updated_at: self.dateFormatter.dateFromString(subJson["updated_at"].stringValue)! as NSDate
                        , aspect_ratio: subJson["aspect_ratio"].stringValue
                        , schedule_url: NSURL(string: subJson["schedule_url"].stringValue)!
                        , images_url: NSURL(string: subJson["images_url"].stringValue)!
                        , recordings_url: NSURL(string: subJson["recordings_url"].stringValue)
                        , webgen_location: subJson["webgen_location"].stringValue
                        , slug: subJson["slug"].stringValue
                        , url: NSURL(string: subJson["url"].stringValue)!
                    )
                    allConferences.append(conference)
                }
            }
            allConferences.sortInPlace({ $0.updated_at.compare($1.updated_at) == ComparisonResultrderedDescending })
            
            self._finished = true
        }
    
    }
}
