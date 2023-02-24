import Foundation
import OSLog

fileprivate(set) var logger: Logger = .init(OSLog.disabled)

public struct Puddles {

    /// Configures and enables a logger that prints out log messages for events inside Puddles.
    ///
    /// This can be useful for debugging.
    /// - Parameter subsystem: The subsystem. If none is provided, the bundle's identifier will try to be used and if it is specifically set to `nil`, then `Puddles` will be used.
    public static func configureLog(inSubsystem subsystem: String? = Bundle.main.bundleIdentifier) {
        logger = .init(subsystem: subsystem ?? "Puddles", category: "Puddles")
    }
}

