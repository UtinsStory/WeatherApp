//
//  HourForecastCollectionViewCell.swift
//  WeatherApp
//
//  Created by Никита Соловьев on 13.05.2025.
//

import UIKit

final class HourForecastCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "HourForecastCollectionViewCell"
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white
        label.textAlignment = .center
        
        return label
    }()
    
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white
        label.textAlignment = .center
        
        return label
    }()
    
    private lazy var conditionImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        
        return image
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            timeLabel,
            conditionImageView,
            temperatureLabel
        ])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 6
        
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            conditionImageView.widthAnchor.constraint(equalToConstant: 40),
            conditionImageView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func configure(
        with model: WeatherForecastModel.ForecastDay.Hour,
        viewModel: WeatherViewModelProtocol
    ) {
        timeLabel.text = String(model.time.suffix(5))
        temperatureLabel.text = "\(Int(model.tempC))°"
        conditionImageView.image = nil
        
        Task {
            if let image = await viewModel.loadWeatherIcon(for: model.condition.icon) {
                DispatchQueue.main.async { [weak self] in
                    self?.conditionImageView.image = image
                }
            }
        }
    }
}
