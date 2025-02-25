//
//  Haptic+CoreHaptic.swift
//  HapticPlayground
//
//  Created by Nikita Komarov on 24.02.2025.
//

import CoreHaptics

extension CHHapticPattern {
  convenience init(from pattern: HapticPattern) throws {
    try self.init(
      events: pattern.events.map(CHHapticEvent.from(event:)),
      parameterCurves: pattern.curves.map(CHHapticParameterCurve.from(curve:))
    )
  }
}

extension CHHapticEvent {
  fileprivate static func from(event: HapticEvent) -> CHHapticEvent {
    switch event.type {
    case .transient:
      CHHapticEvent(
        eventType: .hapticTransient,
        parameters: [
          CHHapticEventParameter(
            parameterID: .hapticIntensity,
            value: event.intensity
          ),
          CHHapticEventParameter(
            parameterID: .hapticSharpness,
            value: event.sharpness
          ),
        ],
        relativeTime: event.relativeTime
      )
    case let .continuous(duration):
      CHHapticEvent(
        eventType: .hapticContinuous,
        parameters: [
          CHHapticEventParameter(
            parameterID: .hapticIntensity,
            value: event.intensity
          ),
          CHHapticEventParameter(
            parameterID: .hapticSharpness,
            value: event.sharpness
          ),
        ],
        relativeTime: event.relativeTime,
        duration: duration
      )
    }
  }
}

extension CHHapticParameterCurve {
  fileprivate static func from(curve: HapticCurve) -> CHHapticParameterCurve {
    CHHapticParameterCurve(
      parameterID: CHHapticDynamicParameter.ID.from(paramID: curve.parameterID),
      controlPoints: curve.controlPoints.map(CHHapticParameterCurve.ControlPoint.init),
      relativeTime: curve.time
    )
  }
}

extension CHHapticParameterCurve.ControlPoint {
  fileprivate convenience init(point: HapticCurve.ControlPoint) {
    self.init(
      relativeTime: point.relativeTime,
      value: Float(point.value)
    )
  }
}

extension CHHapticDynamicParameter.ID {
  fileprivate static func from(paramID: HapticCurve.ParameterID) -> CHHapticDynamicParameter.ID {
    switch paramID {
    case .intensity: .hapticIntensityControl
    case .sharpness: .hapticSharpnessControl
    case .attackTime: .hapticAttackTimeControl
    case .decayTime: .hapticDecayTimeControl
    case .releaseTime: .hapticReleaseTimeControl
    }
  }
}
