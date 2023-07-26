//
//  FavoritesViewController.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 15.07.2023.
//

import UIKit
import GridLayout
import NSLayoutConstraintExtensionPackage

fileprivate extension UIEdgeInsets {
    static let searchFieldMargin = UIEdgeInsets(10)
    static let searchImageViewMargin = UIEdgeInsets(
        top: 0, left: 0, bottom: 0, right: 10
    )
    
    static let collectionViewMargin = UIEdgeInsets(10)
}

extension FavoritesViewController {
    fileprivate enum Constants {
        static let notFoundText = "Ooops. We could not find the game you are looking for."
        
        static let notFoundImageHeight: CGFloat = 200
    }
}

protocol FavoritesViewControllerProtocol {
    func setupViews()
}

final class FavoritesViewController: UIViewController {
    
    lazy var searchField: UITextField = {
        let searchField = UITextField()
        searchField.backgroundColor = .clear
        searchField.font = .preferredFont(forTextStyle: .title2)
        searchField.textColor = .white
        
        searchField.attributedPlaceholder = NSAttributedString(
            string: viewModel.viewControllerTitle,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.searchTintColor]
        )
        
        searchField.addTarget(
            self,
            action: #selector(searchDidChange(_:)),
            for: .editingChanged
        )
        
        searchField.delegate = self
        
        return searchField
    }()
    
    let searchImageView: UIImageView = {
        let searchImageView = UIImageView()
        searchImageView.image = UIImage(systemName: ApplicationConstants.SystemImages.magnifyingGlass)
        searchImageView.contentMode = .scaleAspectFit
        searchImageView.tintColor = .searchTintColor
        return searchImageView
    }()
    
    lazy var searchBar: Grid = {
        let container = Grid.horizontal {
            searchField
                .Expanded(margin: .searchFieldMargin)
            searchImageView
                .Constant(value: 35,
                          margin: .searchImageViewMargin)
        }
        
        container.backgroundColor = .searchBackgroundColor
        
        return container
    }()
    
    let notFoundImage: UIImageView = {
        let notFoundImage = UIImageView(
            image: UIImage(systemName: ApplicationConstants.SystemImages.eyeSlashCircle)
        )
        notFoundImage.contentMode = .scaleAspectFit
        notFoundImage.tintColor = .white
        return notFoundImage
    }()
    
    let notFoundLabel: UILabel = {
        let notFoundLabel = UILabel()
        notFoundLabel.text = Constants.notFoundText
        notFoundLabel.textColor = .white
        notFoundLabel.textAlignment = .center
        notFoundLabel.numberOfLines = 0
        return notFoundLabel
    }()
    
    lazy var notFoundView = Grid.vertical {
        notFoundImage
            .Constant(value: Constants.notFoundImageHeight)
        notFoundLabel
            .Auto(margin: .collectionViewMargin)
    }
    
    lazy var collectionView: UICollectionView = {
        let layout = CollectionViewTableLayout(
            cellHeight: GamesListCell.defaultHeight,
            sectionInset: .zero
        )
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        
        collectionView.backgroundColor = .clear
        
        collectionView.register(
            GamesListCell.self,
            forCellWithReuseIdentifier: GamesListCell.reuseIdentifier
        )
        
        collectionView.register(
            ImageViewPagerReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ImageViewPagerReusableView.reuseIdentifier
        )
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.backgroundView = notFoundView
        
        return collectionView
    }()
    
    lazy var mainGrid = Grid.vertical {
        searchBar
            .Constant(value: 50)
        collectionView
            .Expanded(margin: UIEdgeInsets(
                top: 10, left: 0, bottom: 0, right: 0))
    }
    
    var viewModel: FavoritesViewModelProtocol! {
        didSet {
            viewModel.delegate = self
            title = viewModel.viewControllerTitle
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.updateFavoriteGames(for: nil)
    }
    
    @objc private func searchDidChange(_ textField: UITextField) {
        viewModel.filter(for: textField.text)
    }
}

extension FavoritesViewController: FavoritesViewControllerProtocol {
    
    func setupViews() {
        view.backgroundColor = .appTabBarColor
        mainGrid.backgroundColor = .appBackgroundColor
        
        view.addSubview(mainGrid)
        mainGrid.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.expand(mainGrid, to: view.safeAreaLayoutGuide)
    }
}

extension FavoritesViewController: UICollectionViewDelegateFlowLayout,
                                   UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        
        let count = viewModel.itemCount
        notFoundView.isHidden = viewModel.itemCount > 0
        return count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: GamesListCell.reuseIdentifier,
            for: indexPath
        ) as? GamesListCell else {
            fatalError("Failed to cast GamesListCell in FavoritesViewController.")
        }
        
        let data = viewModel.getGame(at: indexPath.row)
        cell.viewModel = GamesListCellViewModel(dataModel: data)
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        viewModel.didSelectGame(at: indexPath.row)
    }
}

extension FavoritesViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
}

extension FavoritesViewController: FavoritesViewModelDelegate {
    func onListUpdate() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            collectionView.reloadData()
        }
    }
}
