//
//  ConferencesExport.swift
//  CCCtv
//
//  Created by Kris Simon on 14/12/15.
//  Copyright © 2015 aus der Technik. All rights reserved.
//

import UIKit
import TVMLKit

@objc protocol ConferencesExportProtocol : JSExport {
    func getConferences(fn: JSValue) -> Array<Dictionary<String, String>>
    func eventsOfConference(url: NSString, fn: JSValue)
    func isCensored(guid: String) -> Bool
}


class ConferencesExport: NSObject, ConferencesExportProtocol {
    
    let downloader = Downloader()

    private func conferenceStructToObject() -> Array<Dictionary<String, String>> {
        return allConferences.map(){(conference: Conference) -> Dictionary<String, String> in
            return Dictionary(dictionaryLiteral:
                ("title", conference.title)
                , ("acronym", conference.acronym)
                , ("logo_url", conference.logo_url.absoluteString)
                , ("updated_at", DateFormatter.localizedStringFromDate(conference.updated_at as Date, dateStyle: .mediumStyle, timeStyle: .mediumStyle) )
                , ("aspect_ratio", conference.aspect_ratio)
                , ("schedule_url", conference.schedule_url.absoluteString)
                , ("images_url", conference.images_url.absoluteString)
                , ("recordings_url", (conference.recordings_url?.absoluteString) ?? "")
                , ("webgen_location", conference.webgen_location)
                , ("slug", conference.slug)
                , ("url", conference.url.absoluteString)
            )
        }
    }
    
    private func eventStructToObject(withEventId eventId: Int) -> Array<Dictionary<String, String>> {
        var result: Array<Dictionary<String, String>> = []
        let eventList = allEvents[eventId]
        if let eventList = eventList {
        for event in eventList {
            result.append(
                Dictionary(dictionaryLiteral:
                      ("title", event.title)
                    , ("subtitle", event.subtitle)
                    , ("description", event.description)
                    , ("length", "\(event.length)")
                    , ("tags", event.tags.joinWithSeparator(","))
                    , ("persons", event.tags.joinWithSeparator(","))
                    , ("slug", event.slug)
                    , ("guid", event.guid)
                    , ("url", event.url.absoluteString)
                    , ("link", (event.link?.absoluteString) ?? "")
                    , ("frontend_link", (event.frontend_link?.absoluteString) ?? "")
                    , ("date", DateFormatter.localizedStringFromDate(event.date ?? NSDate(), dateStyle: .MediumStyle, timeStyle: .MediumStyle) )
                    , ("release_date", DateFormatter.localizedStringFromDate(event.release_date ?? NSDate(), dateStyle: .MediumStyle, timeStyle: .MediumStyle) )
                    , ("updated_at", DateFormatter.localizedStringFromDate(event.updated_at!, dateStyle: .MediumStyle, timeStyle: .MediumStyle) )
                    , ("poster_url", (event.poster_url?.absoluteString) ?? "")
                    , ("thumb_url", (event.thumb_url?.absoluteString) ?? "")
                    , ("conference_url", (event.conference_url?.absoluteString) ?? "")
                ))
        }
        }
        return result
    }
    
    func getConferences(fn: JSValue) -> Array<Dictionary<String, String>> {
        if(allConferences.count > 0){
            let conferences = conferenceStructToObject()
            //fn.callWithArguments(conferences)
            return conferences
        } else {
            downloader.performDownload(){
                globalJsContext?.evaluateScript("updateUI();")
                let conferences = self.conferenceStructToObject()
                fn.call(withArguments: conferences)
            }
            return Array(arrayLiteral: Dictionary())
        }
    }
    
    func eventsOfConference(url id: NSString, fn: JSValue){
        if(allEvents.count > 0){
            print("# events from the cahce")
            let events = self.eventStructToObject(withEventId: Int(id as String)!)
            
            NSLog("events length \(events.count)");
            fn.call(withArguments: events)

        } else {
            let eventsDownloader = DownloadEventsOperation(eventId: Int(id as String)!)
            
            eventsDownloader.completionBlock = {
                print("# eventsDownloader finish")
                let events = self.eventStructToObject(withEventId: Int(id as String)!)
                
                NSLog("events length \(events.count)");
                fn.callWithArguments(events)
                //globalJsContext?.evaluateScript("Presenter.addVideoItem("+(id as String)+");")
            }
            downloadQueue.addOperation(eventsDownloader)
        }
    }
    
    func isCensored(guid: String) -> Bool {
        return censoredEventList.filter({$0.guid == guid}).count > 0
    }
}

 
