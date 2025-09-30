//
//  ControllerView.swift
//  Esp32 Controller
//
//  Created by Kryštof Sláma on 21.07.2025.
//

import SwiftUI

struct ControllerView: View {
    @ObservedObject var bleManager: BluetoothManager
    
    @State private var roombaMode: RoombaMode = .safe
    
    enum RoombaMode: String, CaseIterable, Identifiable {
        case safe = "Safe"
        case full = "Full"
        var id: String { self.rawValue }
    }
    
    
    @State private var sideBrushOn = false
    @State private var mainBrushOn = false
    @State private var vacuumOn = false

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button {
                    bleManager.checkConnection()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                Text("✅ Connected")
                    .font(.title2)
                
                Spacer()
                
                Picker("Mode", selection: $roombaMode) {
                    ForEach(RoombaMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode as RoombaMode)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                .frame(width: 200)
                .onChange(of: roombaMode) { oldMode, newMode in
                    switch newMode {
                    case .safe:
                        print("SAFE Mode")
                        bleManager.sendRoombaBytes([131]) // SAFE mode
                    case .full:
                        print("FULL Mode")
                        bleManager.sendRoombaBytes([132]) // FULL mode
                    }
                }

                
                Spacer()
                
                Button("📡 Dock") {
                    //bleManager.sendRoombaBytes([143])
                }
            }
            
            Spacer()
            
            
            
            
            HStack {
                
                
                JoystickView { command in
                    bleManager.send(command)
                }
                Spacer()
                
                VStack {
                    HStack {
                        Button {
                            vacuumOn.toggle()
                            motorsControl()
                        } label: {
                            ZStack {
                                Circle()
                                    .frame(width: 80, height: 80)
                                    .foregroundStyle(Color(.systemGray4))
                                
                                if vacuumOn {
                                    Image(systemName: "tornado")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundStyle(.black)
                                        .background(.clear)
                                } else {
                                    Image(systemName: "tornado")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundStyle(.black)
                                        .background(.clear)
                                }
                            }
                        }
                        .padding()
                        .cornerRadius(10)
                    }.padding(.bottom, -40)
                    HStack {
                        Button {
                            sideBrushOn.toggle()
                            motorsControl()
                        } label: {
                            ZStack {
                                Circle()
                                    .frame(width: 80, height: 80)
                                    .foregroundStyle(Color(.systemGray4))
                                
                                if sideBrushOn {
                                    Image(systemName: "fan.fill")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundStyle(.black)
                                        .background(.clear)
                                } else {
                                    Image(systemName: "fan")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundStyle(.black)
                                        .background(.clear)
                                }
                            }
                        }
                        .padding()
                        .cornerRadius(10)
                        
                        Spacer()
                        
                        Button {
                            mainBrushOn.toggle()
                            motorsControl()
                        } label: {
                            ZStack {
                                Circle()
                                    .frame(width: 80, height: 80)
                                    .foregroundStyle(Color(.systemGray4))
                                
                                if mainBrushOn {
                                    Image(systemName: "paintbrush.fill")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundStyle(.black)
                                        .background(.clear)
                                } else {
                                    Image(systemName: "paintbrush")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundStyle(.black)
                                        .background(.clear)
                                }
                            }
                        }
                        .padding()
                        .cornerRadius(10)
                    }.frame(width: 200)
                }
            }
        }
        .padding()
    }
    
    func motorsControl() {
        let mainByte: UInt8
        let brushByte: UInt8
        let vacuumByte: UInt8
        
        if mainBrushOn {
            mainByte = UInt8(4)
        } else {
            mainByte = UInt8(0)
        }
        if vacuumOn {
            vacuumByte = UInt8(2)
        } else {
            vacuumByte = UInt8(0)
        }
        if sideBrushOn {
            brushByte = UInt8(1)
        } else {
            brushByte = UInt8(0)
        }
        
        let bits: UInt8 = mainByte + brushByte + vacuumByte
        print("Sending: \(bits)")
        bleManager.sendRoombaBytes([138, bits])
    }
}


#Preview {
    ControllerView(bleManager: BluetoothManager())
}
