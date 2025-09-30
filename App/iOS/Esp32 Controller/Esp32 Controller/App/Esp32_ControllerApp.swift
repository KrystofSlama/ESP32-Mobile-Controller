//
//  Esp32_ControllerApp.swift
//  Esp32 Controller
//
//  Created by Kryštof Sláma on 19.07.2025.
//

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
