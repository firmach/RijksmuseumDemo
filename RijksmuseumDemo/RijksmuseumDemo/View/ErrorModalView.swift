//
//  ErrorModalView.swift
//  RijksmuseumDemo
//
//  Created by Roman Churkin on 29/05/2023.
//

import UIKit


final class ErrorModalView: UIView {

    // MARK: - Public properties

    var onRetry: (() -> Void)?


    // MARK: - Private properties

    private let errorMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Retry", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let errorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
        imageView.tintColor = .systemOrange
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()


    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Private helpers

    private func configureView() {
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)

        addSubview(errorImageView)
        addSubview(errorMessageLabel)
        addSubview(retryButton)

        NSLayoutConstraint.activate([
            errorImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            errorImageView.topAnchor.constraint(equalTo: topAnchor, constant: 16),

            errorMessageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            errorMessageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            errorMessageLabel.topAnchor.constraint(equalTo: errorImageView.bottomAnchor, constant: 16),

            retryButton.topAnchor.constraint(equalTo: errorMessageLabel.bottomAnchor, constant: 16),
            retryButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            retryButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    @objc private func retryTapped() { onRetry?() }

    // MARK: - Public methods

    func setErrorMessage(_ message: String?) {
        errorMessageLabel.text = message
    }
}

