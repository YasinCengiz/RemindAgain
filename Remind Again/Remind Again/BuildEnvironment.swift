//
//  BuildEnvironment.swift
//  CheckLater
//
//  Created by Ilter Cengiz on 5/6/21.
//  Copyright © 2021 Ilter Cengiz. All rights reserved.
//

import Foundation
//#if canImport(UIKit)
import class UIKit.UIDevice
//#endif

enum BuildEnvironment: String, Equatable {
    case debug
    case release
//    case snapshot
}

extension BuildEnvironment {
    
    static let current: BuildEnvironment = {
        #if DEBUG
//        if CommandLine.arguments.contains("-snapshot_mode") {
//            return .snapshot
//        } else {
            return .debug
//        }
        #else
        return .release
        #endif
    }()
    
    var isTestFlight: Bool {
        Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    }

    var isAppExtension: Bool {
        Bundle.main.bundlePath.hasSuffix(".appex")
    }

    var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    }

    var systemVersion: String {
//        #if os(iOS)
        UIDevice.current.systemName + " " + UIDevice.current.systemVersion
//        #else
//        "macOS 12"
//        #endif
    }
}
