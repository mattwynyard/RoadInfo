//
//  RoadEvent.swift
//  RoadInfoTest
//
//  Created by Matt Wynyard on 24/10/15.
//  Copyright © 2015 Niobium. All rights reserved.
//

import Foundation

typealias Coordinate = (easting: Double, northing: Double)
typealias Coordinates = [[Coordinate]]

class RoadEvent: CustomStringConvertible {
    
    var alternativeRoute: String! = nil
    var directLineDistance: NSMutableArray! = []
    var endDate: NSDate! = nil
    var eventComments: String! = nil
    var eventDescription: String! = nil
    var eventId: Int! = nil
    var eventIsland: String! = nil
    var eventType: String! = nil
    var expectedResolution: String! = nil
    var impact: String! = nil
    var locationArea: String! = nil
    var location: NSMutableArray! = []
    var planned: Bool! = nil
    var restrictions: String! = nil
    var startDate: NSDate! = nil
    var status: String! = nil
    var Latitude: Double! = nil
    var Longtitude: Double! = nil
    var srid: String! = nil
    var coordinate: Coordinate! = nil
    var coordinateWSG84: Coordinate! = nil
    var wktGeometry: String! = nil
    var wktGeometryType: String! = nil
    var eventCreated: NSDate! = nil
    var eventModified: NSDate! = nil
    var informationSource: String! = nil
    var supplier: String! = nil
    var eventRegions: NSMutableArray! = nil
    
    var description: String {
        get {
            return "event id: \(eventId)\u{000A}" +
            "alernative route: \(alternativeRoute)\u{000A}" +
            "direct line distance: \(directLineDistance)\u{000A}" +
            "start date: \(getDate(startDate)) \u{000A}" +
            "end date: \(getDate(endDate)) \u{000A}" +
            "event comments: \(eventComments)\u{000A}" +
            "event description: \(eventDescription)\u{000A}" +
            "event island: \(eventIsland)\u{000A}" +
            "event type: \(eventType)\u{000A}" +
            "expected resolution: \(expectedResolution)\u{000A}" +
            "impact: \(impact)\u{000A}" +
            "location area: \(locationArea)\u{000A}" +
            "locations: \(location)\u{000A}" +
            "planned: \(planned)\u{000A}" +
            "restrictions: \(restrictions)\u{000A}" +
            "status: \(status)\u{000A}" +
            "wktGeometry: \(wktGeometry)\u{000A}" +
            "wktGeometryType: \(wktGeometryType)\u{000A}" +
            "eventCreated: \(getDate(eventCreated))\u{000A}" +
            "eventModified: \(getDate(eventModified))\u{000A}" +
            "informationSource: \(informationSource)\u{000A}" +
            "supplier: \(supplier)\u{000A}" +
            "eventRegions: \(eventRegions)\u{000A}"
            
        }
    }
    
    func setCoordinates() {
        //print(wktGeometry)
        let sridTemp = getSubstringToIndex(wktGeometry, character: ";")
        let position = getSubstringFromIndex(wktGeometry, character: ";")
        srid = getSubstringFromIndex(sridTemp, character: "=")
        
        let type = getSubstringToIndex(position, character: "(")
        if type != "MULTILINESTRING" {
            wktGeometryType = getSubstringToIndex(type, character: " ")
        } else {
           wktGeometryType = type
        }
        if wktGeometryType == "POINT" {
            let tupleString = getSubstringFromIndex(position, character: " ")
            let values = tupleString.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "()"))
            let coordinate0 =  Double(getSubstringToIndex(values , character: " "))!
            let coordinate1 =  Double(getSubstringFromIndex(values , character: " "))!
            coordinate  = (easting: coordinate0, northing: coordinate1)
            print(coordinate)
            print(directLineDistance)
        } else {
            var array = Array<Array<Coordinate>>() //Array of array of tuples(Double)
            var tupleArray = [Coordinate]() //Array of tuples(Double)
            var tuple: (Double, Double) = (0, 0)
            var easting: Bool = false
            var northing: Bool = false
            var eastingString: String = ""
            var northingString: String = ""
            var openBracket = 0
            let tempString = getSubstringFromIndex(wktGeometry , character: "G") //string to parse
            //print(tempString)
            for char in tempString.characters {
                if char == "(" {
                    openBracket++
                    if openBracket == 2 {
                        easting = true
                    }
                } else if char == ")" {
                    openBracket--
                    if openBracket == 1 {
                        tuple.1 = Double(northingString)!
                       tupleArray.append(tuple)
                        array.append(tupleArray)
                        tupleArray = [Coordinate]()
                        eastingString = ""
                        northingString = ""
                    }
                } else if char == "," {
                    if openBracket == 2 {
                        tuple.1 = Double(northingString)!
                        tupleArray.append(tuple)
                        eastingString = ""
                        northingString = ""
                    }
                } else if char == " " {
                    if easting == true {
                        tuple.0 = Double(eastingString)!
                        easting = false
                        northing = true
                    } else {
                        northing = false
                        easting = true
                    }
                } else {
                    if easting {
                        eastingString += String(char)
                    } else if northing {
                        northingString += String(char)
                    }
                } //end if
            } //end for
            //print(array)
        }
    }
    
    private func getDate(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd-MM-yyyy hh:mm a"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 13 * 3600)
        //print(date)
        return formatter.stringFromDate(date)

    }
    
    /**
     Gets a substring from start of string to first occurence of character
     - Parameter string:   The original string.
     - Parameter character: The  character to find.
     - Returns: a new substring
     */
    private func getSubstringToIndex(string: String, character: Character) -> String {
        if let idx = string.characters.indexOf(character) {
            let pos = string.startIndex.distanceTo(idx)
            let index = string.startIndex.advancedBy(pos)
            return string.substringToIndex(index)
        } else {
            return ""
        }
        
    }
    
    /**
     Gets a substring from first occurence of character to the end of string
     - Parameter string:   The original string.
     - Parameter character: The  character to find.
     - Returns: a new substring
     */
    private func getSubstringFromIndex(string: String, character: Character) -> String {
        if let idx = string.characters.indexOf(character) {
            let pos = string.startIndex.distanceTo(idx)
            let index = string.startIndex.advancedBy(pos + 1)
            return string.substringFromIndex(index)
        }
        else {
            return ""
        }
    }
    
}