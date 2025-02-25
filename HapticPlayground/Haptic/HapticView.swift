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
  var haptic: HapticPattern
  @State
  var selectedEvent: Int?
  @State
  var selectedCurve: Int?

  @State
  var hapticEngine: CHHapticEngine?
  
  var body: some View {
    ZStack(alignment: .bottom) {
      VStack {
        chart
        listOfEvents
      }
      HStack {
        exportButton
        Spacer()
        tryButton
      }.padding(20)
    }.onAppear {
      prepareHaptics()
    }.autoResizingSheet(item: $selectedEvent) { event in
      EventView(event: $haptic.events[event], tryHapticAction: {
        playHaptic(haptic)
      })
    }
    .autoResizingSheet(item: $selectedCurve) { curve in
      CurveView(curve: $haptic.curves[curve], tryHaptic: {
        playHaptic(haptic)
      })
    }
  }
  
  var chart: some View {
    Chart {
      ForEach(haptic.events) { event in
        chartContent(event: event)
      }
      ForEach(haptic.curves) { curve in
        chartContent(curve: curve)
      }
    }
    .frame(height: 200)
    .padding(.horizontal, 30)
  }
  
  var listOfEvents: some View {
    List(selection: $selectedEvent) {
      Section("events") {
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
          Text("+ event")
        }
      }

      Section("curves") {
        ForEach($haptic.curves) { curve in
          Button(curve.parameterID.wrappedValue.description) {
            selectedCurve = haptic.curves.firstIndex(where: {
              $0.id == curve.id
            })
          }.foregroundStyle(curve.parameterID.wrappedValue.color)
        }
        .onDelete { indexSet in
          haptic.curves.remove(atOffsets: indexSet)
        }
        Button("+ curve") {
          haptic.curves.append(.blank)
          selectedCurve = haptic.curves.count - 1
        }
      }
    }
  }

  var exportButton: some View {
    Button {
      UIPasteboard.general.string = haptic.exportString
      UINotificationFeedbackGenerator().notificationOccurred(.success)
    } label: {
      Text("Export")
        .padding()
        .background(.primary.opacity(0.1))
        .background(.regularMaterial)
        .cornerRadius(15)
    }
  }

  var tryButton: some View {
    Button {
      playHaptic(haptic)
    } label: {
      Text("Try")
        .padding()
        .background(.primary.opacity(0.1))
        .background(.regularMaterial)
        .cornerRadius(15)
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
    case let .continuous(duration):
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

  @ChartContentBuilder
  func chartContent(curve: HapticCurve) -> some ChartContent {
    // draw lines between control points starting from relative time
    let sortedPoints = curve.controlPoints
      .sorted { $0.relativeTime < $1.relativeTime }

    let points = sortedPoints.map { point in
      LineMark(
        x: .value("Time", point.relativeTime + curve.time),
        y: .value(curve.parameterID.description, point.value),
        series: .value("Type", curve.parameterID.description)
      ).lineStyle(.init(lineWidth: 3, dash: [5], dashPhase: 10))
    }

    ForEach(points.indices) { index in
      points[index]
        .foregroundStyle(curve.parameterID.color)
    }
  }

  @ViewBuilder
  func listRow(event: HapticEvent) -> some View {
    Text(event.type.string)
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

  func playHaptic(_ haptic: HapticPattern) {
    guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
    guard let hapticEngine else { return }
    do {
      let pattern = try CHHapticPattern(from: haptic)
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
    case .continuous:
      "continuous"
    case .transient:
      "transient"
    }
  }
}

extension Int: @retroactive Identifiable {
  public var id: Int { self }
}

#Preview {
    HapticView(haptic: exampleHaptic)
}

