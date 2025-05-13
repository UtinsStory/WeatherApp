//
//  WeatherForecastModel.swift
//  WeatherApp
//
//  Created by Никита Соловьев on 13.05.2025.
//

import Foundation

struct WeatherForecast: Codable {
    let location: CurrentWeatherModel.Location
    let forecast: Forecast
    
    struct Forecast: Codable {
        let forecastday: [ForecastDay]
    }
    
    struct ForecastDay: Codable {
        let date: String
        let day: Day
        let hour: [Hour]
        
        struct Day: Codable {
            let maxtempC: Double
            let mintempC: Double
            let condition: CurrentWeatherModel.Condition
            
            enum CodingKeys: String, CodingKey {
                case maxtempC = "maxtemp_c"
                case mintempC = "mintemp_c"
                case condition
            }
        }
        
        struct Hour: Codable {
            let time: String
            let tempC: Double
            let condition: CurrentWeatherModel.Condition
            
            enum CodingKeys: String, CodingKey {
                case time
                case tempC = "temp_c"
                case condition
            }
        }
    }
}
