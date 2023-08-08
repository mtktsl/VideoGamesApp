//
//  GamesListCell.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 15.07.2023.
//

import UIKit
import RAWG_API
import GridLayout
import NSLayoutConstraintExtensionPackage

fileprivate extension UIColor {
    static let titleLabelColor = UIColor(
        hue: 222 / maxHueValue,
        saturation: 0.07,
        brightness: 0.95,
        alpha: 1
    )
    
    static let releaseLabelColor = UIColor(
        hue: 222 / maxHueValue,
        saturation: 0.15,
        brightness: 0.59,
        alpha: 1
    )
    
    static let gamesListCellBackgroundColor = UIColor(
        hue: 219 / maxHueValue,
        saturation: 0.34,
        brightness: 0.27,
        alpha: 1
    )
    
    static let seenIndicatorColor = UIColor.systemOrange
}

extension GamesListCell {
    fileprivate enum Constants {
        
        static let mainGridPadding = UIEdgeInsets(5)
        
        static let gameImageMargin = UIEdgeInsets(
            top: 0, left: 0, bottom: 0, right: 10
        )
        static let ratingMargin = UIEdgeInsets(
            top: 0, left: 5, bottom: 0, right: 5
        )
        static let seenIndicatorMargin = UIEdgeInsets(
            top: 5, left: 0, bottom: 0, right: 5)
        
        static let seenIndicatorSize: CGFloat = 15
    }
}

protocol GamesListCellProtocol {
    func setupCell()
    func setupSubviews()
}

final class GamesListCell: UICollectionViewCell {
    
    static var cellCount = 0
    
    static let reuseIdentifier = "GamesListCellReuseIdentifier"
    static let defaultHeight: CGFloat = 90
    
    let gameImageView: UIImageView = {
        let gameImageView = UIImageView()
        gameImageView.contentMode = .scaleAspectFit
        gameImageView.layer.masksToBounds = true
        gameImageView.image = UIImage(
            named: ApplicationConstants.ImageAssets.loading
        )
        return gameImageView
    }()
    
    let rawgImageView: UIImageView = {
        let rawgImageView = UIImageView()
        rawgImageView.contentMode = .scaleAspectFit
        rawgImageView.image = UIImage(
            named: ApplicationConstants.ImageAssets.rawg_logo
        )
        return rawgImageView
    }()
    
    let rawgRatingLabel: UILabel = {
        let rawgRatingLabel = UILabel()
        rawgRatingLabel.font = .systemFont(ofSize: 14)
        return rawgRatingLabel
    }()
    
    let metacriticImageView: UIImageView = {
        let metacriticImageView = UIImageView()
        metacriticImageView.contentMode = .scaleAspectFit
        metacriticImageView.image = UIImage(
            named: ApplicationConstants.ImageAssets.metacriticlogo
        )
        return metacriticImageView
    }()
    
    let metacriticRatingLabel: UILabel = {
        let metacriticLabel = UILabel()
        metacriticLabel.font = .systemFont(ofSize: 14)
        return metacriticLabel
    }()
    
    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = .titleLabelColor
        titleLabel.font = .systemFont(ofSize: 16)
        return titleLabel
    }()
    
    let releasedLabel: UILabel = {
        let releasedLabel = UILabel()
        releasedLabel.textColor = .releaseLabelColor
        releasedLabel.font = .systemFont(ofSize: 14)
        return releasedLabel
    }()
    
    let seenIndicatorView: UIView = {
        let seenIndicator = UIView()
        seenIndicator.backgroundColor = .seenIndicatorColor
        seenIndicator.layer.cornerRadius = Constants.seenIndicatorSize / 2
        seenIndicator.clipsToBounds = true
        return seenIndicator
    }()
    
    lazy var mainGrid = Grid.horizontal {
        gameImageView
            .Constant(value: 150, margin: Constants.gameImageMargin)
        
        Grid.vertical {
            titleLabel
                .Auto()
            releasedLabel
                .Expanded()
            
            Grid.horizontal {
                Grid.horizontal {
                    rawgImageView
                        .Constant(value: 23)
                    rawgRatingLabel
                        .Auto(margin: Constants.ratingMargin)
                }.Auto()
                
                Grid.horizontal {
                    metacriticImageView
                        .Constant(value: 23)
                    metacriticRatingLabel
                        .Auto(margin: Constants.ratingMargin)
                }.Auto(margin: .init(
                    top: 0, left: 30, bottom: 0, right: 0))
            }.Expanded()
            
        }.Expanded()
    }
    
    var viewModel: GamesListCellViewModelProtocol! {
        didSet {
            viewModel.delegate = self
            setupCell()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onIsSeenChanged(_:)),
            name: CoreDataManager.NotificationNames.newItem,
            object: nil
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented for GamesListCell")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        gameImageView.setImageAsync(
            UIImage(named: ApplicationConstants.ImageAssets.loading),
            newContentMode: .scaleAspectFit
        )
        releasedLabel.text = ""
        rawgRatingLabel.text = "nil"
        metacriticRatingLabel.text = "nil"
    }
    
    @objc private func onIsSeenChanged(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            seenIndicatorView.isHidden = !viewModel.isSeen
        }
    }

    private func setupContentView() {
        contentView.backgroundColor = .gamesListCellBackgroundColor
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 5
    }
    
    private func setupMainGrid() {
        mainGrid.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainGrid)
        NSLayoutConstraint.expand(
            mainGrid,
            to: contentView,
            padding: Constants.mainGridPadding
        )
    }
    
    
    private func setupIndicatorView() {
        seenIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(seenIndicatorView)
        NSLayoutConstraint.activate([
            seenIndicatorView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Constants.seenIndicatorMargin.top
            ),
            seenIndicatorView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.seenIndicatorMargin.right
            ),
            seenIndicatorView.widthAnchor.constraint(
                equalToConstant: Constants.seenIndicatorSize
            ),
            seenIndicatorView.heightAnchor.constraint(
                equalToConstant: Constants.seenIndicatorSize
            )
        ])
        contentView.sendSubviewToBack(seenIndicatorView)
    }
    
    private func setRawgColor() {
        switch viewModel.rawgRating {
        case .high:
            rawgRatingLabel.textColor = .ratingHighColor
        case .medium:
            rawgRatingLabel.textColor = .ratingMediumColor
        case .low:
            rawgRatingLabel.textColor = .ratingLowColor
        case .none:
            rawgRatingLabel.textColor = .ratingNilColor
        }
    }
    
    private func setMetacriticColor() {
        switch viewModel.metacriticRating {
        case .high:
            metacriticRatingLabel.textColor = .ratingHighColor
        case .medium:
            metacriticRatingLabel.textColor = .ratingMediumColor
        case .low:
            metacriticRatingLabel.textColor = .ratingLowColor
        case .none:
            metacriticRatingLabel.textColor = .ratingNilColor
        }
    }
}

extension GamesListCell: GamesListCellProtocol {
    func setupCell() {
        guard let data = viewModel.dataModel else { return }
        
        titleLabel.text = data.name
        
        if let releaseDate = data.released {
            releasedLabel.text = "RELEASED ON \(releaseDate)"
        }
        
        setRawgColor()
        setMetacriticColor()
        
        rawgRatingLabel.text = String(data.rating ?? 0.0)
        metacriticRatingLabel.text = String(data.metacritic ?? 0)
        
        seenIndicatorView.isHidden = !viewModel.isSeen
        
        mainGrid.setNeedsLayout()
        
        viewModel.downloadGameImage()
    }
    
    func setupSubviews() {
        setupContentView()
        setupMainGrid()
        setupIndicatorView()
    }
}

extension GamesListCell: GamesListCellViewModelDelegate {
    func onImageResult(_ imageData: Data) {
        gameImageView.setImageAsync(
            UIImage(data: imageData)
        )
    }
    
    func onImageError(_ error: RAWG_NetworkError) {
        gameImageView.setImageAsync(
            UIImage(systemName: ApplicationConstants
                .SystemImages
                .exclamationmarkTriangle),
            newContentMode: .scaleAspectFit
        )
    }
}
