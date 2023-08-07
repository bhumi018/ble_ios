//
//  MainVC.swift
//  BLE_DEMO
//
//  Created by Bhumita Panara on 25/07/23.
//

import UIKit
import CoreBluetooth

class MainVC: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    //MARK: - OUTLETS
    @IBOutlet weak var lblDeviceName: UILabel!
    @IBOutlet weak var lblBatteryLevel: UILabel!
    
    
    //MARK: - GLOBAL VARIABLES
    var centralManager = CBCentralManager()
    var peripheral: CBPeripheral?
    let UUIDdevice = UUID(uuidString:"A6DCBC6F-0021-6BO9-10C1-BDA4S6CV8N68")
    var characteristicData: [CBCharacteristic] = []
    var batteryLevelValue = 0
    let BATTERY_LEVEL_CHARACTERISTIC = CBUUID(string: "2B18")
    
    
    //MARK: - UI VIEW CONTROLLER LIFE CYCLES
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    //MARK: - DELEGATE METHODS
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn{
            central.scanForPeripherals(withServices:nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard peripheral.name != nil else { return }
        
        //        //MARK: - METHOD_1 FOR FILTERING THE PERIPHERALS
        //        if let name = peripheral.name{
        //            if name.hasPrefix("CJ"){
        //                self.centralManager.stopScan()
        //                self.centralManager.connect(peripheral, options: nil)
        //                self.peripheral = peripheral
        //                if let deviceName = self.peripheral?.name{
        //                    lblDeviceName.text = "Device Name : \(deviceName)"
        //                }
        //                print("EXPECTED_PERIPHERALS - \(self.peripheral!)")
        //            }
        //        }
        
        //MARK: - METHOD_2 FOR FILTERING THE PERIPHERALS
        if peripheral.identifier == UUIDdevice{
            self.centralManager.stopScan()
            self.centralManager.connect(peripheral, options: nil)
            self.peripheral = peripheral
            if let deviceName = self.peripheral?.name{
                lblDeviceName.text = "Device Name : \(deviceName)"
            }
            print("EXPECTED_PERIPHERALS = \(self.peripheral!)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.peripheral?.discoverServices(nil) //can provide array of specific services
        self.peripheral?.delegate = self
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services{
            for service in services{
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for charac in service.characteristics!{
            
            characteristicData.append(charac)
            if charac.uuid == BATTERY_LEVEL_CHARACTERISTIC{
                peripheral.setNotifyValue(true, for: charac)
                peripheral.readValue(for: charac)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        guard let data = characteristic.value else {
            return
        }
        
        if characteristic.uuid == BATTERY_LEVEL_CHARACTERISTIC{
            batteryLevelValue = Int(data[0]) //we are getting battery information at index 0, this would vary based on how firmware is configured to sent data on specific index.
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let peripheral = peripheral as CBPeripheral?{
            peripheral.delegate = nil
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    //MARK: - ACTIONS
    @IBAction func onClickBtnBatteryLevel(_ sender: UIButton) {
        lblBatteryLevel.isHidden = !lblBatteryLevel.isHidden
        lblBatteryLevel.text = "Battery Level : \(batteryLevelValue)"
    }
    
    @IBAction func onClickMoreCharac(_ sender: UIButton) {
        let main = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = main.instantiateViewController(withIdentifier: "DetailVC") as! DetailVC
        vc.characteristicData = characteristicData
        self.present(vc, animated: true)
    }
    
}
