//
//  EventsRequest.swift
//  CCCtv
//
//  Created by Kris Simon on 16/12/15.
//  Copyright © 2015 aus der Technik. All rights reserved.
//

import Foundation
import SwiftyJSON

class EventsRequest: Requestable {
    
    private let eventId: Int


    required init(eventid: Int) {
        eventId = eventid
    }
    
    var requestUrl: String {
        get {
            return "/conferences/\(eventId)"
        }
    }
    
    var _json: JSON?
    var jsonData: JSON {
        get {
            if self._json != nil {
                return _json!
            }
            return JSON(data: "{}".data(usingEncoding: NSUTF8StringEncoding)!)
        }
        set(newJson) {
            self._json = newJson
        }
    }
}
