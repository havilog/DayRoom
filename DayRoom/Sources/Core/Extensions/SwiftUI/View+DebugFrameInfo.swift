//
//  View+DebugFrameInfo.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/12.
//

import SwiftUI

public extension View {
    func debug(_ color: Color = .blue) -> some View {
        modifier(FrameInfo(color: color))
    }
}

private struct FrameInfo: ViewModifier {
    let color: Color
    
    func body(content: Content) -> some View {
        content
        #if DEBUG
            .overlay(GeometryReader(content: overlay))
        #endif
    }
    
    func overlay(for geometry: GeometryProxy) -> some View {
        ZStack(alignment: .topTrailing) { 
            Rectangle()
                .strokeBorder(style: .init(lineWidth: 1, dash: [3]))
                .foregroundColor(color)
            
            Text("(\(Int(geometry.frame(in: .global).origin.x)), \(Int(geometry.frame(in: .global).origin.y))) \(Int(geometry.size.width))x\(Int(geometry.size.height))")
                .font(.caption2)
                .minimumScaleFactor(0.5)
                .foregroundColor(color)
                .padding(3)
                .offset(y: -20)
        }
    }
}
