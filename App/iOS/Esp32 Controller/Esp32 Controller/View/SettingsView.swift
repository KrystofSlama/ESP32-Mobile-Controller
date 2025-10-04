import SwiftUI

struct SettingsView: View {
    @ObservedObject var bleManager: BluetoothManager
    @State private var deviceFilter: String

    @AppStorage("controllerPreset.id") private var selectedPresetID: String = ControllerPreset.defaultPreset.id
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
                Menu(selectedPreset.name) {
                    ForEach(ControllerPreset.builtInPresets) { preset in
                        Button {
                            selectedPresetID = preset.id
                        } label: {
                            if preset.id == selectedPresetID {
                                Label(preset.name, systemImage: "checkmark")
                            } else {
                                Text(preset.name)
                            }
                        }
                    }
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(selectedPresetDescription)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    if selectedPreset.trackpad1 || selectedPreset.trackpad2 {
                        Text("Trackpads and joysticks shown here will appear when you open the preset controller view.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section {
                Button("Reset to Default") {
                    deviceFilter = "ESP32Roomba"
                    selectedPresetID = ControllerPreset.defaultPreset.id
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

    private var selectedPreset: ControllerPreset {
        ControllerPreset.preset(withID: selectedPresetID)
    }

    private var selectedPresetDescription: String {
        switch selectedPreset.id {
        case "robot-vacuum":
            return "Optimized for Roomba cleaning with toggles for the vacuum, side brush, and main brush, plus quick actions like Dock and Spot."
        default:
            return "A general purpose layout with joystick and six customizable action buttons (A–F)."
        }
    }
}

#Preview {
    SettingsView(bleManager: BluetoothManager())
}
