//
//  Downloader.swift
//  CCCtv
//
//  Created by Kris Simon on 10/12/15.
//  Copyright © 2015 aus der Technik. All rights reserved.
//

import Foundation

var downloadQueue = OperationQueue()

class Downloader {
    
    func performDownload(completionHandler callback: (()->())? = nil){
        // conferences
        let conferencesDownloader = DownloadConferencesOperation()
        
        conferencesDownloader.completionBlock = {
            print("# conferencesDownloader finish")
            if let callback = callback {
                callback()
            }
        }
        
        downloadQueue.addOperation(conferencesDownloader)
    }
    
}
