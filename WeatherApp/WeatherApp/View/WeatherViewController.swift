//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Никита Соловьев on 13.05.2025.
//

import UIKit

final class WeatherViewController: UIViewController {
    
    private let viewModel: WeatherViewModel
    
    private var hourlyForecast: [WeatherForecastModel.ForecastDay.Hour] = []
    private var weeklyForecast: [WeatherForecastModel.ForecastDay] = []
    
    private lazy var cityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 36, weight: .bold)
        label.textColor = .white
        
        return label
    }()
    
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 48, weight: .bold)
        label.textColor = .white
        
        return label
    }()
    
    private lazy var conditionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .regular)
        label.textColor = .white
        
        return label
    }()
    
    private lazy var backgroundView: UIView = {
        let view = UIView()
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor.systemBlue.cgColor, UIColor.systemIndigo.cgColor]
        gradient.locations = [0.0, 1.0]
        view.layer.insertSublayer(gradient, at: 0)
        
        return view
    }()
    
    private lazy var hourForecastCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(HourForecastCollectionViewCell.self, forCellWithReuseIdentifier: HourForecastCollectionViewCell.reuseIdentifier)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        
        return collectionView
    }()
    
    private lazy var weeklyForecastTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            WeeklyForecastTableViewCell.self,
            forCellReuseIdentifier: WeeklyForecastTableViewCell.reuseIdentifier
        )
        tableView.backgroundColor = .clear
        
        return tableView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Повторить", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    init(viewModel: WeatherViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        startLoading()
        viewModel.requestWeatherForCurrentLocation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Обновляем frame градиента при изменении размеров backgroundView
        if let gradientLayer = backgroundView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = backgroundView.bounds
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .clear
        [
            backgroundView,
            cityLabel,
            temperatureLabel,
            conditionLabel,
            hourForecastCollectionView,
            weeklyForecastTableView,
            activityIndicator,
            errorLabel,
            retryButton
        ].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            cityLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cityLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cityLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            temperatureLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 10),
            temperatureLabel.leadingAnchor.constraint(equalTo: cityLabel.leadingAnchor),
            temperatureLabel.trailingAnchor.constraint(equalTo: cityLabel.trailingAnchor),
            
            conditionLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 10),
            conditionLabel.leadingAnchor.constraint(equalTo: cityLabel.leadingAnchor),
            conditionLabel.trailingAnchor.constraint(equalTo: cityLabel.trailingAnchor),
            
            hourForecastCollectionView.topAnchor.constraint(equalTo: conditionLabel.bottomAnchor, constant: 20),
            hourForecastCollectionView.leadingAnchor.constraint(equalTo: cityLabel.leadingAnchor),
            hourForecastCollectionView.trailingAnchor.constraint(equalTo: cityLabel.trailingAnchor),
            hourForecastCollectionView.heightAnchor.constraint(equalToConstant: 100),
            
            weeklyForecastTableView.topAnchor.constraint(equalTo: hourForecastCollectionView.bottomAnchor, constant: 10),
            weeklyForecastTableView.leadingAnchor.constraint(equalTo: cityLabel.leadingAnchor),
            weeklyForecastTableView.trailingAnchor.constraint(equalTo: cityLabel.trailingAnchor),
            weeklyForecastTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            retryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            retryButton.widthAnchor.constraint(equalToConstant: 100),
            retryButton.heightAnchor.constraint(equalToConstant: 44)
            
        ])
        
    }
    
    private func updateGradientForWeather(condition: String?) {
            guard let gradientLayer = backgroundView.layer.sublayers?.first as? CAGradientLayer else { return }
            
            let colors: [CGColor]
            switch condition?.lowercased() {
            case "sunny", "clear", "ясно", "солнечно":
                colors = [UIColor.systemYellow.cgColor, UIColor.systemBlue.cgColor]
            case "cloudy", "overcast", "облачно", "пасмурно":
                colors = [UIColor.systemGray.cgColor, UIColor.systemGray2.cgColor]
            case "rain", "shower", "дождь":
                colors = [UIColor.systemBlue.cgColor, UIColor.systemGray.cgColor]
            case "partly cloudy", "переменная облачность":
                colors = [UIColor.systemBlue.cgColor, UIColor.systemGray.cgColor]
            default:
                colors = [UIColor.systemBlue.cgColor, UIColor.systemIndigo.cgColor]
            }
            
            gradientLayer.colors = colors
            
            let colorAnimation = CABasicAnimation(keyPath: "colors")
            colorAnimation.fromValue = colors
            colorAnimation.toValue = colors.reversed()
            colorAnimation.duration = 5.0
            colorAnimation.autoreverses = true
            colorAnimation.repeatCount = .infinity
            gradientLayer.add(colorAnimation, forKey: "colorAnimation")
        }
    
    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            guard let self = self else { return }
            self.cityLabel.text = viewModel.cityName
            self.temperatureLabel.text = viewModel.temperature
            self.conditionLabel.text = viewModel.conditionText
            self.hourlyForecast = self.viewModel.todayAndTomorrowHours
            self.weeklyForecast = self.viewModel.forecast?.forecast.forecastday ?? []
            self.hourForecastCollectionView.reloadData()
            self.weeklyForecastTableView.reloadData()
            self.updateGradientForWeather(condition: self.viewModel.conditionText)
            self.stopLoading()
            self.hideError()
        }
        
        viewModel.onError = { [weak self] message in
            guard let self = self else { return }
            self.showError(message)
            self.stopLoading()
        }
    }
    
    private func startLoading() {
        activityIndicator.startAnimating()
        [
            cityLabel,
            temperatureLabel,
            conditionLabel,
            hourForecastCollectionView,
            weeklyForecastTableView
        ].forEach { $0.isHidden = true }
        errorLabel.isHidden = true
        retryButton.isHidden = true
    }
    
    private func stopLoading() {
        activityIndicator.stopAnimating()
        [
            cityLabel,
            temperatureLabel,
            conditionLabel,
            hourForecastCollectionView,
            weeklyForecastTableView
        ].forEach { $0.isHidden = false }
    }
    
    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
        retryButton.isHidden = false
        [
            cityLabel,
            temperatureLabel,
            conditionLabel,
            hourForecastCollectionView,
            weeklyForecastTableView
        ].forEach { $0.isHidden = true }
        activityIndicator.stopAnimating()
    }
    
    private func hideError() {
        errorLabel.isHidden = true
        retryButton.isHidden = true
    }
    
    @objc private func retryButtonTapped() {
        startLoading()
        viewModel.requestWeatherForCurrentLocation()
    }
}

// MARK: - UICollectionViewDataSource
extension WeatherViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        hourlyForecast.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HourForecastCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? HourForecastCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let hourModel = hourlyForecast[indexPath.item]
        cell.configure(with: hourModel)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension WeatherViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: 60, height: collectionView.bounds.height)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 12
    }
}

// MARK: - UITableViewDataSource
extension WeatherViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        weeklyForecast.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: WeeklyForecastTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? WeeklyForecastTableViewCell else {
            return UITableViewCell()
        }
        let dayModel = weeklyForecast[indexPath.row]
        cell.configure(with: dayModel)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension WeatherViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.cornerRadius = 8
        cell.layer.masksToBounds = true
        cell.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        
        let margins = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20)
        cell.contentView.frame = cell.contentView.frame.inset(by: margins)
    }
}

