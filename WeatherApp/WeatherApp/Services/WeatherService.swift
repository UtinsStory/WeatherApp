//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Никита Соловьев on 13.05.2025.
//

import Foundation

enum WeatherServiceError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case noData
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный URL запроса."
        case .networkError(let error):
            return "Ошибка сети: \(error.localizedDescription)"
        case .noData:
            return "Данные с сервера не получены."
        case .decodingError(let error):
            return "Ошибка декодирования ответа: \(error.localizedDescription)"
        }
    }
}

protocol WeatherServiceProtocol {
    func fetchCurrentWeather(
        lat: Double,
        lon: Double
    ) async throws -> CurrentWeatherModel
    
    func fetchWeatherForecast(
        lat: Double,
        lon: Double,
        days: Int
    ) async throws -> WeatherForecastModel
}

final class WeatherService: WeatherServiceProtocol {
    
    private let apiKey = "fa8b3df74d4042b9aa7135114252304"
    private let baseURL = "https://api.weatherapi.com/v1/"
    
    func fetchCurrentWeather(
        lat: Double,
        lon: Double
    ) async throws -> CurrentWeatherModel {
        let urlString = "\(baseURL)current.json?key=\(apiKey)&q=\(lat),\(lon)"
        guard let url = URL(string: urlString) else {
            throw WeatherServiceError.invalidURL
        }
        
        let (data,_) = try await URLSession.shared.data(from: url)
        do {
            let weather = try JSONDecoder().decode(CurrentWeatherModel.self, from: data)
            return weather
        } catch {
            throw WeatherServiceError.decodingError(error)
        }
    }
    
    func fetchWeatherForecast(
        lat: Double,
        lon: Double,
        days: Int
    ) async throws -> WeatherForecastModel {
        let urlString = "\(baseURL)forecast.json?key=\(apiKey)&q=\(lat),\(lon)&days=\(days)&lang=ru"
        guard let url = URL(string: urlString) else {
            throw WeatherServiceError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        do {
            let forecast = try JSONDecoder().decode(WeatherForecastModel.self, from: data)
            return forecast
        } catch {
            throw WeatherServiceError.decodingError(error)
        }
    }
}
