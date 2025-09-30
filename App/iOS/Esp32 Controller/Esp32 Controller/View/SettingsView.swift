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
    @State private var selectedProfile: RobotProfile

    init(bleManager: BluetoothManager) {
        self._bleManager = ObservedObject(wrappedValue: bleManager)
        self._deviceFilter = State(initialValue: bleManager.deviceName)
        self._selectedProfile = State(initialValue: bleManager.selectedProfile)
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

            Section("Controller Preset") {
                Picker("Active preset", selection: $selectedProfile) {
                    ForEach(RobotProfile.allCases) { profile in
                        Text(profile.displayName).tag(profile)
                    }
                }
                .pickerStyle(.segmented)

                Text(selectedProfile.description)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section {
                Button("Reset to Default") {
                    deviceFilter = "ESP32Roomba"
                    selectedProfile = .roomba
                }
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            deviceFilter = bleManager.deviceName
            selectedProfile = bleManager.selectedProfile
        }
        .onChange(of: deviceFilter) { newValue in
            if bleManager.deviceName != newValue {
                bleManager.deviceName = newValue
            }
        }
        .onChange(of: selectedProfile) { newValue in
            if bleManager.selectedProfile != newValue {
                bleManager.selectedProfile = newValue
            }
        }
    }
}

#Preview {
    SettingsView(bleManager: BluetoothManager())
}
