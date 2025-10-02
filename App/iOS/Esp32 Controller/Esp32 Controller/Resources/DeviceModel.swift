import Foundation
import CoreBluetooth

struct BluetoothDevice: Identifiable, Equatable {
    let id: UUID
    let name: String
    let peripheral: CBPeripheral?
    let isSimulated: Bool

    init(peripheral: CBPeripheral) {
        self.id = peripheral.identifier
        self.name = peripheral.name ?? "Unnamed"
        self.peripheral = peripheral
        self.isSimulated = false
    }

    init(id: UUID = UUID(), name: String, isSimulated: Bool) {
        self.id = id
        self.name = name
        self.peripheral = nil
        self.isSimulated = isSimulated
    }

    static func == (lhs: BluetoothDevice, rhs: BluetoothDevice) -> Bool {
        lhs.id == rhs.id
    }
}
