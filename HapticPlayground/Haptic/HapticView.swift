//
//  HapticView.swift
//  HapticPlayground
//
//  Created by Nikita Komarov on 24.02.2025.
//

import SwiftUI
import Charts
import CoreHaptics

struct HapticView: View {
  @State
  var haptic: Haptic
  @State
  var selectedEvent: Int?

  @State
  var hapticEngine: CHHapticEngine?

  var body: some View {
    ZStack {
      VStack {
        chart
        listOfEvents
        tryButton
      }
    }.onAppear {
      prepareHaptics()
    }
  }

  var chart: some View {
    Chart {
      ForEach(haptic.events) { event in
        chartContent(event: event)
      }
    }
    .frame(height: 200)
    .padding(.horizontal, 30)
  }

  var listOfEvents: some View {
    List(selection: $selectedEvent) {
      ForEach($haptic.events) { event in
        listRow(event: event.wrappedValue)
          .background { Color.clear }
          .onTapGesture {
            selectedEvent = haptic.events.firstIndex(where: {
              $0.id == event.id
            })
          }
      }
      .onDelete { indexSet in
        haptic.events.remove(atOffsets: indexSet)
      }
      Button {
        haptic.events.append(.defaultTransient)
        selectedEvent = haptic.events.count - 1
      } label: {
        Text("Add event")
      }
    }.sheet(item: $selectedEvent) { event in
      EventView(event: $haptic.events[event], tryHapticAction: {
        playHaptic(haptic)
      })
    }
  }

  var tryButton: some View {
    VStack(alignment: .trailing) {
      Spacer()
      HStack {
        Spacer()
        ZStack {
          RoundedRectangle(cornerRadius: 15.0)
            .aspectRatio(1.0, contentMode: .fit)
            .foregroundStyle(Color.gray.opacity(0.3))
            .frame(width: 60, height: 60)
          Text("Try")
            .foregroundStyle(Color.blue)
        }
        .onTapGesture {
          playHaptic(haptic)
        }
        .padding(20)
      }
    }
  }

  @ChartContentBuilder
  func chartContent(event: HapticEvent) -> some ChartContent {
    let sortedLines = [
      (type: "Intensity", value: event.intensity, color: Color.blue),
      (type: "Sharpness", value: event.sharpness, color: Color.orange),
    ]

    switch event.type {
    case .transient:
      ForEach(sortedLines.indices) { index in
        let (type, value, color) = sortedLines[index]
        BarMark(
          x: .value("Time", event.relativeTime),
          y: .value(type, value),
          width: 6
        )
        .foregroundStyle(color)
      }
    case let .continuos(duration):
      ForEach(sortedLines.indices) { sortedLineIndex in
        let (lineType, lineValue, color) = sortedLines[sortedLineIndex]
        let lineMarks = [
          (type: lineType, time: event.relativeTime, value: 0.0),
          (type: lineType, time: event.relativeTime, value: lineValue),
          (type: lineType, time: event.relativeTime + duration, value: lineValue),
          (type: lineType, time: event.relativeTime + duration, value: 0.0),
        ]
        ForEach(lineMarks.indices) { index in
          let (markType, markTime, markValue) = lineMarks[index]
          LineMark(
            x: .value("Time", markTime),
            y: .value(markType, markValue),
            series: .value("Type", markType)
          )
          .foregroundStyle(color)
        }
      }
    }
  }

  @ViewBuilder
  func listRow(event: HapticEvent) -> some View {
    HStack {
      Text(event.type.string)
    }
  }

  func prepareHaptics() {
      guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
      guard hapticEngine == nil else { return }
      do {
        hapticEngine = try CHHapticEngine()
      } catch {
        print("There was an error creating the engine: \(error.localizedDescription)")
      }
  }

  func playHaptic(_ haptic: Haptic) {
    guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
    guard let hapticEngine else { return }
    do {
      let pattern = try haptic.core()
      let player = try hapticEngine.makePlayer(with: pattern)
      try hapticEngine.start()
      try player.start(atTime: 0)
    } catch {
      print("There was an error creating the player: \(error.localizedDescription)")
    }
  }
}

extension HapticEvent.EventType {
  var string: String {
    switch self {
    case .continuos:
      "continuos"
    case .transient:
      "transient"
    }
  }
}

extension Int: Identifiable {
  public var id: Int { self }
}

#Preview {
    HapticView(haptic: exampleHaptic)
}

