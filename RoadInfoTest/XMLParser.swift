//
//  XMLParser.swift
//  RoadInfoTest
//
//  Created by Matt Wynyard on 24/10/15.
//  Copyright © 2015 Niobium. All rights reserved.
//

import Foundation

class XMLParser: NSObject, NSXMLParserDelegate {
    
    let parser: NSXMLParser!
    let _data: NSData!
    var eventArray = [RoadEvent]()
    var count: Int = -1
    var currentElement: String! = nil

    init(data: NSData) {
        parser = NSXMLParser(data: data)
        self._data = data
        super.init()
        parser.delegate = self
        parser.parse()
    }
    
    func parserDidStartDocument(parser: NSXMLParser) {
        print("Start parsing")
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
        print("Finished parsing")
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        //print("Element's name is \(elementName)")
        
        if elementName == "tns:roadEvent" {
            eventArray.append(RoadEvent())
            print(count)
            count++
        }
        currentElement = elementName
    }

    func parser(parser: NSXMLParser, foundCharacters string: String) {
        
        print(string)
        
        switch currentElement {
        case "tns:alternativeRoute":
            eventArray[count].alternativeRoute = string
            
        case "tns:directLineDistance1":
            eventArray[count].directLineDistance.addObject(string)
            
        case "tns:directLineDistance2":
            eventArray[count].directLineDistance.addObject(string)
            
        case "tns:directLineDistance3":
            eventArray[count].directLineDistance.addObject(string)
            
        case "tns:endDate":
            let date: NSDate = formatDate(string)
            let formatter = NSDateFormatter()
            formatter.dateFormat = "dd-MM-yyyy hh:mm a"
            formatter.timeZone = NSTimeZone(forSecondsFromGMT: 13 * 3600)
            eventArray[count].endDate = date
            //print(formatter.stringFromDate(date))
        case "tns:eventComments":
            eventArray[count].eventComments = string
        case "tns:eventDescription":
            eventArray[count].eventDescription = string
        case "tns:eventId":
            eventArray[count].eventId = Int(string)
        case "tns:eventIsland":
            eventArray[count].eventIsland = string
        case "tns:eventType":
            eventArray[count].eventType = string
        case "tns:expectedResolution":
            eventArray[count].expectedResolution = string
        case "tns:impact":
            eventArray[count].impact = string
        case "tns:locationArea":
            eventArray[count].locationArea = string
        case "tns:planned":
            if string == "true" {
                eventArray[count].planned = true
            } else {
               eventArray[count].planned = false
            }
        case "tns:location":
            eventArray[count].location.addObject(string)
        case "tns:restrictions":
            eventArray[count].restrictions = string
        case "tns:startDate":
            let date: NSDate = formatDate(string)
            eventArray[count].startDate = date
        case "tns:status":
            eventArray[count].status = string
        case "tns:wktGeometry":
            eventArray[count].wktGeometry = string
            if count == 0 {
                print(string)
                eventArray[count].setCoordinates()
                let nzmg: NZMGConverter = NZMGConverter(easting: eventArray[0].coordinate.0, northing: eventArray[0].coordinate.1)
                print(nzmg.nzmgToNZGD1949())
            }
        case "tns:eventCreated":
            let date: NSDate = formatDate(string)
            //let formatter = NSDateFormatter()
            //formatter.dateFormat = "dd-MM-yyyy hh:mm a"
            //formatter.timeZone = NSTimeZone(forSecondsFromGMT: 13 * 3600)
            eventArray[count].eventCreated = date
            
        case "tns:eventModified":
            let date: NSDate = formatDate(string)
            let formatter = NSDateFormatter()
            formatter.dateFormat = "dd-MM-yyyy hh:mm a"
            formatter.timeZone = NSTimeZone(forSecondsFromGMT: 13 * 3600)
            eventArray[count].eventModified = date
            
        case "tns:informationSource":
            eventArray[count].informationSource = string
            
        case "tns:supplier":
            eventArray[count].supplier = string
            
        case "tns:eventRegions":
            eventArray[count].eventRegions.addObject(string)
            
        default:
            break
        }
    }
    
    func formatDate(date: String) -> NSDate {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        let localDate = formatter.dateFromString(date)
        return localDate!
    }
}
