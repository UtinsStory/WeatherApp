//
//  WeeklyForecastTableViewCell.swift
//  WeatherApp
//
//  Created by Никита Соловьев on 13.05.2025.
//

import UIKit

final class WeeklyForecastTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "WeeklyForecastTableViewCell"
    
    private let viewModel = WeatherViewModel()
    
    private lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white
        
        return label
    }()
    
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white
        label.textAlignment = .right
        
        return label
    }()
    
    private lazy var conditionImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        image.widthAnchor.constraint(equalToConstant: 40).isActive = true
        image.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        return image
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            dayLabel,
            conditionImageView,
            temperatureLabel
        ])
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        stack.distribution = .equalSpacing
        
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(with model: WeatherForecastModel.ForecastDay) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: model.date) {
            let weekdayFormatter = DateFormatter()
            weekdayFormatter.locale = Locale(identifier: "ru_RU")
            weekdayFormatter.dateFormat = "E"
            dayLabel.text = weekdayFormatter.string(from: date).capitalized
        } else {
            dayLabel.text = model.date
        }
        
        temperatureLabel.text = "\(Int(model.day.maxtempC))° / \(Int(model.day.mintempC))°"
        conditionImageView.image = nil
        
        Task {
            if let image = await viewModel.loadWeatherIcon(for: model.day.condition.icon) {
                DispatchQueue.main.async { [weak self] in
                    self?.conditionImageView.image = image
                }
            }
        }
    }
}
