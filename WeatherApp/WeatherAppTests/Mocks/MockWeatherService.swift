//
//  MockWeatherService.swift
//  WeatherAppTests
//
//  Created by Никита Соловьев on 15.05.2025.
//

import Foundation
import XCTest
@testable import WeatherApp

final class MockWeatherService: WeatherServiceProtocol {
    var shouldFail = false
    
    func fetchCurrentWeather(lat: Double, lon: Double) async throws -> CurrentWeatherModel {
        if shouldFail { throw WeatherServiceError.noData }
        return .init(
            location: .init(name: "Москва", country: "Россия", localTime: "2025-05-15 12:00"),
            current: .init(tempC: 20, condition: .init(text: "Ясно", icon: "//icon.png"), windKph: 5, humidity: 60)
        )
    }
    
    func fetchWeatherForecast(lat: Double, lon: Double, days: Int) async throws -> WeatherForecastModel {
        if shouldFail { throw WeatherServiceError.noData }
        return .init(
            location: .init(name: "Москва", country: "Россия", localTime: "2025-05-15 12:00"),
            forecast: .init(forecastday: [])
        )
    }
}
