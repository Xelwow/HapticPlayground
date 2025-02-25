//
//  Haptic.swift
//  HapticPlayground
//
//  Created by Nikita Komarov on 24.02.2025.
//

import Foundation

struct HapticPattern {
  var events: [HapticEvent]
  var curves: [HapticCurve]
}

extension HapticPattern {
  var exportString: String {
    """
    HapticPattern(
      events: [
        \(events.map(\.exportString).joined(separator: ",\n"))
      ],
      curves: [
        \(curves.map(\.exportString).joined(separator: ",\n"))
      ]
    )
    """
  }
}

var exampleHaptic = HapticPattern(
  events:[
    HapticEvent(
      intensity: 0.5,
      sharpness: 0.5,
      relativeTime: 0,
      type: .continuous(duration: 0.15)
    ),
    HapticEvent(
      intensity: 0.6,
      sharpness: 0.4,
      relativeTime: 0.2,
      type: .continuous(duration: 0.45)
    )
  ],
  curves: [
    HapticCurve(
      parameterID: .intensity,
      controlPoints: [
        .init(relativeTime: 0, value: 0.5),
        .init(relativeTime: 0.2, value: 0),
        .init(relativeTime: 0.25, value: 0.25),
        .init(relativeTime: 0.35, value: 0.4),
        .init(relativeTime: 0.45, value: 0.25),
        .init(relativeTime: 0.65, value: 0),
      ],
      time: 0
    ),
    HapticCurve(
      parameterID: .sharpness,
      controlPoints: [
        .init(relativeTime: 0, value: 0.3),
        .init(relativeTime: 0.2, value: 0.4),
        .init(relativeTime: 0.4, value: 0.0),
      ],
      time: 0
    ),
  ]
)
