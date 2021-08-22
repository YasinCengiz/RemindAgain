//
//  Alert.swift
//  Alertz
//
//  Created by Mazyad Alabduljaleel on 10/9/15.
//  Copyright © 2015 Mazy. All rights reserved.
//

import Foundation


public struct Alert: Hashable {

    // MARK: - properties
    
    public let title: String
    public let registryID: UUID
    public let dateComponents: DateComponents

    public let sound: String?
    public let repeats: Bool
    
    // MARK: - Init & Dealloc
    
    public init(title: String,
                
                registryID: UUID,
                dateComponents: DateComponents,
                timezone: TimeZone? = nil,
                sound: String? = nil,
                repeats: Bool = false) {

        self.title = title
        
        self.registryID = registryID
        self.dateComponents = dateComponents
        self.sound = sound
        self.repeats = repeats
    }
}

// CustomDebug

extension Alert: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        
        let prefixItems: [CustomDebugStringConvertible] = [dateComponents]
        let prefix = prefixItems
            .compactMap { $0.debugDescription }
            .joined(separator: " - ")
        
        return "[\(prefix)] \(title): \(sound ?? "nil")"
    }
}
