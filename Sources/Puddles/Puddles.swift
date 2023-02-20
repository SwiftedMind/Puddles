import SwiftUI

import OSLog

fileprivate(set) var logger: Logger = .init(OSLog.disabled)

public struct Puddles {

    public static func configureLog(inSubsystem subsystem: String? = Bundle.main.bundleIdentifier) {
        logger = .init(subsystem: subsystem ?? "Puddles", category: "Puddles")
    }
}

