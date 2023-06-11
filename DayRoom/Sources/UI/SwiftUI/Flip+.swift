//
//  Flip+.swift
//  DayRoom
//
//  Created by 한상진 on 2023/06/12.
//

import SwiftUI

extension View {
    func flip(opacity: CGFloat) -> some View {
        modifier(FlipOpacity(pct: opacity))
    }
}

struct FlipOpacity: Animatable, ViewModifier {
   var pct: CGFloat = 0
   
   var animatableData: CGFloat {
      get { pct }
      set { pct = newValue }
   }
   
   func body(content: Content) -> some View {
      return content.opacity(Double(pct.rounded()))
   }
}

