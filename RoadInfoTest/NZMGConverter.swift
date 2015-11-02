//
//  NZMGConverter.swift
//  RoadInfoTest
//
//  Created by Matt Wynyard on 28/10/15.
//  Copyright © 2015 Niobium. All rights reserved.
//

import Foundation
import Darwin

class NZMGConverter {
    
    private let easting: Double!
    private let northing: Double!
    private let coordArray: [[Coordinate]]!
    private var z: Complex! = nil
    private let N0: Double  = 6023150; //false Northing
    private let E0: Double  = 2510000; //false Easting
    
    private let NZMGLatOrigin: Double  = -41;
    private let NZMGLongOrigin: Double  = 173;
    
    private let c: [Complex]  = [Complex(real: 1.3231270439, imag: 0.0), Complex(real: -0.577245789, imag: -0.007809598), Complex(real: 0.508307513, imag: -0.112208952), Complex(real: -0.15094762, imag: 0.18200602), Complex(real: 1.01418179, imag: 1.64497696), Complex(real: 1.9660549, imag: 2.5127645)]
    private let b: [Complex] = [Complex(real: 0.7557853228, imag: 0.0), Complex(real: 0.249204646, imag: 0.003371507), Complex(real: -0.001541739, imag: 0.04105856), Complex(real: -0.10162907, imag: 0.01727609), Complex(real: -0.26623489, imag: -0.36249218), Complex(real: -0.6870983, imag: -1.1651967)]
    private let d: [Double] = [1.5627014243, 0.5185406398, -0.0333309800, -0.1052906000, -0.0368594000, 0.0073170000, 0.0122000000, 0.0039400000, -0.0013000000]
    
    //Datum info.
    private let NZGD1949f: Double  = 0.003367003;
    //Double NZGD1949InverseFlattening = 297;
    private let NZGD1949e2: Double = (2 * 0.003367003) - pow(0.003367003, 2);
    private let NZGD1949a: Double  = 6378388; //Semi-major axis
    
    private let NZGD2000a: Double  = 6378137;
    private let NZGD2000f: Double  = 0.003352811;
    //Double NZGD2000InverseFlattening = 298.2572221;
    private let NZGD2000e2: Double  = (2 * 0.003352811) - pow(0.003352811, 2);
    
    //NZ1949 -> NZGD2000 differences
    private let differenceX: Double = 54.4;
    private let differenceY: Double  = -20.1;
    private let differenceZ: Double = 183.1;
    
    init(easting: Double, northing: Double) {
        
        self.easting = easting
        self.northing = northing
        self.coordArray = nil
    }
    
    init(array: [[Coordinate]]) {
        
        self.coordArray = array
        self.easting = nil
        self.northing = nil
    }
    
    func nzmgToNZGD1949() -> (latitude: Double, longitude: Double) {
        
        z = Complex(real: (northing - N0) / NZGD1949a, imag: (easting - E0) / NZGD1949a)
        let theta0 = thetaZero(z)
        let theta: Complex = thetaSuccessive(theta0, i: 0)
        let latlong = calcLatLong(theta)
        //print(latlong)
        return datumShift(latlong.0, longitude: latlong.1)
    }
    
    func thetaZero(z: Complex) -> Complex {
        var theta0 = Complex()
        for var i = 0; i < c.count; i++ {
            theta0 = theta0 + (c[i] * (z ^ (i + 1)))
            //print(theta0)
        }
        return theta0
    }
    
    private func thetaSuccessive(theta0: Complex, i: Int) -> Complex {
        var numerator: Complex = Complex()
        var denominator: Complex = Complex()
        for var n = 1; n < b.count; n++ {
            numerator = numerator + (Complex(real: n) * b[n] * (theta0 ^ (n + 1)))
        }
        numerator = z + numerator
        for var n = 0; n < b.count; n++ {
            denominator = denominator + (Complex(real: n + 1) * b[n] * (theta0 ^ n))
        }
        let theta = numerator / denominator
        if i == 2 {
            return theta
        } else {
            return thetaSuccessive(theta, i: i + 1)
        }
    }
    
    private func calcLatLong(theta: Complex) -> (latitude: Double, longitude: Double) {
        
        let deltaPsi = theta.real
        let deltaLambda = theta.imag
        var deltaPhi: Double = 0
        for var n = 0; n < d.count; n++ {
            deltaPhi += d[n] * pow(deltaPsi, Double(n + 1))
        }
        let lat: Double = NZMGLatOrigin + ((pow(10, 5) / 3600) * deltaPhi)
        let long: Double = NZMGLongOrigin + ((180 / M_PI) * deltaLambda)
        return (latitude: lat, longitude: long)
    }
    
    private func datumShift(latitude: Double, longitude: Double) -> (latitude: Double, longitude: Double) {
        
        let latInRadians = latitude * (M_PI / 180)
        let lngInRadians = longitude * (M_PI / 180)
        
        let v = NZGD1949a / (sqrt(1 - (NZGD1949e2 * pow(sin(latInRadians), 2))))
        var x_cart = v * cos(latInRadians) * cos(lngInRadians)
        var y_cart = v * cos(latInRadians) * sin(lngInRadians)
        var z_cart = (v * (1 - NZGD1949e2)) * sin(latInRadians)
        x_cart += differenceX
        y_cart += differenceY
        z_cart += differenceZ
        
        let p = sqrt(pow(x_cart, 2) + pow(y_cart, 2))
        let r = sqrt(pow(p, 2) + pow(z_cart, 2))
        let mu = atan((z_cart / p) * ((1 - NZGD2000f) + ((NZGD2000e2 * NZGD2000a) / r)))
        let num = (z_cart * (1 - NZGD2000f)) + (NZGD2000e2 * NZGD2000a * pow(sin(mu), 3))
        let denom = (1 - NZGD2000f) * (p - (NZGD2000e2 * NZGD2000a * pow(cos(mu), 3)))
        
        var lat = atan(num / denom)
        var long = atan(y_cart / x_cart)

        lat = (180 / M_PI) * lat
        long = 180 + (180 / M_PI) * long
        
        return (latitude: lat, longitude: long)
        
    }
    
    
}

