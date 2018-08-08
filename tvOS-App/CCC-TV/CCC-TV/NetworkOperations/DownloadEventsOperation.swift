//
//  DownloadEventsOperation.swift
//  CCCtv
//
//  Created by Kris Simon on 16/12/15.
//  Copyright © 2015 aus der Technik. All rights reserved.
//

import Foundation
import SwiftyJSON

class DownloadEventsOperation: Operation {
    
    private let eventId: Int
    
    private var _finished: Bool = false {
        willSet {
            self.willChangeValue(forKey: "isFinished");
        }
        didSet {
            self.didChangeValue(forKey: "isFinished");
        }
    }
    override var isFinished: Bool {
        get {
            return _finished
        }
    }
    
    let dateFormatter = DateFormatter()
    
    init(eventId: Int){
        dateFormatter.dateFormat = "yyyy-MM-dd'T'kk:mm:ss.SSSxxxxx"
        self.eventId = eventId
    }
    
    override func main() {
        var eventsRequest = EventsRequest(eventid: eventId)
        eventsRequest.performRequest(){
            (err: RequestError?, data: JSON?)->() in
            
            if let data = data {
                let _data = data["events"]
                for (_,subJson):(String, JSON) in _data {
                    let guid = subJson["guid"].stringValue
                    NSLog("** Download event \(subJson["title"].stringValue) \(guid)")
                    if(allEvents.keys.contains(self.eventId) == false){
                       allEvents[self.eventId] = []
                    }
                    allEvents[self.eventId] = allEvents[self.eventId]!.filter({$0.guid != guid})
                    var defaultDate = "1970-01-01T00:00:00.000+00:00"
                    if(subJson["date"].exists() && subJson["date"].stringValue != "") {
                        defaultDate = subJson["date"].stringValue
                    }
                    var event = Event(
                          eventId: self.eventId
                        , title: subJson["title"].stringValue
                        , subtitle: subJson["subtitle"].stringValue
                        , description: subJson["description"].stringValue
                        , length: subJson["length"].intValue
                        , tags: [""]
                        , persons: [""]
                        , slug: subJson["slug"].stringValue
                        , guid: subJson["guid"].stringValue
                        , url: NSURL(string: subJson["url"].stringValue)!
                        , link: NSURL(string: subJson["link"].stringValue)
                        , frontend_link: NSURL(string: subJson["frontend_link"].stringValue)
                        , date: self.dateFormatter.date(from: defaultDate)! as NSDate
                        , release_date: nil
                        , updated_at: self.dateFormatter.date(from: subJson["updated_at"].stringValue) as NSDate?
                        , poster_url: NSURL(string: subJson["poster_url"].stringValue)
                        , thumb_url: NSURL(string: subJson["thumb_url"].stringValue)
                        , conference_url: NSURL(string: subJson["conference_url"].stringValue)
                    )
                    
                    if subJson["release_date"].exists() {
                        event.release_date = self.dateFormatter.date(from: subJson["release_date"].stringValue) as NSDate?
                    } else {
                        event.release_date = NSDate()
                    }
                    allEvents[self.eventId]!.append(event)
                }
            }
            if(allEvents.keys.contains(self.eventId)) {
                allEvents[self.eventId]!.sort(by: { $0.date.compare($1.date as Date) == ComparisonResult.orderedDescending })
            }
            self._finished = true
        }
        
    }
}
