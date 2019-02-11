//
//  CodableCar.swift
//  JSONBenchmarks
//
//  Created by Iaroslav Spirin on 1/28/19.
//  Copyright © 2019 Mountain Viewer. All rights reserved.
//

import Foundation

struct CodableCarList: Codable {
    var cars: [CodableCar]
}

struct CodableCar: Codable {
    var telematics: CodableTelematics
    var location: CodableLocation
    var modelID: String
    var number: String
    var patches: [Int]?
    var sf: [Int]
    var filters: [Int]
    
    private enum CodingKeys : String, CodingKey {
        case telematics
        case location
        case modelID = "model_id"
        case number
        case patches
        case sf
        case filters
    }
}

struct CodableTelematics: Codable {
    var fuelDistance: Int?
    var fuelLevel: Int?
    
    private enum CodingKeys : String, CodingKey {
        case fuelDistance = "fuel_distance"
        case fuelLevel = "fuel_level"
    }
}

struct CodableLocation: Codable {
    var course: Int
    var lat: Float
    var lon: Float
}
