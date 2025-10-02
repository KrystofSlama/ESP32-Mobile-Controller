import SwiftUI

struct ContentView: View {
    @StateObject var bleManager = BluetoothManager()
    
    var body: some View {
        ConnectingView(bleManager: bleManager)
    }
}
