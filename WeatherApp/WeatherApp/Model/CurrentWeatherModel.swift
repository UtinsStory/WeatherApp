//
//  CurrentWeatherModel.swift
//  WeatherApp
//
//  Created by Никита Соловьев on 13.05.2025.
//

import Foundation

struct CurrentWeatherModel: Codable {
    let location: Location
    let current: Current
    
    struct Location: Codable {
        let name: String
        let country: String
        let localTime: String
    }
    
    struct Current: Codable {
        let tempC: Double
        let condition: Condition
        let windKph: Double
        let humidity: Int
        
        enum CodingKeys: String, CodingKey {
            case tempC = "temp_c"
            case condition
            case windKph = "wind_kph"
            case humidity
        }
    }
    
    struct Condition: Codable {
        let text: String
        let icon: String
    }
}
