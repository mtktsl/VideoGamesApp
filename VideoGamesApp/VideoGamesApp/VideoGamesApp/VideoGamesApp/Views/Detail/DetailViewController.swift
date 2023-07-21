//
//  DetailViewController.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 18.07.2023.
//

import UIKit
import GridLayout
import NSLayoutConstraintExtensionPackage
import LoadingView

extension DetailViewController {
    fileprivate enum Constants {
        
        static let lightColor = UIColor(
            hue: 210.0/360.0,
            saturation: 0.09,
            brightness: 0.85,
            alpha: 1
        )
        
        static let darkColor = UIColor(
            hue: 203.0/360.0,
            saturation: 0.14,
            brightness: 0.60,
            alpha: 1
        )
        
        static let gameNameFont: UIFont = .boldSystemFont(ofSize: 24)
        static let gameNameTextColor = UIColor.white
        
        static let indicatorFont: UIFont = .systemFont(ofSize: 18)
        static let indicatorTextColor = darkColor
        static let nameTextColor = UIColor(
            hue: 205.0/360,
            saturation: 0.51,
            brightness: 0.92,
            alpha: 1
        )
        
        static let releaseDateTextColor = lightColor
        
        static let descriptionLabelFont: UIFont = .systemFont(ofSize: 16)
        static let descriptionTextColor = lightColor
        
        static let indicatorWidth: CGFloat = 110
        
        static let ratingImageWidth: CGFloat = 25
    }
}

fileprivate extension UIEdgeInsets {
    static let titleMargin = UIEdgeInsets(
        top: 10, left: 10, bottom: 5, right: 10)
    
    static let infoMargin = UIEdgeInsets(
        top: 5, left: 10, bottom: 0, right: 10)
    
    static let descriptionMargin = UIEdgeInsets(10)
    
    static let indicatorMargin = UIEdgeInsets(
        top: 0, left: 0, bottom: 0, right: 10)
    
    static let ratingInnerMargin = UIEdgeInsets(
        top: 0, left: 10, bottom: 0, right: 0)
    
    static let reviewIndicatorMargin = UIEdgeInsets(
        top: 20, left: 10, bottom: 0, right: 10)
}

protocol DetailViewControllerProtocol: AnyObject {
    func setupSubviews()
    func calculateScrollViewContentSize()
    func setupData()
}

final class DetailViewController: UIViewController {
    let gameImageView: UIImageView = {
        let gameImageView = UIImageView()
        gameImageView.contentMode = .scaleToFill
        return gameImageView
    }()
    
    let gameNameLabel: UILabel = {
        let gameNameLabel = UILabel()
        gameNameLabel.font = Constants.gameNameFont
        gameNameLabel.textColor = Constants.gameNameTextColor
        gameNameLabel.numberOfLines = 0
        return gameNameLabel
    }()
    
    let developerIndicatorLabel: UILabel = {
        let developerIndicatorLabel = UILabel()
        developerIndicatorLabel.font = Constants.indicatorFont
        developerIndicatorLabel.textColor = Constants.indicatorTextColor
        return developerIndicatorLabel
    }()
    
    let developerNameLabel: UILabel = {
        let developerNameLabel = UILabel()
        developerNameLabel.font = Constants.indicatorFont
        developerNameLabel.textColor = Constants.nameTextColor
        developerNameLabel.numberOfLines = 0
        return developerNameLabel
    }()
    
    let publisherIndicatorLabel: UILabel = {
        let publisherIndicatorLabel = UILabel()
        publisherIndicatorLabel.font = Constants.indicatorFont
        publisherIndicatorLabel.textColor = Constants.indicatorTextColor
        return publisherIndicatorLabel
    }()
    
    let publisherNameLabel: UILabel = {
        let publisherNameLabel = UILabel()
        publisherNameLabel.font = Constants.indicatorFont
        publisherNameLabel.textColor = Constants.nameTextColor
        publisherNameLabel.numberOfLines = 0
        return publisherNameLabel
    }()
    
    let releaseDateIndicatorLabel: UILabel = {
        let releaseDateIndicatorLabel = UILabel()
        releaseDateIndicatorLabel.font = Constants.indicatorFont
        releaseDateIndicatorLabel.textColor = Constants.indicatorTextColor
        return releaseDateIndicatorLabel
    }()
    
    let releaseDateLabel: UILabel = {
        let releaseDateLabel = UILabel()
        releaseDateLabel.font = Constants.indicatorFont
        releaseDateLabel.textColor = Constants.releaseDateTextColor
        return releaseDateLabel
    }()
    
    
    let reviewsIndicatorLabel: UILabel = {
        let reviewsIndicatorLabel = UILabel()
        reviewsIndicatorLabel.font = Constants.indicatorFont
        reviewsIndicatorLabel.textColor = Constants.indicatorTextColor
        return reviewsIndicatorLabel
    }()
    
    let rawgRatingImageView: UIImageView = {
        let rawgRatingImageView = UIImageView(
            image: UIImage(
                named: ApplicationConstants.ImageAssets.rawg_logo
            )
        )
        rawgRatingImageView.contentMode = .scaleAspectFit
        return rawgRatingImageView
    }()
    
    let rawgTitleLabel: UILabel = {
        let rawgTitleLabel = UILabel()
        rawgTitleLabel.font = Constants.indicatorFont
        rawgTitleLabel.textColor = Constants.releaseDateTextColor
        return rawgTitleLabel
    }()
    
    let rawgRatingLabel: UILabel = {
        let rawRatingLabel = UILabel()
        rawRatingLabel.font = Constants.indicatorFont
        return rawRatingLabel
    }()
    
    let metacriticRatingImageView: UIImageView = {
        let metacriticRatingImageView = UIImageView(
            image: UIImage(
                named: ApplicationConstants.ImageAssets.metacriticlogo
            )
        )
        metacriticRatingImageView.contentMode = .scaleAspectFit
        return metacriticRatingImageView
    }()
    
    let metacriticTitleLabel: UILabel = {
        let metacriticTitleLabel = UILabel()
        metacriticTitleLabel.font = Constants.indicatorFont
        metacriticTitleLabel.textColor = Constants.releaseDateTextColor
        return metacriticTitleLabel
    }()
    
    let metacriticRatingLabel: UILabel = {
        let metacriticRatingLabel = UILabel()
        metacriticRatingLabel.font = Constants.indicatorFont
        return metacriticRatingLabel
    }()
    
    lazy var reviewsContrainerGrid: Grid = {
        let reviewsContainerGrid = Grid.vertical {
            
            Grid.horizontal {
                rawgRatingImageView
                    .Constant(value: Constants.ratingImageWidth)
                rawgTitleLabel
                    .Auto(margin: .ratingInnerMargin)
                rawgRatingLabel
                    .Auto(margin: .ratingInnerMargin)
            }.Expanded(margin: .init(
                top: 10, left: 10, bottom: 5, right: 0)
            )
            
            Grid.horizontal {
                metacriticRatingImageView
                    .Constant(value: Constants.ratingImageWidth)
                metacriticTitleLabel
                    .Auto(margin: .ratingInnerMargin)
                metacriticRatingLabel
                    .Auto(margin: .ratingInnerMargin)
            }.Expanded(margin: .init(
                top: 5, left: 10, bottom: 10, right: 0)
            )
        }
        
        reviewsContainerGrid.layer.masksToBounds = true
        reviewsContainerGrid.layer.cornerRadius = 5
        reviewsContainerGrid.backgroundColor = .appGamesListCellBackgroundColor
        return reviewsContainerGrid
    }()
    
    let descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.font = Constants.descriptionLabelFont
        descriptionLabel.textColor = Constants.descriptionTextColor
        descriptionLabel.numberOfLines = 0
        return descriptionLabel
    }()
    
    let favoritesImageView: UIImageView = {
        let favoritesImageView = UIImageView()
        favoritesImageView.contentMode = .scaleAspectFit
        favoritesImageView.image = UIImage(systemName: ApplicationConstants.SystemImages.heart)
        return favoritesImageView
    }()
    
    let scrollView = UIScrollView()
    
    lazy var mainGrid = Grid.vertical {
        
        gameImageView
            .Constant(value: 200)
        
        gameNameLabel
            .Auto(margin: .titleMargin)
        
        Grid.horizontal {
            developerIndicatorLabel
                .Constant(value: Constants.indicatorWidth,
                          verticalAlignment: .autoTop,
                          margin: .indicatorMargin)
            developerNameLabel
                .Expanded()
        }.Auto(margin: .infoMargin)
        
        Grid.horizontal {
            publisherIndicatorLabel
                .Constant(value: Constants.indicatorWidth,
                          verticalAlignment: .autoTop,
                          margin: .indicatorMargin)
            publisherNameLabel
                .Expanded()
        }.Auto(margin: .infoMargin)
        
        Grid.horizontal {
            releaseDateIndicatorLabel
                .Constant(value: Constants.indicatorWidth,
                          margin: .indicatorMargin)
            releaseDateLabel
                .Expanded()
        }.Auto(margin: .infoMargin)
        
        reviewsIndicatorLabel
            .Auto(margin: .reviewIndicatorMargin)
        
        reviewsContrainerGrid
            .Constant(value: Constants.ratingImageWidth * 4,
                       margin: .descriptionMargin)
        
        descriptionLabel
            .Auto(margin: .descriptionMargin)
    }
    
    var viewModel: DetailViewModelProtocol! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackgroundColor
        setupSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LoadingView.shared.startLoading(
            view.frame,
            cornerRadius: 0
        )
        viewModel.downloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            calculateScrollViewContentSize()
        }
    }
    
    private func setImage(
        for imageView: UIImageView,
        image: UIImage?
    ) {
        DispatchQueue.main.async {
            imageView.image = image
        }
    }
    
    private func setRatingColor() {
        let rawgRating = viewModel.rawgRatingLevel
        let metacriticRating = viewModel.metacriticRatingLevel
        
        var rawgColor: UIColor!
        var metacriticColor: UIColor!
        
        switch rawgRating {
        case .high:
            rawgColor = .ratingHighColor
        case .medium:
            rawgColor = .ratingMediumColor
        case .low:
            rawgColor = .ratingLowColor
        case .none:
            rawgColor = .ratingNilColor
        }
        
        switch metacriticRating {
        case .high:
            metacriticColor = .ratingHighColor
        case .medium:
            metacriticColor = .ratingMediumColor
        case .low:
            metacriticColor = .ratingLowColor
        case .none:
            metacriticColor = .ratingNilColor
        }
        
        rawgRatingLabel.textColor = rawgColor
        metacriticRatingLabel.textColor = metacriticColor
    }
}

extension DetailViewController: DetailViewControllerProtocol {
    func setupSubviews() {
        scrollView.addSubview(mainGrid)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.expand(scrollView, to: view.safeAreaLayoutGuide)
        
        setImage(
            for: gameImageView,
            image: UIImage(named: ApplicationConstants.ImageAssets.loading)
        )
    }
    
    func calculateScrollViewContentSize() {
        let width = scrollView.bounds.size.width
        let height = mainGrid.sizeThatFits(
            .init(
                width: width,
                height: 0
            )
        ).height
        
        let finalSize = CGSize(
            width: width,
            height: height
        )

        scrollView.contentSize = finalSize
        mainGrid.frame = CGRect(
            origin: .zero,
            size: finalSize
        )
    }
    
    func setupData() {
        gameNameLabel.text = viewModel.gameTitle
        
        developerIndicatorLabel.text = viewModel.gameDeveloperIndicator
        developerNameLabel.text = viewModel.gameDeveloper
        
        publisherIndicatorLabel.text = viewModel.gamePublisherIndicator
        publisherNameLabel.text = viewModel.gamePublisher
        
        releaseDateIndicatorLabel.text = viewModel.gameReleaseDateIndicator
        releaseDateLabel.text = viewModel.gameReleaseDate
        
        reviewsIndicatorLabel.text = viewModel.reviewsIndicator
        
        rawgTitleLabel.text = viewModel.rawgRatingText + ":"
        rawgRatingLabel.text = String(viewModel.rawgRating)
        
        metacriticTitleLabel.text = viewModel.metacriticRatingText + ":"
        metacriticRatingLabel.text = String(viewModel.metacriticRating)
        
        descriptionLabel.text = viewModel.gameDescription
    }
}

extension DetailViewController: DetailViewModelDelegate {
    
    func onImageDownloadSuccess(_ imageData: Data) {
        setImage(
            for: gameImageView,
            image: UIImage(data: imageData)
        )
        DispatchQueue.main.async {
            LoadingView.shared.hideLoading()
        }
    }
    
    func onImageDownloadFailure() {
        setImage(
            for: gameImageView,
            image: UIImage(
                systemName: ApplicationConstants.SystemImages.exclamationmarkTriangle
            )
        )
        DispatchQueue.main.async {
            LoadingView.shared.hideLoading()
        }
    }
    
    func onDataDownloadSuccess() {
        viewModel.downloadImage()
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            LoadingView.shared.hideLoading()
            LoadingView.shared.startLoading(on: gameImageView)
            
            setupData()
            setRatingColor()
            calculateScrollViewContentSize()
        }
    }
}
