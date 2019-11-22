import Dispatch
import CoreBluetooth
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

class BLEDiscovery: NSObject, CBCentralManagerDelegate {
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("didConnect:", peripheral)
    }
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("didUpdateState:")
        switch central.state {
            case .poweredOn:
                print("on")
                central.scanForPeripherals(withServices: nil, options: nil)
                print(central.isScanning)
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
        print("didDiscoveradvertisementDatarssi:", peripheral, advertisementData, RSSI)
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
