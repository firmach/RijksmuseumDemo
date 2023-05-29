//
//  CollectionHeaderView.swift
//  RijksmuseumDemo
//
//  Created by Roman Churkin on 29/05/2023.
//

import UIKit


final class CollectionHeaderView: UICollectionReusableView {

    // MARK: - Private  properties

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()


    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Public methods

    func configure(with text: String) {
        titleLabel.text = text
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }

}
