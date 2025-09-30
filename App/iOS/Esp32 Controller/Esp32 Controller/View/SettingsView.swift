//
//  SettingsView.swift
//  Esp32 Controller
//
//  Created by Kryštof Sláma on 27.07.2025.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var bleManager: BluetoothManager
    @State private var deviceFilter: String

    init(bleManager: BluetoothManager) {
        self._bleManager = ObservedObject(wrappedValue: bleManager)
        self._deviceFilter = State(initialValue: bleManager.deviceName)
    }

    var body: some View {
        Form {
            Section("Device Filter") {
                TextField("Device name", text: $deviceFilter)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                Text("Only devices whose Bluetooth name matches this filter will appear on the connection screen.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section {
                Button("Reset to Default") {
                    deviceFilter = "ESP32Roomba"
                }
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            deviceFilter = bleManager.deviceName
        }
        .onChange(of: deviceFilter) { newValue in
            if bleManager.deviceName != newValue {
                bleManager.deviceName = newValue
            }
        }
    }
}

#Preview {
    SettingsView(bleManager: BluetoothManager())
}
