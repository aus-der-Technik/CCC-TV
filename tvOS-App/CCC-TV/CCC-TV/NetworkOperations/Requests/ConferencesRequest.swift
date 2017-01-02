//
//  ConferencesRequest.swift
//  CCCtv
//
//  Created by Kris Simon on 13/12/15.
//  Copyright © 2015 aus der Technik. All rights reserved.
//

import Foundation
import SwiftyJSON

class ConferencesRequest: Requestable {

    required init() {

    }
    
    var requestUrl = "/conferences"
    
    var _json: JSON?
    var jsonData: JSON {
        get {
            if self._json != nil {
                return _json!
            }
            return JSON(data: "{}".data(using: String.Encoding.utf8)!)
        }
        set(newJson) {
            self._json = newJson
        }
    }
}
