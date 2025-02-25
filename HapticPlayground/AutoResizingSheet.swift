//
//  AutoResizingSheet.swift
//  HapticPlayground
//
//  Created by Alexey Sherstnev on 25.02.2025.
//

import SwiftUI

extension View {
  func autoResizingSheet<Item: Identifiable, SheetContent: View>(
    item: Binding<Item?>,
    sheetContent: @escaping (Item) -> SheetContent
  ) -> some View {
    modifier(AutoResizingSheet(item: item, sheetContent: sheetContent))
  }
}

private struct AutoResizingSheet<Item: Identifiable, SheetContent: View>: ViewModifier {
  @Binding
  var item: Item?
  var sheetContent: (Item) -> SheetContent
  @State
  private var sheetHeight: CGFloat = 0

  func body(content: Content) -> some View {
    content
      .sheet(item: $item) {
        sheetContent($0)
          .presentationDragIndicator(.visible)
          .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.height
          } action: { height in
            sheetHeight = height
          }
          .presentationDetents([.height(sheetHeight)])
      }
  }
}

