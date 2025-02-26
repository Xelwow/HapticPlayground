//
//  HapticCurve.swift
//  HapticPlayground
//
//  Created by Alexey Sherstnev on 25.02.2025.
//

import Foundation
import CoreHaptics
import SwiftUI

struct HapticCurve: Identifiable {
  struct ControlPoint: Identifiable, Equatable {
    let id = UUID()
    var relativeTime: TimeInterval
    var value: Float
  }

  enum ParameterID: CaseIterable {
    case intensity
    case sharpness
    case attackTime
    case decayTime
    case releaseTime
  }

  let id = UUID()
  var parameterID: ParameterID
  var controlPoints: [ControlPoint]
  var time: TimeInterval
}

extension HapticCurve {
  static var blank: HapticCurve {
    HapticCurve(
      parameterID: .intensity,
      controlPoints: [
        .init(relativeTime: 0, value: 1),
        .init(relativeTime: 1, value: 1),
      ],
      time: 0
    )
  }

  var exportString: String {
    """
    HapticCurve(
      parameterID: .\(parameterID),
      controlPoints: [
        \(controlPoints.map { ".init(relativeTime: \($0.relativeTime), value: \($0.value))" }.joined(separator: ",\n        "))
      ],
      time: \(time)
    )
    """
  }
}

extension HapticCurve.ParameterID {
  var description: String {
    switch self {
    case .intensity: "intensity"
    case .sharpness: "sharpness"
    case .attackTime: "attack time"
    case .decayTime: "decay time"
    case .releaseTime: "release time"
    }
  }
}

extension HapticCurve.ParameterID {
  var color: Color {
    switch self {
    case .intensity: .red
    case .sharpness: .blue
    case .attackTime: .green
    case .decayTime: .yellow
    case .releaseTime: .purple
    }
  }
}
