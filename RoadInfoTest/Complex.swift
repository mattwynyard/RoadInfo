//
//  Complex.swift
//  prog3.3
//
//  Created by Matthew Wynyard on 7/20/15.
//  Copyright (c) 2015 Matthew Wynyard. All rights reserved.
//

import Foundation

class Complex: CustomStringConvertible  {
    
    //Stored properties
    private var _real: Double;
    private var _imag: Double;
    
    //Computed properties
    var magnitude: Double {
        return (self.real * self.real) + (self.imag * self.imag)
    }
    
    var description: String {
        if self.imag == 0 {
            return "\(self.real)"
        } else if self.real == 0 {
            return "\(self.imag)i"
        } else if self.imag < 0 {
            return "\(self.real) - \(-self.imag)i"
        } else {
            return "\(self.real) + \(self.imag)i"
        }
    }
    
    //Initialisers
    init(real: Double, imag: Double = 0) {
        self._real = real
        self._imag = imag
    }
    
    init(real: Int, imag: Int = 0) {
        self._real = Double(real)
        self._imag = Double(imag)
    }
    
    convenience init() {
        self.init(real: 0)
    }
    
    var real: Double {
        get {
            return _real
        }
    }
    
    var imag: Double {
        get {
            return _imag
        }
    }
    
    //Methods
    private static func add(c1: Complex, to c2: Complex) -> Complex {
        let xr = c1.real + c2.real
        let xi = c1.imag + c2.imag
        return Complex(real: xr, imag: xi)
    }

    private static func subtract(c1: Complex, from c2: Complex) -> Complex {
        let xr = c1.real - c2.real
        let xi = c1.imag - c2.imag
        return Complex(real: xr, imag: xi)
    }

    private static func multiply(c1: Complex, by c2: Complex) -> Complex {
        let xr = (c1.real * c2.real) - (c1.imag * c2.imag)
        let xi = (c1.real * c2.imag) + (c1.imag * c2.real)
        return Complex(real: xr, imag: xi)
    }
    
    private static func divide(c1: Complex, by c2: Complex) -> Complex {
        let xr = (c1.real * c2.real + c1.imag * c2.imag) / c2.magnitude
        let xi = ((c1.imag * c2.real) - (c1.real * c2.imag)) / c2.magnitude
        return Complex(real: xr, imag: xi)
    }
    
    private static func power(c1: Complex, x: Int) -> Complex {
        if x == 0 {return Complex(real: 1)}
        return c1 * power(c1, x: x - 1)
    }
    
    /* returns a deepy copy of object */
    func copy() -> Complex {
        return Complex(real: self.real, imag: self.imag)
    }
}

func +(c1: Complex, c2: Complex) -> Complex {
    return Complex.add(c1, to: c2)
}

func -(c1: Complex, c2: Complex) -> Complex {
    return Complex.subtract(c1, from: c2)
}

func *(c1: Complex, c2: Complex) -> Complex {
    return Complex.multiply(c1, by: c2)
}

func /(c1: Complex, c2: Complex) -> Complex {
    return Complex.divide(c1, by: c2)
}

func +(c1: Complex, x: Double) -> Complex {
    return Complex.add(c1, to: Complex(real: x))
}

func -(c1: Complex, x: Double) -> Complex {
    return Complex.subtract(c1, from: Complex(real: x))
}

func *(c1: Complex, x: Double) -> Complex {
    return Complex.multiply(c1, by: Complex(real: x))
}

func *(c1: Complex, x: Int) -> Complex {
    return Complex.multiply(c1, by: Complex(real: Double(x)))
}

func /(c1: Complex, x: Double) -> Complex {
    return Complex.divide(c1, by: Complex(real: x))
}

func ^(c1: Complex, x: Int) -> Complex {
    return Complex.power(c1, x: x)
}

func +=(c1: Complex, c2: Complex) -> Complex {
    return Complex.add(c1, to: c2)
}