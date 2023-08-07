//
//  DetailVC.swift
//  BLE_DEMO
//
//  Created by Bhumita Panara on 25/07/23.
//

import UIKit
import CoreBluetooth

class DetailVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
   
    //MARK: - OUTLETS
    @IBOutlet weak var tblVw: UITableView!
    
    //MARK: - GLOBAL VARIABLES
    var characteristicData: [CBCharacteristic] = []

    //MARK: - UI VIEW CONTROLLER LIFE CYCLES
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    //MARK: - DELEGATE METHODS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characteristicData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CharacViewCell
        cell.lblCharacName.text = "\(characteristicData[indexPath.row].uuid)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true)
    }
    
}

