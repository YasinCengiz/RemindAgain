//
//  DateFormatter+Ext.swift
//  DateFormatter+Ext
//
//  Created by Yasin Cengiz on 21/8/21.
//

import Foundation


extension DateFormatter {
    
    static let fullDayName: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "eeee"
        
        return formatter
    }()
    
    static let shortDayName: DateFormatter = {
        let shortenedFormatter = DateFormatter()
        shortenedFormatter.locale = .current
        shortenedFormatter.dateFormat = "E"
        
        return shortenedFormatter
    }()
    
}


