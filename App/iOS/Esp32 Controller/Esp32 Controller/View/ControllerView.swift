import SwiftUI

struct ControllerView: View {
    @ObservedObject var bleManager: BluetoothManager

    @State private var selectedModeID: String = ""
    @State private var quickActionStates: [String: Bool] = [:]
    @State private var roombaMotorStates: [RobotMotorKind: Bool] = [:]
    @State private var suppressModeCommand = false

    private var profileBinding: Binding<RobotProfile> {
        Binding(
            get: { bleManager.selectedProfile },
            set: { bleManager.selectedProfile = $0 }
        )
    }

    var body: some View {
        let profile = bleManager.selectedProfile

        VStack(alignment: .leading, spacing: 24) {
            headerView(for: profile)

            if !profile.description.isEmpty {
                Text(profile.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(alignment: .top, spacing: 24) {
                VStack(spacing: 12) {
                    JoystickView { command in
                        bleManager.send(command)
                    }
                    .padding(.trailing, 8)

                    Text(profile.joystickTip)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: 220)
                        .multilineTextAlignment(.center)
                }

                Spacer(minLength: 24)

                if !profile.quickActions.isEmpty {
                    quickActionsPanel(for: profile)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .padding()
        .navigationTitle(profile.displayName)
        .onAppear {
            resetState(for: profile)
        }
        .onChange(of: bleManager.selectedProfile) { newProfile in
            resetState(for: newProfile)
        }
        .onChange(of: selectedModeID) { newValue in
            guard !suppressModeCommand,
                  let mode = bleManager.selectedProfile.modeOptions.first(where: { $0.id == newValue }) else {
                return
            }
            applyMode(mode)
        }
    }

    @ViewBuilder
    private func headerView(for profile: RobotProfile) -> some View {
        HStack(spacing: 16) {
            Button {
                bleManager.checkConnection()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .imageScale(.large)
            }

            Label {
                Text(bleManager.isConnected ? "Connected" : "Disconnected")
                    .font(.headline)
            } icon: {
                Image(systemName: bleManager.isConnected ? "checkmark.circle" : "xmark.circle")
                    .foregroundStyle(bleManager.isConnected ? .green : .red)
            }

            Spacer()

            if !profile.modeOptions.isEmpty {
                Picker("Mode", selection: $selectedModeID) {
                    ForEach(profile.modeOptions) { mode in
                        Text(mode.title).tag(mode.id)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 300)
                .accessibilityLabel("Robot mode")
            }

            Picker("Preset", selection: profileBinding) {
                ForEach(RobotProfile.allCases) { profile in
                    Text(profile.displayName).tag(profile)
                }
            }
            .pickerStyle(.menu)
            .tint(profile.accentColor)
        }
    }

    @ViewBuilder
    private func quickActionsPanel(for profile: RobotProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)

            let columns = [GridItem(.flexible()), GridItem(.flexible())]
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(profile.quickActions) { action in
                    Button {
                        handleQuickAction(action)
                    } label: {
                        quickActionContent(for: action, profile: profile)
                    }
                    .buttonStyle(.plain)
                    .disabled(!bleManager.isConnected)
                }
            }
        }
    }

    private func quickActionContent(for action: RobotQuickAction, profile: RobotProfile) -> some View {
        let isOn = actionIsOn(action)
        return VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isOn ? profile.accentColor.opacity(0.25) : Color(.systemGray4))
                    .frame(width: 80, height: 80)

                Image(systemName: symbolName(for: action, isOn: isOn))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 42, height: 42)
                    .foregroundStyle(isOn ? profile.accentColor : .primary)
            }

            Text(action.title)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(action.title)
        .accessibilityValue(isOn ? "On" : "Off")
    }

    private func symbolName(for action: RobotQuickAction, isOn: Bool) -> String {
        switch action.type {
        case .roombaMotor(let motor):
            switch motor {
            case .vacuum:
                return isOn ? "tornado" : "tornado"
            case .sideBrush:
                return isOn ? "fan.fill" : "fan"
            case .mainBrush:
                return isOn ? "paintbrush.fill" : "paintbrush"
            }
        default:
            return action.iconName
        }
    }

    private func handleQuickAction(_ action: RobotQuickAction) {
        switch action.type {
        case .momentary(let command):
            send(command)

        case let .toggle(defaultState, onCommand, offCommand):
            let currentState = quickActionStates[action.id] ?? defaultState
            let newState = !currentState
            quickActionStates[action.id] = newState
            send(newState ? onCommand : offCommand)

        case .roombaMotor(let motor):
            let current = roombaMotorStates[motor] ?? false
            roombaMotorStates[motor] = !current
            sendRoombaMotorBits()
        }
    }

    private func actionIsOn(_ action: RobotQuickAction) -> Bool {
        switch action.type {
        case .momentary:
            return false
        case let .toggle(defaultState, _, _):
            return quickActionStates[action.id] ?? defaultState
        case .roombaMotor(let motor):
            return roombaMotorStates[motor] ?? false
        }
    }

    private func sendRoombaMotorBits() {
        let main = roombaMotorStates[.mainBrush] ?? false
        let vacuum = roombaMotorStates[.vacuum] ?? false
        let side = roombaMotorStates[.sideBrush] ?? false

        let bits: UInt8 = (main ? 4 : 0) + (vacuum ? 2 : 0) + (side ? 1 : 0)
        bleManager.sendRoombaBytes([138, bits])
    }

    private func applyMode(_ mode: RobotModeOption) {
        send(mode.command)
    }

    private func send(_ command: RobotCommand) {
        switch command {
        case .text(let message):
            bleManager.send(message)
        case .roombaBytes(let bytes):
            bleManager.sendRoombaBytes(bytes)
        }
    }

    private func resetState(for profile: RobotProfile) {
        suppressModeCommand = true
        selectedModeID = profile.defaultMode?.id ?? ""

        quickActionStates = [:]
        for action in profile.quickActions {
            if case let .toggle(defaultState, _, _) = action.type {
                quickActionStates[action.id] = defaultState
            }
        }

        roombaMotorStates = [:]
        if profile == .roomba {
            for motor in RobotMotorKind.allCases {
                roombaMotorStates[motor] = false
            }
        }

        DispatchQueue.main.async {
            suppressModeCommand = false
        }
    }
}

#Preview {
    let manager = BluetoothManager()
    manager.selectedProfile = .roomba
    return ControllerView(bleManager: manager)
}
