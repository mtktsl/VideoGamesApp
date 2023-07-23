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
}

extension GamesListCell {
    fileprivate enum Constants {
        static let gameImageMargin = UIEdgeInsets(
            top: 0, left: 0, bottom: 0, right: 10
        )
        static let ratingMargin = UIEdgeInsets(
            top: 0, left: 5, bottom: 0, right: 5
        )
    }
}

protocol GamesListCellProtocol {
    func setupCell()
}

final class GamesListCell: UICollectionViewCell {
    
    static let reuseIdentifier = "GamesListCellReuseIdentifier"
    static let defaultHeight: CGFloat = 90
    
    let gameImageView: UIImageView = {
        let gameImageView = UIImageView()
        gameImageView.contentMode = .scaleToFill
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
                }.Expanded()
                
                Grid.horizontal {
                    metacriticImageView
                        .Constant(value: 23)
                    metacriticRatingLabel
                        .Auto(margin: Constants.ratingMargin)
                }.Expanded()
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
        setupView()
        setupMainGrid()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented for GamesListCell")
    }

    private func setupView() {
        contentView.backgroundColor = .gamesListCellBackgroundColor
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 5
    }
    
    private func setupMainGrid() {
        mainGrid.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainGrid)
        NSLayoutConstraint.expand(mainGrid, to: contentView, padding: .init(5))
    }
    
    private func setImage(
        for imageView: UIImageView,
        image: UIImage?
    ) {
        DispatchQueue.main.async {
            imageView.image = image
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setImage(
            for: gameImageView,
            image: UIImage(named: ApplicationConstants.ImageAssets.loading)
        )
        releasedLabel.text = ""
        rawgRatingLabel.text = "nil"
        metacriticRatingLabel.text = "nil"
    }
}

extension GamesListCell: GamesListCellProtocol {
    func setupCell() {
        guard let data = viewModel.dataModel else { return }
        
        viewModel.downloadGameImage()
        
        titleLabel.text = data.name
        
        if let releaseDate = data.released {
            releasedLabel.text = "RELEASED ON \(releaseDate)"
        }
        
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
        
        rawgRatingLabel.text = String(data.rating ?? 0.0)
        metacriticRatingLabel.text = String(data.metacritic ?? 0)
        mainGrid.setNeedsLayout()
    }
}

extension GamesListCell: GamesListCellViewModelDelegate {
    func onImageResult(_ imageData: Data) {
        setImage(
            for: gameImageView,
            image: UIImage(data: imageData)
        )
    }
    
    func onImageError(_ error: RAWG_NetworkError) {
        setImage(
            for: gameImageView,
            image: UIImage(systemName: ApplicationConstants.SystemImages.exclamationmarkTriangle)
        )
    }
}
