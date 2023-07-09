//
//  DatePickerView.swift
//  DayRoom
//
//  Created by 한상진 on 2023/07/01.
//

import SwiftUI

struct DatePickerView: View {
    
    @Binding var date: Date
    
    var body: some View {
        DatePicker("", selection: $date, displayedComponents: [.date])
            .datePickerStyle(.graphical)
            .presentationDetents([.height(400)])
    }
}
