// Source: https://github.com/SwiftGen/SwiftGen/issues/685#issuecomment-782893242
// Adjusted to better fit needs
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import SwiftUI

// MARK: - Strings

public enum Strings {
  /// Add
  public static let add = LocalizedString(lookupKey: "add")
  /// Cancel
  public static let cancel = LocalizedString(lookupKey: "cancel")
  /// Dismiss
  public static let dismiss = LocalizedString(lookupKey: "dismiss")
  /// Edit
  public static let edit = LocalizedString(lookupKey: "edit")
  /// End
  public static let end = LocalizedString(lookupKey: "end")
  /// Save
  public static let save = LocalizedString(lookupKey: "save")
  public enum EditMeeting {
    public enum AttendeesSection {
      /// Attendees
      public static let title = LocalizedString(lookupKey: "edit-meeting.attendees-section.title")
      public enum AttendeesField {
        /// New Attendee
        public static let placeholder = LocalizedString(lookupKey: "edit-meeting.attendees-section.attendees-field.placeholder")
        public enum SubmitButton {
          /// Add attendee
          public static let accessibilityLabel = LocalizedString(lookupKey: "edit-meeting.attendees-section.attendees-field.submit-button.accessibility-label")
        }
      }
    }
    public enum InfoSection {
      /// Meeting Info
      public static let title = LocalizedString(lookupKey: "edit-meeting.info-section.title")
      public enum LengthSlider {
        /// %@ minutes
        public static func value(_ p1: Any) -> String {
          return Strings.tr("Localizable", "edit-meeting.info-section.length-slider.value", String(describing: p1))
        }
      }
      public enum NameField {
        /// Title
        public static let placeholder = LocalizedString(lookupKey: "edit-meeting.info-section.name-field.placeholder")
      }
      public enum ThemePicker {
        /// Theme
        public static let title = LocalizedString(lookupKey: "edit-meeting.info-section.theme-picker.title")
      }
    }
  }
  public enum Meeting {
    /// Discard Meeting
    public static let discard = LocalizedString(lookupKey: "meeting.discard")
    /// Seconds Elapsed
    public static let elapsedSeconds = LocalizedString(lookupKey: "meeting.elapsed-seconds")
    /// Do you want to end the meeting?
    public static let endDialogMessage = LocalizedString(lookupKey: "meeting.end-dialog-message")
    /// is speaking
    public static let isSpeaking = LocalizedString(lookupKey: "meeting.is-speaking")
    /// Last Speaker
    public static let lastSpeaker = LocalizedString(lookupKey: "meeting.last-speaker")
    /// Seconds Remaining
    public static let remainingSeconds = LocalizedString(lookupKey: "meeting.remaining-seconds")
    /// Save Meeting
    public static let save = LocalizedString(lookupKey: "meeting.save")
    /// Speaker %@ of %@
    public static func speakerXOfY(_ p1: Any, _ p2: Any) -> String {
      return Strings.tr("Localizable", "meeting.speaker-x-of-y", String(describing: p1), String(describing: p2))
    }
  }
  public enum ScrumDetail {
    public enum AttendeesSection {
      /// Attendees
      public static let title = LocalizedString(lookupKey: "scrum-detail.attendees-section.title")
    }
    public enum FooterSection {
      public enum Title {
        /// Scrum Id
        public static let _1 = LocalizedString(lookupKey: "scrum-detail.footer-section.title.1")
        /// Long press to copy
        public static let _2 = LocalizedString(lookupKey: "scrum-detail.footer-section.title.2")
      }
    }
    public enum HistorySection {
      /// No meetings yet
      public static let emptyInfo = LocalizedString(lookupKey: "scrum-detail.history-section.empty-info")
      /// History
      public static let title = LocalizedString(lookupKey: "scrum-detail.history-section.title")
    }
    public enum InfoSection {
      /// Start Meeting
      public static let startButton = LocalizedString(lookupKey: "scrum-detail.info-section.start-button")
      /// Theme
      public static let theme = LocalizedString(lookupKey: "scrum-detail.info-section.theme")
      /// Meeting Info
      public static let title = LocalizedString(lookupKey: "scrum-detail.info-section.title")
      public enum Length {
        /// Length
        public static let title = LocalizedString(lookupKey: "scrum-detail.info-section.length.title")
        /// %@ minutes
        public static func value(_ p1: Any) -> String {
          return Strings.tr("Localizable", "scrum-detail.info-section.length.value", String(describing: p1))
        }
      }
    }
  }
  public enum ScrumList {
    /// Daily Scrums
    public static let title = LocalizedString(lookupKey: "scrum-list.title")
    public enum Item {
      public enum LeadingAction {
        /// Copy Id
        public static let title = LocalizedString(lookupKey: "scrum-list.item.leading-action.title")
      }
    }
  }
}

// MARK: - Implementation Details

extension Strings {
  fileprivate static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

public struct LocalizedString {
    private let lookupKey: String

    init(lookupKey: String) {
        self.lookupKey = lookupKey
    }

    var key: LocalizedStringKey {
        LocalizedStringKey(lookupKey)
    }

    var text: String {
        Strings.tr("Localizable", lookupKey)
    }
}

private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
      return Bundle.module
    #else
      return Bundle(for: BundleToken.self)
    #endif
  }()
}
