//
//  HapticEvent.swift
//  HapticPlayground
//
//  Created by Nikita Komarov on 24.02.2025.
//

import Foundation

struct HapticEvent: Identifiable, Hashable {
  // Conforms Hashable to be represented in a Picker
  enum EventType: Hashable {
    case transient
    case continuous(duration: TimeInterval)

    func hash(into hasher: inout Hasher) {
      switch self {
      case .transient:
        hasher.combine("transient")
      case .continuous:
        hasher.combine("continuous")
      }
    }
  }

  private let uuid = UUID()
  var id: UUID { uuid }

  var intensity: Float
  var sharpness: Float
  var relativeTime: TimeInterval
  var type: EventType

  func hash(into hasher: inout Hasher) {
    hasher.combine(uuid)
  }

  static var defaultTransient: HapticEvent {
    HapticEvent(
      intensity: 0.6,
      sharpness: 0.6,
      relativeTime: 0.0,
      type: .transient
    )
  }
}

extension HapticEvent {
  var exportString: String {
    """
    HapticEvent(
      intensity: \(intensity),
      sharpness: \(sharpness),
      relativeTime: \(relativeTime),
      type: .\(type)
    )
    """
  }
}
