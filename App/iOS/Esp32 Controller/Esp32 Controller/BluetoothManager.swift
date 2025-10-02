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

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private static let deviceFilterDefaultsKey = "bluetooth.deviceFilterName"

    @Published var isConnected = false
    @Published var discoveredDevices: [BluetoothDevice] = []
    @Published var isScanning = false

    @Published var deviceName: String = UserDefaults.standard.string(forKey: BluetoothManager.deviceFilterDefaultsKey) ?? "ESP32 Roomba" {
        didSet {
            UserDefaults.standard.set(deviceName, forKey: BluetoothManager.deviceFilterDefaultsKey)
        }
    }

    @Published var connectedDevice: BluetoothDevice?

    private var centralManager: CBCentralManager!
    private var espPeripheral: CBPeripheral?
    private var txCharacteristic: CBCharacteristic?

    private let simulatedDevice = BluetoothDevice(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001") ?? UUID(),
        name: "ESP32 Roomba (Simulated)",
        isSimulated: true
    )

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        discoveredDevices = [simulatedDevice]
    }

    func startScan() {
        discoveredDevices = [simulatedDevice]
        print("🔎 Starting scan...")
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        isScanning = true
    }
    func stopScan() {
        print("🔎 Stoping scan")
        centralManager.stopScan()
        isScanning = false
    }

    func checkConnection() {
        if let device = connectedDevice, device.isSimulated {
            print("🤖 Simulated device always reported as connected.")
            isConnected = true
            return
        }

        guard let peripheral = espPeripheral else {
            print("❌ No device selected.")
            isConnected = false
            return
        }

        print("🔍 Checking connection to: \(peripheral.name ?? "Unknown")")

        if peripheral.state == .connected {
            print("✅ Peripheral is connected.")
            isConnected = true
        } else {
            print("❌ Peripheral is NOT connected. State: \(peripheral.state.rawValue)")
            isConnected = false
        }
    }

    func disconnect() {
        if let device = connectedDevice, device.isSimulated {
            connectedDevice = nil
            isConnected = false
            print("🤖 Disconnected from simulated device.")
            return
        }

        guard let peripheral = espPeripheral else { return }
        centralManager.cancelPeripheralConnection(peripheral)
        isConnected = false
        txCharacteristic = nil
        espPeripheral = nil
        print("🔌 Disconnected.")
        connectedDevice = nil
        isConnected = false
    }

    // MARK: - CBCentralManagerDelegate

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("✅ Bluetooth is ON. Ready to scan.")
        } else {
            print("❌ Bluetooth not ready: \(central.state.rawValue)")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let device = BluetoothDevice(peripheral: peripheral)
        print("🔍 Found peripheral: \(device.name), RSSI: \(RSSI), UUID: \(device.id)")

        if !discoveredDevices.contains(device) {
            discoveredDevices.append(device)
        }
    }

    func connect(to device: BluetoothDevice) {
        if device.isSimulated {
            stopScan()
            connectedDevice = device
            espPeripheral = nil
            txCharacteristic = nil
            isConnected = true
            print("🤖 Connected to simulated device.")
            return
        }

        guard let peripheral = device.peripheral else {
            print("❌ Attempted to connect to a device without a peripheral reference.")
            return
        }

        centralManager.stopScan()
        espPeripheral = peripheral
        espPeripheral?.delegate = self
        centralManager.connect(peripheral, options: nil)
        connectedDevice = device
        isScanning = false
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("✅ Connected to: \(peripheral.name ?? "Unknown")")
        if connectedDevice == nil {
            connectedDevice = BluetoothDevice(peripheral: peripheral)
        }
        isConnected = true
        peripheral.discoverServices(nil) // discover all services
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services, services.count > 0 else {
            print("❌ No services found on peripheral.")
            return
        }

        for service in services {
            print("🧩 Found service: \(service.uuid)")
            peripheral.discoverCharacteristics(nil, for: service) // discover all characteristics
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics, characteristics.count > 0 else {
            print("❌ No characteristics found for service \(service.uuid)")
            return
        }

        print("📨 Characteristics for service \(service.uuid):")

        for char in characteristics {
            print("    UUID: \(char.uuid), properties: \(char.properties)")

            if txCharacteristic == nil && (char.properties.contains(.write) || char.properties.contains(.writeWithoutResponse)) {
                txCharacteristic = char
                print("    ✅ Selected \(char.uuid) as writable characteristic.")
            }
        }

        if txCharacteristic == nil {
            print("❌ No writable characteristic found.")
        }
    }

    func sendRoombaBytes(_ bytes: [UInt8]) {
        for byte in bytes {
            send("C:\(byte)")
            usleep(10000) // 10 ms pause between each send
        }
    }

    func send(_ message: String) {
        if connectedDevice?.isSimulated == true {
            print("🤖 Simulated send: \(message)")
            return
        }

        if espPeripheral == nil {
            print("❌ No connected peripheral.")
        }
        if txCharacteristic == nil {
            print("❌ No txCharacteristic found.")
        }
        guard let peripheral = espPeripheral,
              let txChar = txCharacteristic,
              let data = message.data(using: .utf8) else {
            print("❌ send() failed: missing peripheral, characteristic, or data")
            return
        }

        let writeType: CBCharacteristicWriteType = txChar.properties.contains(.write) ? .withResponse : .withoutResponse
        print("📤 Sending message: \(message) using type: \(writeType == .withResponse ? "withResponse" : "withoutResponse")")

        peripheral.writeValue(data, for: txChar, type: writeType)
    }


}
