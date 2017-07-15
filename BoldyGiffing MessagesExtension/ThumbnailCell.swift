//
//  ThumbnailCell.swift
//  BoldyGiffing MessagesExtension
//
//  Created by Aaron Williams on 2017-07-02.
//  Copyright © 2017 SweetieApps. All rights reserved.
//

import UIKit
import Kingfisher

let thumbmailCellIdentifier = "thumbnailCellReuseIdentifier"

final class ThumbnailCell: UICollectionViewCell {

    // MARK: - UI Elements
    private(set) var imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private(set) var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.activityIndicatorViewStyle = .white
        indicator.isHidden = true
        return indicator
    }()

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        addSubview(imageView)
        addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            imageView.leftAnchor.constraint(equalTo: leftAnchor),
            imageView.rightAnchor.constraint(equalTo: rightAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
            ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        set(loading: false)
    }

    func configure(with gif: Gif) {
        imageView.kf.setImage(with: gif.thumbnailURL)
    }
    
    func set(loading: Bool) {
        imageView.alpha = loading ? 0.3 : 1.0
        if loading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
}
