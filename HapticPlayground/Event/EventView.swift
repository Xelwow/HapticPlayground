//
//  EventView.swift
//  HapticPlayground
//
//  Created by Nikita Komarov on 24.02.2025.
//

import Foundation
import SwiftUI

struct EventView: View {
    @Binding
    var event: HapticEvent
    @State
    var sheetHeight: CGFloat = .zero
    var tryHapticAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            tryButton
            sliderValueView(label: "Relative time:", value: $event.relativeTime, range: 0...2)
            if case .continuos = event.type {
                sliderValueView(label: "Duration:", value: durationBinding, range: 0...2)
            }
            sliderValueView(label: "Intensity:", value: $event.intensity, range: 0...1)
            sliderValueView(label: "Sharpness:", value: $event.sharpness, range: 0...1)
            Picker("", selection: $event.type) {
                Text("Transient").tag(HapticEvent.EventType.transient)
                Text("Continuos").tag(HapticEvent.EventType.continuos(duration: 0.1))
            }.pickerStyle(.segmented)
        }
        .presentationDragIndicator(.visible)
        .padding(.horizontal, 15)
        .overlay {
            GeometryReader { geometry in
                Color.clear.preference(key: InnerHeightPreferenceKey.self, value: geometry.size.height)
            }
        }
        .onPreferenceChange(InnerHeightPreferenceKey.self) { newHeight in
            sheetHeight = newHeight
        }
        .presentationDetents([.height(sheetHeight)])
    }
    
    private var tryButton: some View {
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
            .onTapGesture(perform: tryHapticAction)
        }
        .padding(.top, 15)
    }
    
    private func sliderValueView<BindingValue: BinaryFloatingPoint & LosslessStringConvertible>(
        label: String,
        value: Binding<BindingValue>,
        range: ClosedRange<BindingValue>
    ) -> some View where BindingValue.Stride: BinaryFloatingPoint {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        
        return VStack(alignment: .leading) {
            HStack {
                Text(label)
                TextField(label, value: value, formatter: formatter)
                    .keyboardType(.numbersAndPunctuation)
                    .foregroundStyle(Color.blue)
            }
            Slider(value: value, in: range)
        }
    }
    
    private var durationBinding: Binding<TimeInterval> {
        Binding(get: {
            switch event.type {
            case .transient:
                0
            case let .continuos(duration):
                duration
            }
        }, set: {
            if case .continuos = event.type {
                event.type = .continuos(duration: $0)
            }
        })
    }
}

#Preview {
    HapticView(
        haptic: exampleHaptic,
        selectedEvent: 1
    )
}

fileprivate struct InnerHeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
