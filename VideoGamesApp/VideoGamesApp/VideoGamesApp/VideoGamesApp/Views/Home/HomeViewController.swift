//
//  HomeViewController.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 13.07.2023.
//

import UIKit
import GridLayout
import RAWG_API
import ImageViewPager
import NSLayoutConstraintExtensionPackage

fileprivate typealias const = ApplicationConstants

fileprivate extension UIEdgeInsets {
    static let imageViewPagerMargin = UIEdgeInsets(
        top: 10,
        left: 10,
        bottom: 10,
        right: 10
    )
    
    static let searchFieldMargin = UIEdgeInsets(10)
    static let searchBarMargin = UIEdgeInsets(10)
    static let searchImageViewMargin = UIEdgeInsets(
        top: 0, left: 0, bottom: 0, right: 10
    )
}

protocol HomeViewControllerProtocol {
    func setupColors()
    func setupMainGrid()
}

class HomeViewController: UIViewController {
    
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
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        return collectionView
    }()
    
    let imageViewPager: ImageViewPager = {
        let imageViewPager = ImageViewPager([])
        
        imageViewPager.scrollView.layer.cornerRadius = 10
        return imageViewPager
    }()
    
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
        
        return searchField
    }()
    
    let searchImageView: UIImageView = {
        let searchImageView = UIImageView()
        searchImageView.image = UIImage(systemName: const.SystemImages.magnifyingGlass)
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
    
    
    lazy var mainGrid = Grid.vertical {
        searchBar
            .Constant(value: 50)
        collectionView
            .Expanded(margin: .init(top: 5, left: 0, bottom: 5, right: 0))
    }
    
    var viewModel: HomeViewModelProtocol! {
        didSet {
            title = viewModel.viewControllerTitle
            viewModel.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupColors()
        setupMainGrid()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.queryForGamesList(
            nil,
            orderBy: nil
        )
    }
    
    @objc private func searchDidChange(_ textField: UITextField) {
        //TODO: add logic for 3 letter search
        viewModel.queryForGamesList(
            textField.text,
            orderBy: nil
        )
    }
}

extension HomeViewController: ImageViewPagerDelegate {
    func onImageTap(imageViewPager: ImageViewPager, at index: Int) {
        print(index)
    }
}

extension HomeViewController: HomeViewControllerProtocol {
    
    func setupColors() {
        view.backgroundColor = .appTabBarColor
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.barTitleColor]
    }
    
    func setupMainGrid() {
        view.addSubview(mainGrid)
        mainGrid.backgroundColor = .appBackgroundColor
        mainGrid.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.expand(mainGrid, to: view.safeAreaLayoutGuide)
        imageViewPager.delegate = self
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.dataCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: GamesListCell.reuseIdentifier,
            for: indexPath
        ) as? GamesListCell
        else { fatalError("Failed to cast GamesListCell") }
        
        cell.viewModel = GamesListCellViewModel(
            dataModel: viewModel.getGame(at: indexPath.row)
        )
        
        return cell
    }
}

extension HomeViewController: HomeViewModelDelegate {
    func onSearchResult() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            collectionView.reloadData()
        }
    }
}
