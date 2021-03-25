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
    
    public var algorithm: Algorithm = .sha256
    
    public enum Algorithm {
        case sha256
        case sha1
    }
    
    
    /// - parameter bits: determines difficulty of proof (increment by one, doubles difficulty)
    /// - parameter saltLength: determines length of random salt generated for each stamp
    /// - parameter datePrecision: defines how exact the current date is specified
    /// - parameter algorithm: hashing algorithm used to proof the work (must match on validation part)
    public init(bits: UInt = 20, saltLength: UInt = 16, datePrecision: Stamp.DatePrecision = .days, algorithm: Hashcash.Algorithm = .sha256) {
        self.bits = bits
        self.saltLength = saltLength
        self.datePrecision = datePrecision
        self.algorithm = algorithm
    }
    
    
    /// Mints a new hashcash stamp
    /// - parameter resource: main data you want to proof you have "worked for". It musn't contain any ":" characters
    /// - parameter ext: additional data
    /// - parameter date: custom date the stamp is created at. Default: current date
    public func mint(resource: String, ext: String = "", date: Date = Date()) -> Stamp {
        
        let timestamp = datePrecision.dateFormatter.string(from: date)
        let salt = generateSalt()
        let challenge = "\(ver):\(bits):\(timestamp):\(resource):\(ext):\(salt)"
        
        var counter = 0
        
        while true {
            let encodedCounter = String(format: "%2X", counter).trimmingCharacters(in: .whitespaces)
            let stamp = challenge + ":" + encodedCounter
            
            if isDigestZeroPrefixed(stamp, withBits: bits) {
                return Stamp(bits: bits, resource: resource, ext: ext, salt: salt, counter: encodedCounter, date: date, datePrecision: datePrecision, encodedValue: stamp)
            }
            
            counter += 1
        }
    }
    
    
    /// Checks if given stamp is valid for current Hashcash conditions. It checks if the computational effort (bits) is met, the counter is valid and if it was created within the given time tolerance. Optionally the resource is also compared
    /// - parameter stamp: stamp to check
    /// - parameter resource: resource value to check. If nil, it's not checked
    /// - parameter timeTolerance: time interval from encoded date within the stamp is seen as valid. Defaults to values based on date precision of given stamp (not Hashcash properties)
    /// - parameter currentDate: custom date to compare against. Default: current date
    public func check(stamp: Stamp, resource: String? = nil, timeTolerance: TimeInterval? = nil, currentDate: Date = Date()) -> Bool {
        
        if let resource = resource, resource != stamp.resource {
            return false
        }
        
        if bits > stamp.bits {
            return false // computational effort to low
        }
        
        guard isDigestZeroPrefixed(stamp.encodedValue, withBits: stamp.bits) else {
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
    
    
    private func isDigestZeroPrefixed(_ stamp: String, withBits bits: UInt) -> Bool {
        switch algorithm {
        case .sha256:
            let digest = SHA256.hash(data: stamp.data(using: .utf8)!)
            return digest.isZeroPrefixed(withBits: bits)
            
        case .sha1:
            let digest = Insecure.SHA1.hash(data: stamp.data(using: .utf8)!)
            return digest.isZeroPrefixed(withBits: bits)
        }
    }
    
    
    private func generateSalt() -> String {
        let charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+/="
        return String((0..<saltLength).map { _ in charset.randomElement()! })
    }
    
}
