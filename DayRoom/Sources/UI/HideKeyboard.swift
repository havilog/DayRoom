//
//  HideKeyboard.swift
//  DayRoom
//
//  Created by 한상진 on 2023/06/12.
//

import UIKit
import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
