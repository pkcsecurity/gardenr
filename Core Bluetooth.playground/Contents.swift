import Dispatch
import CoreBluetooth
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

class BLEDiscovery: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var myManager: CBCentralManager? = nil
    var myPeripheral: CBPeripheral? = nil
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let e = error {
            print(e)
        }
        else if let v = characteristic.value {
            print(v)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        if let e = error {
            print(e)
        }
        else if let v = descriptor.value {
            print(v)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        print("didDiscoverDescriptorsFor:")
        if let e = error {
            print(e)
        }
        else if let descriptors = characteristic.descriptors {
            for descriptor in descriptors {
                print(descriptor)
                peripheral.readValue(for: descriptor)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("didDiscoverCharacteristicsFor:")
        if let e = error {
            print(e)
        }
        else if let characteristics = service.characteristics {
            for characteristic in characteristics {
                print(characteristic)
                peripheral.discoverDescriptors(for: characteristic)
                peripheral.readValue(for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("didDiscoverServices:")
        if let e = error {
            print(e)
        }
        else if let services = peripheral.services {
            for service in services {
                print(service)
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("didConnect:", peripheral)
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("didUpdateState:")
        switch central.state {
            case .poweredOn:
                print("on")
                self.myManager = central
                central.scanForPeripherals(withServices: nil, options: nil)
            default:
                print(central.state.rawValue)
                break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let e = error {
            print("didFailToConnect:", peripheral, e)
        }
        else {
            print("didFailToConnect:", peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == "OBDBLE" {
            print("advertisementData:", advertisementData)
            self.myPeripheral = peripheral
            central.connect(peripheral, options: nil)
            central.stopScan()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let e = error {
            print("didDisconnectPeripheral:", peripheral, e)
        }
        else {
            print("didDisconnectPeripheral:", peripheral)
        }
    }
}

var b = BLEDiscovery()

var mngr = CBCentralManager.init(delegate: b, queue: DispatchQueue.main)
