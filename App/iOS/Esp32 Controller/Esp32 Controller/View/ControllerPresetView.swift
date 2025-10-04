import SwiftUI

struct ControllerPresetView: View {
    @ObservedObject var bleManager: BluetoothManager
    @AppStorage("controllerPreset.id") private var selectedPresetID: String = ControllerPreset.defaultPreset.id

    @State private var toggledButtons: Set<String> = []

    private var preset: ControllerPreset {
        ControllerPreset.preset(withID: selectedPresetID)
    }

    private var roombaToggleButtons: [ControllerPreset.ActionButton] {
        preset.buttons.filter { $0.toggleGroup == ControllerPreset.roombaMotorToggleGroup }
    }

    var body: some View {
        VStack(spacing: 24) {
            header

            if preset.joystick1 {
                JoystickView { command in
                    bleManager.send(command)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }

            if !visibleButtons.isEmpty {
                buttonGrid
            } else {
                Text("This preset does not define any buttons.")
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("\(preset.name) Preset")
        .onChange(of: selectedPresetID) { _, _ in
            toggledButtons.removeAll()
        }
    }

    private var header: some View {
        HStack {
            if bleManager.isConnected {
                Label("Connected", systemImage: "wifi")
                    .font(.headline)
                    .foregroundStyle(.green)
            } else {
                Label("Disconnected", systemImage: "wifi.slash")
                    .font(.headline)
                    .foregroundStyle(.red)
            }

            Spacer()

            Text(preset.name)
                .font(.title3)
                .bold()

            Spacer()

            Button {
                if bleManager.isConnected {
                    bleManager.checkConnection()
                } else {
                    bleManager.startScan()
                }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.title2)
            }
            .buttonStyle(.bordered)
        }
    }

    private var buttonGrid: some View {
        let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)

        return LazyVGrid(columns: columns, spacing: 16) {
            ForEach(visibleButtons) { button in
                Button {
                    handleButtonTap(button)
                } label: {
                    VStack(spacing: 8) {
                        if let icon = button.iconSystemName {
                            Image(systemName: iconName(for: button))
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(12)
                                .background(buttonBackground(for: button))
                                .clipShape(Circle())
                        } else {
                            Text(button.title)
                                .font(.title3.bold())
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(buttonBackground(for: button))
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .foregroundStyle(.white)
                        }

                        if button.iconSystemName != nil {
                            Text(button.title)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(toggledButtons.contains(button.id) ? Color.accentColor.opacity(0.15) : Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .disabled(!bleManager.isConnected)
            }
        }
    }

    private var visibleButtons: [ControllerPreset.ActionButton] {
        preset.buttons.filter { $0.isVisible }
    }

    private func handleButtonTap(_ button: ControllerPreset.ActionButton) {
        if button.isToggle {
            if toggledButtons.contains(button.id) {
                toggledButtons.remove(button.id)
            } else {
                toggledButtons.insert(button.id)
            }
        }

        if let message = button.sendMessage {
            bleManager.send(message)
        }

        if let bytes = button.roombaBytes {
            bleManager.sendRoombaBytes(bytes)
        }

        if let group = button.toggleGroup, group == ControllerPreset.roombaMotorToggleGroup {
            let bits = roombaToggleButtons
                .filter { toggledButtons.contains($0.id) }
                .reduce(UInt8(0)) { partialResult, action in
                    partialResult + (action.roombaMotorBitMask ?? 0)
                }
            bleManager.sendRoombaBytes([138, bits])
        }
    }

    private func iconName(for button: ControllerPreset.ActionButton) -> String {
        if button.isToggle, let icon = button.iconSystemName {
            if toggledButtons.contains(button.id) {
                switch icon {
                case "fan": return "fan.fill"
                case "paintbrush": return "paintbrush.fill"
                case "tornado": return "tornado"
                default: return icon
                }
            }
        }
        return button.iconSystemName ?? "circle"
    }

    private func buttonBackground(for button: ControllerPreset.ActionButton) -> Color {
        let baseColor: Color
        switch button.buttonColorName?.lowercased() {
        case "blue": baseColor = .blue
        case "green": baseColor = .green
        case "orange": baseColor = .orange
        case "purple": baseColor = .purple
        case "pink": baseColor = .pink
        case "teal": baseColor = .teal
        case "yellow": baseColor = .yellow
        case "gray": baseColor = Color(.systemGray4)
        default: baseColor = .accentColor
        }

        if button.isToggle {
            return toggledButtons.contains(button.id) ? baseColor : baseColor.opacity(0.5)
        }
        return baseColor
    }
}

#Preview {
    ControllerPresetView(bleManager: BluetoothManager())
}
