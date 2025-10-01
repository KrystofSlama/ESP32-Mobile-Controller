import SwiftUI

struct ConnectingView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var bleManager: BluetoothManager

    @State private var connectionTimer: Timer?

    
    var body: some View {
        NavigationStack {
            HStack(spacing: 0) {
                // List of devices
                VStack {
                    let filteredDevices = bleManager.discoveredDevices.filter { $0.name == bleManager.deviceName }
                    
                    if filteredDevices.isEmpty && bleManager.isScanning {
                        VStack {
                            ProgressView("Searching...")
                                .padding()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if filteredDevices.isEmpty && !bleManager.isScanning {
                        VStack {
                            Image(systemName: "magnifyingglass")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.secondary)
                            
                            Text("Search")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List(filteredDevices, id: \.identifier) { device in
                            
                            
                            HStack {
                                Text(device.name ?? "Unnamed")
                                
                                Spacer()
                                
                                if (bleManager.connectedPeripheral?.identifier == device.identifier) {
                                    Button("Disconnect") {
                                        bleManager.disconnect()
                                    }
                                } else {
                                    Button("Connect") {
                                        bleManager.connect(to: device)
                                        print("connected: \(String(describing: bleManager.connectedPeripheral?.identifier)), fdevice: \(String(describing: device.identifier))")
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        if bleManager.isScanning {
                            bleManager.stopScan()
                        } else {
                            bleManager.startScan()
                        }
                    } label: {
                        if bleManager.isScanning {
                            ZStack {
                                Rectangle()
                                    .frame(width: 150, height: 60)
                                    .cornerRadius(12)
                                    .foregroundStyle(.red)
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .resizable()
                                        .bold()
                                        .foregroundStyle(.black)
                                        .frame(width: 30, height: 30)
                                    Text("Stop")
                                        .foregroundStyle(.black)
                                        .bold()
                                        .font(.largeTitle)
                                }
                            }
                        } else {
                            ZStack {
                                Rectangle()
                                    .frame(width: 150, height: 60)
                                    .cornerRadius(12)
                                    .foregroundStyle(.yellow)
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .resizable()
                                        .bold()
                                        .foregroundStyle(.black)
                                        .frame(width: 30, height: 30)
                                    Text("Start")
                                        .foregroundStyle(.black)
                                        .bold()
                                        .font(.largeTitle)
                                }
                            }
                        }
                    }
                }
                Spacer()
                
                // Middle
                VStack {
                    
                }.frame(maxWidth: .infinity)
                    .border(Color.green, width: 3)
                
                Spacer()
                
                // Right buttons
                VStack {
                    HStack {
                        Spacer()
                        
                        NavigationLink {
                            SettingsView(bleManager: bleManager)
                        } label: {
                            Image(systemName: "gear")
                                .resizable()
                                .frame(width: 45, height: 45)
                                .bold()
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    }.padding()
                    
                    
                    
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        NavigationLink {
                            ControllerView(bleManager: bleManager)
                        } label: {
                            Text("Drive")
                                .foregroundStyle(.black)
                                .font(.largeTitle)
                                .bold()
                                .padding(.horizontal)
                                .padding(.vertical, 10)
                        }.buttonStyle(.borderedProminent)
                            .tint(.green)
                            .disabled(!bleManager.isConnected)
                    }.padding(.trailing)
                    
                }.frame(maxWidth: .infinity)
            }.padding()
                .edgesIgnoringSafeArea(.all)
        }
        .onAppear {
            connectionTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
                bleManager.checkConnection()
            }
        }
        .onDisappear {
            connectionTimer?.invalidate()
            connectionTimer = nil
            bleManager.stopScan()
        }
    }
}


#Preview {
    ConnectingView(bleManager: BluetoothManager())
}
