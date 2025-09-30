//
//  SettingsView.swift
//  Esp32 Controller
//
//  Created by Kryštof Sláma on 27.07.2025.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var bleManager: BluetoothManager
    var body: some View {
        HStack {
            
        }
    }
}

#Preview {
    SettingsView(bleManager: BluetoothManager())
}
