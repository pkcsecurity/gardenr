import Dispatch
import CoreBluetooth
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

class BLEComms: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    let servUuids = [
        CBUUID(string:"FFE0")
    ]
    
    let charUuids = [
//        CBUUID(string:"FFEE"),
        CBUUID(string:"FFE1")
    ]
    
    let toWrite = [
        "ATE0",
        "ATL0",
        "ATS0",
        "0100"
    ]
    
    var toWriteIndex = 0
    
    var peripheral: CBPeripheral? = nil
    var writeChar: CBCharacteristic? = nil
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        let descUuidStr = descriptor.uuid.uuidString
        var value: String = ""
        if let v = descriptor.value {
            if let vData = v as? Data {
//                if let s = String(data: vData, encoding:String.Encoding.ascii) {
//                    value = s
//                }
//                else {
                value = vData.map { String(format:"%02hhX", $0) }.joined()
//                }
            }
            else {
                value = String(describing: v)
            }
        }
        else if let e = error {
            value = e.localizedDescription
        }
        else {
            value = "No data"
        }
        print("descriptor", descUuidStr, value)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let charUuidStr = characteristic.uuid.uuidString
        var value: String = ""
        if let v = characteristic.value {
            if let s = String(data: v, encoding:String.Encoding.ascii) {
                value = s
            }
            else {
                value = v.map { String(format:"%02hhX", $0) }.joined()
            }
        }
        else if let e = error {
            value = e.localizedDescription
        }
        else {
            value = "No data"
        }
        print("characteristic", charUuidStr, value)
//        print(value, terminator:"")
    }
    
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
//        if let descriptors = characteristic.descriptors {
//            for descriptor in descriptors {
//                peripheral.readValue(for: descriptor)
//            }
//        }
//    }
    
//    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
//        let descUuidStr = descriptor.uuid.uuidString
//        var value = ""
//        if let e = error {
//            value = e.localizedDescription
//        }
//        else {
//            value = "success"
//        }
//        print("didWriteValueFor descriptor", descUuidStr, value)
//    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        let charUuidStr = characteristic.uuid.uuidString
        var value = ""
        if let e = error {
            value = e.localizedDescription
        }
        else {
            value = "success"
            if self.toWriteIndex < self.toWrite.count {
                DispatchQueue.main.async {
                    let str = self.toWrite[self.toWriteIndex] + "\r"
                    peripheral.writeValue(str.data(using: .ascii)!, for: characteristic, type: .withResponse)
                    self.toWriteIndex += 1
                }
            }
        }
        print("didWriteValueFor characteristic", charUuidStr, value)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
//                if characteristic.uuid.uuidString == "FFE1" {
                peripheral.setNotifyValue(true, for: characteristic)
//                peripheral.readValue(for: characteristic)
                DispatchQueue.main.async {
                    let str = self.toWrite[self.toWriteIndex] + "\r"
                    peripheral.writeValue(str.data(using: .ascii)!, for: characteristic, type: .withResponse)
                    self.toWriteIndex += 1
                }
//                }
//                peripheral.discoverDescriptors(for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(self.charUuids, for: service)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(self.servUuids)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            case .poweredOn:
                central.scanForPeripherals(withServices: self.servUuids, options: nil)
            default:
                print(central.state.rawValue)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == "OBDBLE" {
            self.peripheral = peripheral
            central.connect(peripheral, options: nil)
            central.stopScan()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        PlaygroundPage.current.finishExecution()
    }
}

let comm = BLEComms()

let mngr = CBCentralManager.init(delegate: comm, queue: DispatchQueue.main)

DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
    if let p = comm.peripheral {
        mngr.cancelPeripheralConnection(p)
    }
    else {
        PlaygroundPage.current.finishExecution()
    }
}
