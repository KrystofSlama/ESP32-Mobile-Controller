import Foundation

struct ControllerPreset: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let isDefault: Bool

    let joystick1: Bool
    let trackpad1: Bool
    let trackpad2: Bool

    let buttons: [ActionButton]
    
    
    struct ActionButton: Codable, Identifiable, Equatable {
        let id: String
        let title: String
        let isVisible: Bool
        let iconSystemName: String?
        let buttonColorName: String?
        let sendMessage: String?
        let roombaBytes: [UInt8]?
        let roombaMotorBitMask: UInt8?
        let toggleGroup: String?
        let isToggle: Bool

        init(
            id: String,
            title: String,
            isVisible: Bool = true,
            iconSystemName: String? = nil,
            buttonColorName: String? = nil,
            sendMessage: String? = nil,
            roombaBytes: [UInt8]? = nil,
            roombaMotorBitMask: UInt8? = nil,
            toggleGroup: String? = nil,
            isToggle: Bool = false
        ) {
            self.id = id
            self.title = title
            self.isVisible = isVisible
            self.iconSystemName = iconSystemName
            self.buttonColorName = buttonColorName
            self.sendMessage = sendMessage
            self.roombaBytes = roombaBytes
            self.roombaMotorBitMask = roombaMotorBitMask
            self.toggleGroup = toggleGroup
            self.isToggle = isToggle
        }
    }
}

extension ControllerPreset {
    static let roombaMotorToggleGroup = "vacuum.motors"

    static let builtInPresets: [ControllerPreset] = [
        ControllerPreset(
            id: "default",
            name: "Default",
            isDefault: true,
            joystick1: true,
            trackpad1: false,
            trackpad2: false,
            buttons: [
                ActionButton(id: "btn.a", title: "A", buttonColorName: "blue", sendMessage: "A"),
                ActionButton(id: "btn.b", title: "B", buttonColorName: "green", sendMessage: "B"),
                ActionButton(id: "btn.c", title: "C", buttonColorName: "orange", sendMessage: "C"),
                ActionButton(id: "btn.d", title: "D", buttonColorName: "purple", sendMessage: "D"),
                ActionButton(id: "btn.e", title: "E", buttonColorName: "pink", sendMessage: "E"),
                ActionButton(id: "btn.f", title: "F", buttonColorName: "gray", sendMessage: "F")
            ]
        ),
        ControllerPreset(
            id: "robot-vacuum",
            name: "Robot Vacuum",
            isDefault: false,
            joystick1: true,
            trackpad1: false,
            trackpad2: false,
            buttons: [
                ActionButton(id: "rv.dock", title: "Dock", iconSystemName: "house", buttonColorName: "teal", sendMessage: "A"),
                ActionButton(id: "rv.spot", title: "Spot", iconSystemName: "sparkles", buttonColorName: "yellow", sendMessage: "B"),
                ActionButton(id: "rv.clean", title: "Clean", iconSystemName: "play.fill", buttonColorName: "green", sendMessage: "C"),
                ActionButton(id: "rv.vacuum", title: "Vacuum", iconSystemName: "tornado", buttonColorName: "gray", sendMessage: "D"),
                ActionButton(id: "rv.side-brush", title: "Side", iconSystemName: "fan", buttonColorName: "gray", sendMessage: "E"),
                ActionButton(id: "rv.main-brush", title: "Main", iconSystemName: "paintbrush", buttonColorName: "gray", sendMessage: "F")
            ]
        )
    ]

    static var defaultPreset: ControllerPreset {
        builtInPresets.first(where: { $0.isDefault }) ?? builtInPresets[0]
    }

    static func preset(withID id: String) -> ControllerPreset {
        builtInPresets.first(where: { $0.id == id }) ?? defaultPreset
    }
}
