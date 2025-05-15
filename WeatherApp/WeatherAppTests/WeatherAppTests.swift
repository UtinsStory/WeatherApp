//
//  WeatherAppTests.swift
//  WeatherAppTests
//
//  Created by Никита Соловьев on 15.05.2025.
//

import XCTest
@testable import WeatherApp

final class WeatherAppTests: XCTestCase {
    
    var weatherService: MockWeatherService!
    var viewModel: WeatherViewModelProtocol!
    
    override func setUp() {
        super.setUp()
        weatherService = MockWeatherService()
        viewModel = WeatherViewModel(weatherService: weatherService)
    }
    
    override func tearDown() {
        weatherService = nil
        viewModel = nil
        super.tearDown()
    }
    
    func testWeatherFetchSucceeds() async {
        // Given
        let expectation = XCTestExpectation(description: "onUpdate called")
        viewModel.onUpdate = { expectation.fulfill() }

        // When
        try? await viewModel.fetchWeather(lat: 55.75, lon: 37.61)

        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(viewModel.cityName, "Москва")
        XCTAssertEqual(viewModel.temperature, "20°")
        XCTAssertEqual(viewModel.conditionText, "Ясно")
    }

    func testWeatherFetchFails() async {
        // Given
        weatherService.shouldFail = true
        let expectation = expectation(description: "Error callback called")
        viewModel.onError = { error in
            XCTAssertTrue(error.contains("Данные с сервера не получены"))
            expectation.fulfill()
        }
        // When
        do {
            try await viewModel.fetchWeather(lat: 0, lon: 0)
        } catch {
            // Ошибка ожидается
        }
        // Then
        await fulfillment(of: [expectation], timeout: 1)
    }
}
