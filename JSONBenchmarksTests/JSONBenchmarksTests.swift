//
//  JSONBenchmarksTests.swift
//  JSONBenchmarksTests
//
//  Created by Iaroslav Spirin on 1/23/19.
//  Copyright © 2019 Mountain Viewer. All rights reserved.
//

import XCTest
@testable import JSONBenchmarks

import SwiftyJSON
import SwiftProtobuf

class JSONBenchmarksTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func carList() -> Data {
        let jsonURL = Bundle.main.url(forResource: "Cars", withExtension: "json")
        let jsonData = try! Data(contentsOf: jsonURL!)
        return jsonData
    }

    func evaluateProblem(_ name: String, method: () -> Void) {
        
        let start = DispatchTime.now()
        method()
        let end = DispatchTime.now()
        
        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
        let timeInterval = Double(nanoTime) / 1_000_000_000
        
        print("    \(name): \(timeInterval) seconds")
    }
    
    func testProtobuf() {
        let carsJSON = carList()
        
        evaluateProblem("Swift Protobuf") {
            let json = try! CarList(jsonUTF8Data: carsJSON)
        }
    }

    func testSwiftyJSON() {
        let carsJSON = carList()
        
        evaluateProblem("SwiftyJSON") {
            var carList = JSON(carsJSON)["cars"].arrayValue
            
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
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
