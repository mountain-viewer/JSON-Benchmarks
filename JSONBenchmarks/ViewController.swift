//
//  ViewController.swift
//  JSONBenchmarks
//
//  Created by Iaroslav Spirin on 1/23/19.
//  Copyright © 2019 Mountain Viewer. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftProtobuf

class ViewController: UIViewController {
    
    @IBOutlet weak var protobufLabel: UILabel!
    @IBOutlet weak var swiftyJSONLabel: UILabel!
    @IBOutlet weak var codableLabel: UILabel!
    @IBOutlet weak var json11Label: UILabel!
    @IBOutlet weak var jsmnLabel: UILabel!
    
    func carList() -> Data {
        let jsonURL = Bundle.main.url(forResource: "Cars", withExtension: "json")
        let jsonData = try! Data(contentsOf: jsonURL!)
        return jsonData
    }
    
    func evaluateProblem(_ name: String, method: () -> Void) -> String {
        
        let start = DispatchTime.now()
        method()
        let end = DispatchTime.now()
        
        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
        let timeInterval = Double(nanoTime) / 1_000_000_000
        
        let verdict = "    \(name): \(timeInterval) seconds"
        
        print(verdict)
        return verdict
    }
    
    func testProtobuf() {
        let carsJSON = carList()
        
        let verdict = evaluateProblem("Swift Protobuf") {
            _ = try! CarList(jsonUTF8Data: carsJSON)
        }
        
        protobufLabel.text = verdict
    }
    
    func testSwiftyJSON() {
        let carsJSON = carList()
        
        let verdict = evaluateProblem("SwiftyJSON") {
            let carList = JSON(carsJSON)["cars"].arrayValue
            
            var cars: [Car] = []
            for carJSON in carList {
                var car = Car()
                car.modelID = carJSON["model_id"].stringValue
                
                
                for sfItem in carJSON["sf"].arrayValue {
                    car.sf.append(sfItem.int32Value)
                }
                
                for filter in carJSON["filters"].arrayValue {
                    car.filters.append(filter.int32Value)
                }
                
                car.telematics.fuelDistance = carJSON["telematics"]["fuel_distance"].int32Value
                car.telematics.fuelLevel = carJSON["telematics"]["fuel_level"].int32Value
                
                car.number = carJSON["number"].stringValue
                
                car.location.lat = carJSON["location"]["lat"].floatValue
                car.location.lon = carJSON["location"]["lon"].floatValue
                car.location.course = carJSON["location"]["course"].int32Value
                
                if let patches = carJSON["patches"].array {
                    for patch in patches {
                        car.patches.append(patch.int32Value)
                    }
                }
                
                cars.append(car)
            }
        }
        
        swiftyJSONLabel.text = verdict
    }
    
    func testCodable() {
        let carsJSON = carList()
        let decoder = JSONDecoder()
        
        let verdict = evaluateProblem("Codable") {
            _ = try! decoder.decode(CodableCarList.self, from: carsJSON)
        }
        
        codableLabel.text = verdict
    }
    
    func testDropboxParser() {
        let carsJSON = carList()
        let carsJSONString = String(data: carsJSON, encoding: .utf8)
        
        let parser = DropboxParserWrapper(carsJSONString)
        
        let verdict = evaluateProblem("Dropbox json11") {
            _ = parser?.parse()
        }
        
        json11Label.text = verdict
    }
    
    func testJSMNParser() {
        let carsJSON = carList()
        let carsJSONString = String(data: carsJSON, encoding: .utf8)
        
        let parser = JSMNParser(carsJSONString)
        
        let verdict = evaluateProblem("JSMN Parser") {
            let result = parser?.parseJSON()
            print(result![1])
        }
        
        jsmnLabel.text = verdict
    }

    @IBAction func runTestsTouchUpInside(_ sender: Any) {
        //testProtobuf()
        //testSwiftyJSON()
        //testCodable()
        //testDropboxParser()
        testJSMNParser()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
}


