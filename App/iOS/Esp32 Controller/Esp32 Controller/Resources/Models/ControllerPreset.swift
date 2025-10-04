import Foundation

struct ControllerPreset: Codable {
    let id: String
    let name: String
    let isDefault: Bool
    
    let joystick1: Bool
    let trackpad1: Bool
    let trackpad2: Bool
    
    let buttons: [button]
    
    struct button: Codable {
        let isVisible: Bool
        let name: String?
        let imageSysname: String?
        let buttonColor: String?
    }
}
