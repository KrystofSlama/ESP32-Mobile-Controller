import SwiftUI

@main
struct Esp32_ControllerApp: App {
    @StateObject var bleManager = BluetoothManager()
    
    var body: some Scene {
        WindowGroup {
            ConnectingView(bleManager: bleManager)
        }
    }
}
