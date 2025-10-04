import SwiftUI

struct Controlllll: View {
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
            // Header
            HStack {
                Spacer()
                if bleManager.isConnected {
                    HStack(spacing: 0) {
                        Image(systemName: "wifi")
                            .font(.title2)
                            .foregroundStyle(.green)
                        Text("Connected")
                            .font(.title3)
                            .foregroundStyle(.green)
                    }
                } else {
                    HStack(spacing: 0) {
                        Image(systemName: "wifi.slash")
                            .font(.title2)
                            .foregroundStyle(.red)
                        Text("Disconnected")
                            .font(.title3)
                            .foregroundStyle(.red)
                    }
                }
                Spacer()
            }
            Spacer()
            // Main controll
            HStack {
                JoystickView { command in
                    bleManager.send(command)
                }
                Spacer()
                VStack {
                    Spacer()
                    Button {
                        bleManager.sendCommand("Reset")
                    } label: {
                        ZStack {
                            Text("Reset")
                                .font(.largeTitle)
                                .bold()
                                .foregroundStyle(.black)
                                .padding(.horizontal, 9)
                        }.background(.red)
                            .cornerRadius(8)
                    }
                }
                Spacer()
                VStack(spacing: 0) {
                    HStack {
                        Button {
                            bleManager.sendCommand("B")
                        } label: {
                            ZStack {
                                Circle()
                                    .frame(width: 70)
                                    .foregroundStyle(.yellow)
                                Text("B")
                                    .font(.system(size: 45, weight: .bold))
                                    .foregroundStyle(.black)
                            }
                        }
                    }
                    // Second Row
                    HStack {
                        Button {
                            bleManager.sendCommand("A")
                        } label: {
                            ZStack {
                                Circle()
                                    .frame(width: 70)
                                    .foregroundStyle(.red)
                                Text("A")
                                    .font(.system(size: 45, weight: .bold))
                                    .foregroundStyle(.black)
                            }.padding(.trailing)
                        }
                        
                        Button {
                            bleManager.sendCommand("D")
                        } label: {
                            ZStack {
                                Circle()
                                    .frame(width: 70)
                                    .foregroundStyle(.green)
                                Text("D")
                                    .font(.system(size: 45, weight: .bold))
                                    .foregroundStyle(.black)
                            }.padding(.leading)
                        }
                    }
                    // Third row
                    HStack {
                        Button {
                            bleManager.sendCommand("C")
                        } label: {
                            ZStack {
                                Circle()
                                    .frame(width: 70)
                                    .foregroundStyle(.blue)
                                Text("C")
                                    .font(.system(size: 45, weight: .bold))
                                    .foregroundStyle(.black)
                            }
                        }
                    }
                }
            }
            
        }
        .padding([.top])
        .navigationTitle("\(preset.name) Preset")
        .onChange(of: selectedPresetID) { _, _ in
            toggledButtons.removeAll()
        }
    }
}


#Preview {
    Controlllll(bleManager: BluetoothManager())
}

