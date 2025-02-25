//
//  Haptic.swift
//  HapticPlayground
//
//  Created by Nikita Komarov on 24.02.2025.
//

struct Haptic {
  var events: [HapticEvent]
}

var exampleHaptic = Haptic(events:[
    HapticEvent(
        intensity: 0.4,
        sharpness: 0.2,
        relativeTime: 0,
        type: .transient
    ),
    HapticEvent(
        intensity: 0.2,
        sharpness: 0.3,
        relativeTime: 0.3,
        type: .continuos(duration: 0.2)
    ),
    HapticEvent(
        intensity: 0.2,
        sharpness: 0.1,
        relativeTime: 0.15,
        type: .transient
    )
])
