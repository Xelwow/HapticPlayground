//
//  Haptic+CoreHaptic.swift
//  HapticPlayground
//
//  Created by Nikita Komarov on 24.02.2025.
//

import CoreHaptics

extension Haptic {
  func core() throws -> CHHapticPattern {
    try CHHapticPattern(
      events: events.map(\.core),
      parameterCurves: []
    )
  }
}

extension HapticEvent {
  var core: CHHapticEvent {
    switch type {
    case .transient:
      CHHapticEvent(
        eventType: .hapticTransient,
        parameters: [
          CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
          CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness),
        ],
        relativeTime: relativeTime
      )
    case let .continuos(duration):
      CHHapticEvent(
        eventType: .hapticContinuous,
        parameters: [
          CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
          CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness),
        ],
        relativeTime: relativeTime,
        duration: duration
      )
    }
  }
}
