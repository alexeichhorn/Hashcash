//
//  Hashcash.swift
//  
//
//  Created by Alexander Eichhorn on 24.03.21.
//

import Foundation
import CryptoKit

public struct Hashcash {
    
    public let ver = "1"
    public var bits: UInt = 20
    public var saltLength: UInt = 16
    public var datePrecision: DatePrecision = .days
    
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
    }
    
    
    public func mint(resource: String, ext: String = "", date: Date = Date()) -> String {
        
        let timestamp = datePrecision.dateFormatter.string(from: date)
        let salt = generateSalt()
        let challenge = "\(ver):\(bits):\(timestamp):\(resource):\(ext):\(salt)"
        
        var counter = 0
        
        while true {
            let encodedCounter = String(format: "%2X", counter).trimmingCharacters(in: .whitespaces)
            let stamp = challenge + ":" + encodedCounter
            
            let digest = SHA256.hash(data: stamp.data(using: .utf8)!)
            
            if digest.isZeroPrefixed(withBits: bits) {
                return stamp
            }
            
            counter += 1
        }
    }
    
    private func generateSalt() -> String {
        let charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+/="
        return String((0..<saltLength).map { _ in charset.randomElement()! })
    }
    
}
