//
//  main.swift
//  RoadInfoTest
//
//  Created by Matt Wynyard on 22/10/15.
//  Copyright © 2015 Niobium. All rights reserved.
//

import Foundation

var running = true
var xmlParser: XMLParser!

func httpGet(request: NSURL!, callback: (NSData, String, String?) -> Void) {
    let config = NSURLSessionConfiguration.defaultSessionConfiguration()
    config.HTTPAdditionalHeaders = ["username" : "mjwynyard", "password" : "Copper2004"]
    let session = NSURLSession(configuration: config)
    let task = session.dataTaskWithURL(request){
        (data, response, error) -> Void in
        if error != nil {
            let errorData = NSData()
            callback(errorData, "", error!.localizedDescription)
        } else {
            let result = NSString(data: data!, encoding:
                NSASCIIStringEncoding)!
            callback(data!, result as String, nil)
        }
    }
    task.resume()
}
//var request = NSMutableURLRequest(URL:
   var request = NSURL(string: "https://infoconnect1.highwayinfo.govt.nz/ic/jbi/TREIS/REST/FeedService/")!

httpGet(request) {
    (responseData, xmlString, error) -> Void in
    if error != nil {
        print(error!)
        running = false
    } else {
        print(xmlString)
        xmlParser = XMLParser(data: responseData)
        print(xmlParser.eventArray[0])
        running = false
    }
}

while(running) {
    NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate())
   
}