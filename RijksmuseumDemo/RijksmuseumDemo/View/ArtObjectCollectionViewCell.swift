//
//  ArtObjectCollectionViewCell.swift
//  RijksmuseumDemo
//
//  Created by Roman Churkin on 29/05/2023.
//

import UIKit
import Kingfisher


final class ArtObjectCollectionViewCell: UICollectionViewCell {

    // MARK: - Public properties

    var preferredLayout: CollectionPreferredLayout = .row {
        didSet {
            guard oldValue != preferredLayout else { return }
            
            switch preferredLayout {
            case .row:
                titleLabel.isHidden = false
                subtitleLabel.isHidden = false
            case .grid:
                titleLabel.isHidden = true
                subtitleLabel.isHidden = true
            }
            update(for: preferredLayout)
            self.layoutIfNeeded()
        }
    }


    // MARK: - Private properties

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.kf.indicatorType = .activity
        imageView.backgroundColor = .placeholderText
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .left
        titleLabel.font = .preferredFont(forTextStyle: .title2)
        titleLabel.numberOfLines = 3
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()

    private let subtitleLabel: UILabel = {
        let subtitleLabel = UILabel()
        subtitleLabel.textAlignment = .left
        subtitleLabel.font = .preferredFont(forTextStyle: .callout)
        subtitleLabel.numberOfLines = 2
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        return subtitleLabel
    }()

    private var gridModeConstraints: [NSLayoutConstraint]!
    private var rowModeConstraints: [NSLayoutConstraint]!


    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)

        gridModeConstraints = buildGridModConstraints()
        rowModeConstraints = buildRowModeConstraints()

        update(for: preferredLayout)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods

    private func update(for preferredLayout: CollectionPreferredLayout) {
        switch preferredLayout{
        case .row:
            imageView.setContentHuggingPriority(.defaultHigh, for: .vertical)
            imageView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
            NSLayoutConstraint.deactivate(gridModeConstraints)
            NSLayoutConstraint.activate(rowModeConstraints)
        case .grid:
            imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
            imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
            titleLabel.setContentHuggingPriority(.required, for: .vertical)
            subtitleLabel.setContentHuggingPriority(.required, for: .vertical)
            NSLayoutConstraint.deactivate(rowModeConstraints)
            NSLayoutConstraint.activate(gridModeConstraints)
        }
    }


    // MARK: - Helpers

    private func buildGridModConstraints() -> [NSLayoutConstraint] {[
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
    ]}

    private func buildRowModeConstraints() -> [NSLayoutConstraint] {[
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

        titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

        subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
        subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
    ]}


    // MARK: - Public methods

    func configure(with artObject: ArtObject) {
        let imageProcessor = DownsamplingImageProcessor(size: imageView.bounds.size)
        imageView.kf.setImage(
            with: URL(string: artObject.webImage.url),
            options: [
                .processor(imageProcessor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.5)),
                .cacheOriginalImage
            ]
        )

        titleLabel.text = artObject.title
        subtitleLabel.text = artObject.principalOrFirstMaker
    }

    override func prepareForReuse() {
        imageView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
    }

}

