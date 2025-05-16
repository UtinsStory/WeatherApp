//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Никита Соловьев on 13.05.2025.
//

import UIKit
import CoreLocation

@MainActor
protocol WeatherViewModelProtocol: AnyObject {
    var onUpdate: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var cityName: String { get }
    var temperature: String { get }
    var conditionText: String { get }
    var todayAndTomorrowHours: [WeatherForecastModel.ForecastDay.Hour] { get }
    var forecast: WeatherForecastModel? { get }
    var isLocationPermissionGranted: Bool { get }
    
    func requestWeatherForCurrentLocation()
    func fetchWeather(lat: Double, lon: Double) async throws
    func loadWeatherIcon(for iconPath: String) async -> UIImage?
}

final class WeatherViewModel: NSObject, WeatherViewModelProtocol {
    
    private let weatherService: WeatherServiceProtocol
    private let locationManager = CLLocationManager()
    
    private var currentWeather: CurrentWeatherModel?
    var forecast: WeatherForecastModel?
    var isLocationPermissionGranted: Bool = true
    
    var onUpdate: (() -> Void)?
    var onError: ((String) -> Void)?
    
    init(weatherService: WeatherServiceProtocol = WeatherService()) {
        self.weatherService = weatherService
        super.init()
        locationManager.delegate = self
    }
    
    func requestWeatherForCurrentLocation() {
        locationManager.requestWhenInUseAuthorization()
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            break
        case .restricted, .denied:
            isLocationPermissionGranted = false
            DispatchQueue.main.async { [weak self] in
                self?.onError?("Доступ к геолокации запрещён. Используется погода для Москвы.")
            }
        case .authorizedAlways, .authorizedWhenInUse:
            isLocationPermissionGranted = true
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
            DispatchQueue.main.async { [weak self] in
                self?.onError?(error.localizedDescription)
            }
            throw error
        }
    }
    
    func loadWeatherIcon(for iconPath: String) async -> UIImage? {
        let fullURLString = "https:\(iconPath)"
        guard let url = URL(string: fullURLString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            return nil
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
    
    var todayAndTomorrowHours: [WeatherForecastModel.ForecastDay.Hour] {
        guard let forecastDays = forecast?.forecast.forecastday else { return [] }
        guard forecastDays.count >= 2 else { return [] }
        
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let todayHours = forecastDays[0].hour.filter {
            guard let hourDate = formatter.date(from: $0.time) else { return false }
            return hourDate >= now
        }
        
        let tomorrowHours = forecastDays[1].hour
        return todayHours + tomorrowHours
    }
    
}

extension WeatherViewModel: CLLocationManagerDelegate {
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else {
            DispatchQueue.main.async { [weak self] in
                self?.onError?("Не удалось получить координаты")
            }
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
        DispatchQueue.main.async { [weak self] in
            self?.onError?("Не удалось определить местоположение: \(error.localizedDescription)")
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            break
        case .restricted, .denied:
            isLocationPermissionGranted = false
            DispatchQueue.main.async { [weak self] in
                self?.onError?("Доступ к геолокации запрещён. Используется погода для Москвы.")
            }
        case .authorizedAlways, .authorizedWhenInUse:
            isLocationPermissionGranted = true
            locationManager.requestLocation()
        @unknown default:
            isLocationPermissionGranted = false
            DispatchQueue.main.async { [weak self] in
                self?.onError?("Неизвестный статус геолокации. Используется погода для Москвы.")
            }
        }
    }
}

struct Constants {
    static let moscowLat: Double = 55.751244
    static let moscowLon: Double = 37.618423
}

