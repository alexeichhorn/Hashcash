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
    public var datePrecision: Stamp.DatePrecision = .days
    
    
    public func mint(resource: String, ext: String = "", date: Date = Date()) -> Stamp {
        
        let timestamp = datePrecision.dateFormatter.string(from: date)
        let salt = generateSalt()
        let challenge = "\(ver):\(bits):\(timestamp):\(resource):\(ext):\(salt)"
        
        var counter = 0
        
        while true {
            let encodedCounter = String(format: "%2X", counter).trimmingCharacters(in: .whitespaces)
            let stamp = challenge + ":" + encodedCounter
            
            let digest = SHA256.hash(data: stamp.data(using: .utf8)!)
            
            if digest.isZeroPrefixed(withBits: bits) {
                return Stamp(bits: bits, resource: resource, ext: ext, salt: salt, counter: encodedCounter, date: date, datePrecision: datePrecision, encodedValue: stamp)
            }
            
            counter += 1
        }
    }
    
    
    public func check(stamp: Stamp, resource: String? = nil, timeTolerance: TimeInterval? = nil, currentDate: Date = Date()) -> Bool {
        
        if let resource = resource, resource != stamp.resource {
            return false
        }
        
        if bits > stamp.bits {
            return false // computational effort to low
        }
        
        let digest = SHA256.hash(data: stamp.encodedValue.data(using: .utf8)!)
        
        guard digest.isZeroPrefixed(withBits: stamp.bits) else {
            return false // work not proven
        }
        
        let timeTolerance = timeTolerance ?? stamp.datePrecision.defaultTimeTolerance
        let notBeforeDate = currentDate - timeTolerance
        let notAfterDate = currentDate + timeTolerance
        
        guard stamp.date >= notBeforeDate && stamp.date <= notAfterDate else {
            return false // not in time range
        }
        
        return true
    }
    
    
    
    private func generateSalt() -> String {
        let charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+/="
        return String((0..<saltLength).map { _ in charset.randomElement()! })
    }
    
}
