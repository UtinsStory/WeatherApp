//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Никита Соловьев on 13.05.2025.
//

import UIKit
import CoreLocation

final class WeatherViewModel: NSObject {
    
    private let weatherService: WeatherServiceProtocol
    private let locationManager = CLLocationManager()
    
    private var currentWeather: CurrentWeatherModel?
    private var forecast: WeatherForecastModel?
    
    var onUpdate: (() -> Void)?
    
    init(weatherService: WeatherServiceProtocol) {
        self.weatherService = WeatherService()
        locationManager.delegate = self
    }
    
    func requestWeatherForCurrentLocation() {
        locationManager.requestWhenInUseAuthorization()
        
        switch locationManager.authorizationStatus {
            
        case .notDetermined:
            break
        case .restricted:
            Task { try await fetchWeather(lat: Constants.moscowLat, lon: Constants.moscowLon) }
        case .denied:
            Task { try await fetchWeather(lat: Constants.moscowLat, lon: Constants.moscowLon) }
        case .authorizedAlways:
            locationManager.requestLocation()
        case .authorizedWhenInUse:
            locationManager.requestLocation()
        @unknown default:
            Task { try await fetchWeather(lat: Constants.moscowLat, lon: Constants.moscowLon) }
        }
    }
    
    func fetchWeather(lat: Double, lon: Double) async throws {
        do {
            async let current = try await weatherService.fetchCurrentWeather(lat: lat, lon: lon)
            async let forecast = try await weatherService.fetchWeatherForecast(lat: lat, lon: lon, days: 7)
            
            self.currentWeather = try await current
            self.forecast = try await forecast
            
            DispatchQueue.main.async { [weak self] in
                self?.onUpdate?()
            }
        } catch {
            throw WeatherServiceError.networkError(error)
        }
    }
    
    var cityName: String {
        currentWeather?.location.name ?? "Неизвестно"
    }
    
    var temperature: String {
        guard let temp = currentWeather?.current.tempC else { return "--" }
        return "\(Int(temp))°"
    }
    
    var conditionText: String {
        currentWeather?.current.condition.text ?? ""
    }
}

extension WeatherViewModel: CLLocationManagerDelegate {
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else {
            Task { try await fetchWeather(lat: Constants.moscowLat, lon: Constants.moscowLon) }
            return
        }
        
        Task {
            try await fetchWeather(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
        }
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print("Не удалось определить геолокацию: \(error.localizedDescription)")
        Task {
            try await fetchWeather(lat: Constants.moscowLat, lon: Constants.moscowLon)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        requestWeatherForCurrentLocation()
    }
}

struct Constants {
    static let moscowLat: Double = 55.751244
    static let moscowLon: Double = 37.618423
}

