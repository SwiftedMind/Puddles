/*
 See LICENSE folder for this sample’s licensing information.
 */

import Foundation
import IdentifiedCollections

public struct History: Identifiable, Codable, Equatable, Hashable, Sendable {
    public var id: UUID
    public var date: Date
    public var attendees: IdentifiedArrayOf<DailyScrum.Attendee>
    public var lengthInMinutes: Int
    public var transcript: String?

    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        attendees: IdentifiedArrayOf<DailyScrum.Attendee>,
        lengthInMinutes: Int = 5,
        transcript: String? = nil
    ) {
        self.id = id
        self.date = date
        self.attendees = attendees
        self.lengthInMinutes = lengthInMinutes
        self.transcript = transcript
    }
}

public extension History {
    static var mock: Self {
        History(
            attendees: [
                DailyScrum.Attendee(name: "Jon"),
                DailyScrum.Attendee(name: "Darla"),
                DailyScrum.Attendee(name: "Luis")
            ],
            lengthInMinutes: 10,
            transcript: "Darla, would you like to start today? Sure, yesterday I reviewed Luis' PR and met with the design team to finalize the UI..."
        )
    }
}
