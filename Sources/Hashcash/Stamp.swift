//
//  Stamp.swift
//  
//
//  Created by Alexander Eichhorn on 24.03.21.
//

import Foundation

public struct Stamp {
    
    public let version: String = "1"
    public let bits: UInt
    public let resource: String
    public let ext: String
    public let salt: String
    public let counter: String
    public let date: Date
    public let datePrecision: DatePrecision
    
    public let encodedValue: String
    
    public enum DatePrecision {
        case days
        case minutes
        case seconds
        
        var dateFormatter: DateFormatter {
            let dateFormatter = DateFormatter()
            switch self {
            case .days: dateFormatter.dateFormat = "yyMMdd"
            case .minutes: dateFormatter.dateFormat = "yyMMddHHmm"
            case .seconds: dateFormatter.dateFormat = "yyMMddHHmmss"
            }
            return dateFormatter
        }
        
        static func precision(of encodedValue: String) -> Self? {
            switch encodedValue.count {
            case 6: return .days
            case 10: return .minutes
            case 12: return .seconds
            default: return nil
            }
        }
        
        var defaultTimeTolerance: TimeInterval {
            switch self {
            case .days: return 48 * 3600
            case .minutes: return 5 * 60
            case .seconds: return 2 * 60
            }
        }
    }
    
    public enum ParseError: Error {
        case incompatibleVersion
        case invalidComponentsCount
        case invalidBits
        case invalidTimestampFormat
    }
    
    /// - parameter encodedValue: expects a value like "1:20:210324:hello::gemqijJM/8VRm6ij:1C2EB1"
    public init(encodedValue: String) throws {
        let components = encodedValue.components(separatedBy: ":")
        
        guard let version = components.first,
              version == "1" else {
            throw ParseError.incompatibleVersion
        }
        
        guard components.count == 7 else {
            throw ParseError.invalidComponentsCount
        }

        guard let bits = UInt(components[1]) else {
            throw ParseError.invalidBits
        }
        self.bits = bits
        
        let timestamp = components[2]
        guard let precision = DatePrecision.precision(of: timestamp),
              let date = precision.dateFormatter.date(from: timestamp) else {
            throw ParseError.invalidTimestampFormat
        }
        self.datePrecision = precision
        self.date = date
        
        self.resource = components[3]
        self.ext = components[4]
        self.salt = components[5]
        self.counter = components[6]
        
        self.encodedValue = encodedValue
    }
    
    
    
    internal init(bits: UInt, resource: String, ext: String, salt: String, counter: String, date: Date, datePrecision: DatePrecision, encodedValue: String) {
        self.bits = bits
        self.resource = resource
        self.ext = ext
        self.salt = salt
        self.counter = counter
        self.date = date
        self.datePrecision = datePrecision
        self.encodedValue = encodedValue
    }
    
}
