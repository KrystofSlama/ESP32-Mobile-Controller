import SwiftUI

struct RobotModeOption: Identifiable, Equatable {
    let id: String
    let title: String
    let caption: String?
    let command: RobotCommand

    init(id: String, title: String, caption: String? = nil, command: RobotCommand) {
        self.id = id
        self.title = title
        self.caption = caption
        self.command = command
    }
}

struct RobotQuickAction: Identifiable {
    enum ActionType {
        case momentary(command: RobotCommand)
        case toggle(defaultState: Bool, on: RobotCommand, off: RobotCommand)
        case roombaMotor(RobotMotorKind)
    }

    let id: String
    let title: String
    let iconName: String
    let type: ActionType

    init(id: String, title: String, iconName: String, type: ActionType) {
        self.id = id
        self.title = title
        self.iconName = iconName
        self.type = type
    }
}

enum RobotCommand {
    case text(String)
    case roombaBytes([UInt8])
}

enum RobotMotorKind: String, CaseIterable, Identifiable {
    case vacuum
    case sideBrush
    case mainBrush

    var id: String { rawValue }
}

enum RobotProfile: String, CaseIterable, Identifiable {
    case generic
    case roomba
    case tank

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .generic:
            return "Universal"
        case .roomba:
            return "Roomba"
        case .tank:
            return "Tracked Tank"
        }
    }

    var description: String {
        switch self {
        case .generic:
            return "Simple button presets for any ESP32-based robot."
        case .roomba:
            return "Tailored controls for iRobot Roomba vacuums using the Open Interface."
        case .tank:
            return "Preset commands for a differential drive tank with lights and accessories."
        }
    }

    var accentColor: Color {
        switch self {
        case .generic:
            return .blue
        case .roomba:
            return .green
        case .tank:
            return .orange
        }
    }

    var modeOptions: [RobotModeOption] {
        switch self {
        case .generic:
            return [
                RobotModeOption(id: "manual", title: "Manual", caption: "Direct drive with joystick", command: .text("MODE:MANUAL")),
                RobotModeOption(id: "assist", title: "Assist", caption: "Joystick + onboard assists", command: .text("MODE:ASSIST"))
            ]
        case .roomba:
            return [
                RobotModeOption(id: "safe", title: "Safe", caption: "Limits the motors", command: .roombaBytes([131])),
                RobotModeOption(id: "full", title: "Full", caption: "No safety limits", command: .roombaBytes([132]))
            ]
        case .tank:
            return [
                RobotModeOption(id: "precision", title: "Precision", caption: "Slow, accurate movements", command: .text("MODE:PRECISION")),
                RobotModeOption(id: "turbo", title: "Turbo", caption: "Full power driving", command: .text("MODE:TURBO"))
            ]
        }
    }

    var defaultMode: RobotModeOption? {
        modeOptions.first
    }

    var quickActions: [RobotQuickAction] {
        switch self {
        case .generic:
            return [
                RobotQuickAction(
                    id: "generic.b1",
                    title: "Light",
                    iconName: "lightbulb",
                    type: .toggle(defaultState: false, on: .text("B1:ON"), off: .text("B1:OFF"))
                ),
                RobotQuickAction(
                    id: "generic.b2",
                    title: "Horn",
                    iconName: "speaker.wave.3",
                    type: .momentary(command: .text("B2:TRIGGER"))
                ),
                RobotQuickAction(
                    id: "generic.b3",
                    title: "Macro",
                    iconName: "bolt",
                    type: .momentary(command: .text("B3:RUN"))
                )
            ]
        case .roomba:
            return [
                RobotQuickAction(
                    id: "roomba.vacuum",
                    title: "Vacuum",
                    iconName: "tornado",
                    type: .roombaMotor(.vacuum)
                ),
                RobotQuickAction(
                    id: "roomba.sideBrush",
                    title: "Side Brush",
                    iconName: "fan",
                    type: .roombaMotor(.sideBrush)
                ),
                RobotQuickAction(
                    id: "roomba.mainBrush",
                    title: "Main Brush",
                    iconName: "paintbrush",
                    type: .roombaMotor(.mainBrush)
                ),
                RobotQuickAction(
                    id: "roomba.dock",
                    title: "Dock",
                    iconName: "house",
                    type: .momentary(command: .roombaBytes([143]))
                )
            ]
        case .tank:
            return [
                RobotQuickAction(
                    id: "tank.headlights",
                    title: "Headlights",
                    iconName: "car.headlights",
                    type: .toggle(defaultState: false, on: .text("LIGHTS:ON"), off: .text("LIGHTS:OFF"))
                ),
                RobotQuickAction(
                    id: "tank.turret",
                    title: "Turret",
                    iconName: "scope",
                    type: .momentary(command: .text("TURRET:FIRE"))
                ),
                RobotQuickAction(
                    id: "tank.smoke",
                    title: "Smoke",
                    iconName: "smoke",
                    type: .toggle(defaultState: false, on: .text("SMOKE:ON"), off: .text("SMOKE:OFF"))
                ),
                RobotQuickAction(
                    id: "tank.anchor",
                    title: "Anchor",
                    iconName: "lifepreserver",
                    type: .momentary(command: .text("ANCHOR:DEPLOY"))
                )
            ]
        }
    }

    var joystickTip: String {
        switch self {
        case .generic:
            return "Use the joystick to stream normalized X/Y commands to your firmware."
        case .roomba:
            return "Joystick commands are translated into Roomba velocity/radius strings."
        case .tank:
            return "Differential drive: push forward to advance, twist to spin in place."
        }
    }
}
