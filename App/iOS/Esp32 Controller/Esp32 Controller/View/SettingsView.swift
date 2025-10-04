import SwiftUI

struct SettingsView: View {
    @ObservedObject var bleManager: BluetoothManager
    @State private var deviceFilter: String

    @State var selectedPreset: String = "Default"
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
            Section("Controller Preset") {
                Menu(selectedPreset) {
                    Button("Default") {
                        selectedPreset = "Default"
                    }
                    Button("Robot Vacuum") {
                        selectedPreset = "Robot Vacuum"
                    }
                }
            }

            Section {
                Button("Reset to Default") {
                    deviceFilter = "ESP32Roomba"
                }
                Link("SetUp Guide", destination: URL(string: "https://github.com/KrystofSlama/ESP32-Mobile-Controller/blob/main/ESP32/Roomba/README.md")!)
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
