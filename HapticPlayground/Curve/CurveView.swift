//
//  CurveView.swift
//  HapticPlayground
//
//  Created by Alexey Sherstnev on 25.02.2025.
//

import SwiftUI
import CoreHaptics

struct CurveView: View {
  @Binding
  var curve: HapticCurve
  var tryHaptic: () -> Void

  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        topButton(title: "Try", action: tryHaptic)
        topButton(title: "+ Control Point") {
          curve.controlPoints.insert(
            HapticCurve.ControlPoint(relativeTime: 0, value: 0),
            at: 0
          )
        }
      }
      parameterPicker

      sliderValueView(
        label: "Start time",
        value: $curve.time,
        range: 0...2
      ).padding()
        .background(.primary.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 10))

      EnumeratedForEach(curve.controlPoints) { index, _ in
        controlPointView(at: index)
      }
    }
    .padding()
    .onChange(of: curve.controlPoints) { _ in
      curve.controlPoints.sort { $0.relativeTime < $1.relativeTime }
    }
  }

  private func controlPointView(at index: Int) -> some View {
    HStack {
      textWithField(
        title: "Time",
        value: $curve.controlPoints[index].relativeTime
      )
      textWithField(
        title: "Value",
        value: $curve.controlPoints[index].value
      )
      let isRemovable = curve.controlPoints.count > 2
      Button {
        curve.controlPoints.remove(at: index)
      } label: {
        Image(systemName: "trash")
          .font(.title3)
          .padding(10)
      }.opacity(isRemovable ? 1 : 0.3)
        .allowsHitTesting(isRemovable)
    }.padding(.horizontal)
      .background(.primary.opacity(0.05))
      .clipShape(RoundedRectangle(cornerRadius: 10))
  }

  private func textWithField<BindingValue: BinaryFloatingPoint & LosslessStringConvertible>(
    title: String,
    value: Binding<BindingValue>
  ) -> some View where BindingValue.Stride: BinaryFloatingPoint  {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 2

    return HStack {
      Text(title)
      TextField(title, value: value, formatter: formatter)
        .keyboardType(.numbersAndPunctuation)
        .foregroundStyle(Color.blue)
    }
  }

  private var parameterPicker: some View {
    Picker("Parameter", selection: $curve.parameterID) {
      ForEach(HapticCurve.ParameterID.allCases, id: \.self) { parameter in
        Text(parameter.description)
      }
    }
  }

  private func topButton(title: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Text(title)
        .padding()
        .background(.primary.opacity(0.05))
        .cornerRadius(15)
    }
  }
}

#Preview {
  HapticView(
    haptic: exampleHaptic,
    selectedCurve: 1
  )
}

struct EnumeratedForEach<Value: Identifiable, Content: View>: View {
  var values: [Value]
  var content: (Int, Value) -> Content

  init(
    _ values: [Value],
    @ViewBuilder content: @escaping (Int, Value) -> Content
  ) {
    self.values = values
    self.content = content
  }

  var body: some View {
    ForEach(Array(values.enumerated()), id: \.element.id, content: content)
  }
}
