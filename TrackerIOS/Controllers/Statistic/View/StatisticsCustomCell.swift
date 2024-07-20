//
//  StatisticsCustomCell.swift
//  TrackerIOS
//
//  Created by Олег Серебрянский on 7/19/24.
//

import UIKit

final class StatisticsCustomCell: UITableViewCell {

    static let identifier = "StatisticsCustomCell"

    lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        return label
    }()
    lazy var  titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()

    lazy var rainbowFrame: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()

    let colors: [CGColor] = [
        AppColors.gradient1 ?? UIColor.red.cgColor,
        AppColors.gradient2 ?? UIColor.red.cgColor,
        AppColors.gradient3 ?? UIColor.red.cgColor
    ]

    lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = colors
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        return layer
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellDesign()
    }

    func setupCellDesign() {

        contentView.backgroundColor = .systemBackground

        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.addArrangedSubview(numberLabel)
        stack.addArrangedSubview(titleLabel)

        let mainView: UIView = {
            let view = UIView()
            view.backgroundColor = .systemBackground
            view.layer.cornerRadius = 16
            return view
        }()

        rainbowFrame.layer.insertSublayer(gradientLayer, at: 0)

        contentView.addSubViews([rainbowFrame, mainView, stack])

        NSLayoutConstraint.activate([
            rainbowFrame.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            rainbowFrame.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            rainbowFrame.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            rainbowFrame.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            mainView.topAnchor.constraint(equalTo: rainbowFrame.topAnchor, constant: 1),
            mainView.leadingAnchor.constraint(equalTo: rainbowFrame.leadingAnchor, constant: 1),
            mainView.trailingAnchor.constraint(equalTo: rainbowFrame.trailingAnchor, constant: -1),
            mainView.bottomAnchor.constraint(equalTo: rainbowFrame.bottomAnchor, constant: -1),

            stack.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 11),
            stack.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 11),
            stack.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -11),
            stack.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -11)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = rainbowFrame.bounds
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
