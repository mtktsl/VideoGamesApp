//
//  HomeViewController.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 13.07.2023.
//

import UIKit
import GridLayout
import ImageViewPager
import NSLayoutConstraintExtensionPackage
import LoadingView
import TextStepperView
import SegmentedPickerView

//MARK: - Fileprivate values
fileprivate typealias const = ApplicationConstants

fileprivate extension UIEdgeInsets {
    
    static let imageViewPagerMargin = UIEdgeInsets(
        top: 10,
        left: 10,
        bottom: 10,
        right: 10
    )
    
    static let searchFieldMargin = UIEdgeInsets(10)
    
    static let searchImageViewMargin = UIEdgeInsets(
        top: 0, left: 0, bottom: 0, right: 10
    )
    
    static let pickerMargin = UIEdgeInsets(
        top: 0, left: 5, bottom: 0, right: 0)
    
    static let stepperMargin = UIEdgeInsets(10)
    
    static let orderMargin = UIEdgeInsets(
        top: 15, left: 10, bottom: 10, right: 10)
    
    static let collectionViewMargin = UIEdgeInsets(
        top: 5, left: 0, bottom: 5, right: 0
    )
}

extension HomeViewController {
    enum Constants {
        static let imageViewPagerHeaderHeight: CGFloat = 200
        static let collectionContentInset = UIEdgeInsets(
            top: 0, left: 10, bottom: 10, right: 10
        )
        static let notFoundImageHeight: CGFloat = 200
        
        static let viewPagerHeightRatio: CGFloat = 9.0 / 16.0
        static let viewPagerMinHeightSpacing: CGFloat = 50
        
        static let notFoundText = "Oops. We couldn't find what you are looking for."
    }
}

//MARK: - HomeviewControllerProtocol
protocol HomeViewControllerProtocol: AnyObject, ImageViewPagerDelegate {
    func setupColors()
    func setupMainGrid()
    func showNotFoundView()
    func hideNotFoundView()
}

//MARK: - HomeViewController View Implementations
class HomeViewController: UIViewController {
    
    let notFoundImage: UIImageView = {
        let notFoundImage = UIImageView(
            image: UIImage(systemName: const.SystemImages.eyeSlashCircle)
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
        
        collectionView.dataSource = viewModel.dataSource
        collectionView.delegate = self
        
        collectionView.backgroundView = notFoundView
        
        return collectionView
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
        
        searchField.delegate = self
        
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
    
    lazy var orderingView: SegmentedPickerView = {
        let picker = SegmentedPickerView.build(
            segmentedFilters: viewModel.orderingVisibleSegments,
            moreFilters: viewModel.orderingMoreSegments,
            moreButtonTitle: viewModel.orderingMoreText,
            moreButtonImage: UIImage(
                systemName: ApplicationConstants
                    .SystemImages
                    .line3HorizontalDecrease
            ),
            pickerTitle: viewModel.orderingPickerTitle,
            pickerConfig: .init(
                viewColor: .appContainerBackgroundColor,
                titleTextColor: .white,
                tableColor: .clear,
                cellColor: .appGamesListCellBackgroundColor,
                cellTextColor: .white,
                searchColor: .systemGray4,
                searchTextColor: .black,
                cancelColor: .systemBlue,
                cancelTextColor: .white
            )
        )
        
        picker.normalTitleColor = .lightText
        picker.popupCancelColor = .systemBlue
        picker.selectedSegmentTintColor = .systemGray
        picker.selectedSegmentTitleColor = .white
        
        picker.backgroundColor = .appGamesListCellBackgroundColor
        picker.clipsToBounds = true
        picker.layer.cornerRadius = 5
        
        picker.delegate = self
        
        return picker
    }()
    
    lazy var orderingIndicatorLabel: UILabel = {
        let orderingIndicatorLabel = UILabel()
        orderingIndicatorLabel.textColor = .lightText
        orderingIndicatorLabel.text = viewModel.orderingIndicatorText
        return orderingIndicatorLabel
    }()
    
    lazy var textStepperView: TextStepperView = {
        let textStepperView = TextStepperView(
            startUpValue: viewModel.minimumPageNumber,
            stepperText: viewModel.paginationIndicatorText
        )
        
        textStepperView.setDecreaseImage(UIImage(systemName: ApplicationConstants.SystemImages.chevronLeftCircle))
        textStepperView.setIncreaseImage(UIImage(systemName: ApplicationConstants.SystemImages.chevronRightCircle))
        
        textStepperView.stepperTextLabel.textColor = .white
        textStepperView.stepperTextLabel.font = .boldSystemFont(ofSize: 18)
        textStepperView.stepperTotalValueLabel.textColor = .white
        textStepperView.stepperTotalValueLabel.textColor = .lightText
        textStepperView.decreaseImageView.tintColor = .darkGray
        textStepperView.increaseImageView.tintColor = .white
        
        textStepperView.minimumValue = viewModel.minimumPageNumber
        
        textStepperView.delegate = self
        
        return textStepperView
    }()
    
    let spacerView: UIView = {
        let spacerView = UIView()
        spacerView.backgroundColor = .darkGray
        return spacerView
    }()
    
    //MARK: - Main Grid
    lazy var mainGrid = Grid.vertical {
        searchBar
            .Constant(value: 50)
        
        textStepperView
            .Constant(value: 50, margin: .stepperMargin)
        
        spacerView
            .Constant(value: 2)
        
        Grid.horizontal {
            orderingIndicatorLabel
                .Auto()
            orderingView
                .Expanded(margin: .pickerMargin)
        }.Constant(value: 60, margin: .orderMargin)
        
        collectionView
            .Expanded(margin: .collectionViewMargin)
    }
    
    var viewModel: HomeViewModelProtocol! {
        didSet {
            title = viewModel.viewControllerTitle
            viewModel.delegate = self
        }
    }
    
    lazy var dataSource = HomeCollectionDataSource(
        view: self,
        viewModel: viewModel
    )
    
    //MARK: - Overridden methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupColors()
        setupMainGrid()
        LoadingView.shared.startLoading()
        viewModel.performDefaultQuery()
    }
    
    @objc private func searchDidChange(_ textField: UITextField) {
        viewModel.queryForGamesList(
            textField.text,
            orderBy: orderingView.selectedValue,
            pageNumber: textStepperView.currentValue
        )
    }
}

//MARK: - ImageViewPagerDelegate
extension HomeViewController: ImageViewPagerDelegate {
    func onImageTap(imageViewPager: ImageViewPager, at index: Int) {
        viewModel.pageControllerDidSelect(at: index)
    }
}

//MARK: - HomeViewControllerProtocol Implementation
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
    }
    
    func showNotFoundView() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            collectionView.backgroundView?.isHidden = false
        }
    }
    
    func hideNotFoundView() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            collectionView.backgroundView?.isHidden = true
        }
    }
}

//MARK: - UICollectionViewDataSource and Delegate implementations
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        
        let width: CGFloat = collectionView.bounds.size.width
        - Constants.collectionContentInset.left
        - Constants.collectionContentInset.right
        let height: CGFloat = collectionView.bounds.size.height
        - Constants.collectionContentInset.bottom
        - Constants.collectionContentInset.top
        
        let viewWidth = view.bounds.inset(by: view.safeAreaInsets).size.width
        
        let calculatedHeight = viewWidth * Constants.viewPagerHeightRatio
        
        let calculatedWidth = (calculatedHeight > height)
        ? width * Constants.viewPagerHeightRatio
        : width
        
        let finalSize: CGSize = viewModel.isImageViewPagerVisible
        ? .init(
            width: calculatedWidth,
            height: calculatedHeight
        )
        : .zero
        
        return finalSize
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        viewModel.cellDidSelect(at: indexPath.row)
    }
}

//MARK: - ViewModel delegate implementations
extension HomeViewController: HomeViewModelDelegate {
    
    func onSearchResult() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            LoadingView.shared.hideLoading()
            collectionView.reloadData()
            textStepperView.maximumValue = viewModel.maximumPageNumber
        }
    }
}

extension HomeViewController: TextStepperViewDelegate {
    func onCurrentValueChange(
        _ textStepperView: TextStepperView,
        oldValue: Int,
        newValue: Int
    ) {
        if oldValue != newValue {
            LoadingView.shared.startLoading(on: collectionView)
            viewModel.queryForGamesList(
                searchField.text,
                orderBy: orderingView.selectedValue,
                pageNumber: newValue
            )
        }
        
        if newValue == textStepperView.minimumValue {
            textStepperView.decreaseImageView.tintColor = .darkGray
        } else {
            textStepperView.decreaseImageView.tintColor = .white
        }
        
        if newValue == textStepperView.maximumValue {
            textStepperView.increaseImageView.tintColor = .darkGray
        } else {
            textStepperView.increaseImageView.tintColor = .white
        }
    }
}

extension HomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

extension HomeViewController: SegmentedPickerViewDelegate {
    func onSelectionChanged(_ newSelection: String) {
        LoadingView.shared.startLoading(on: collectionView)
        viewModel.queryForGamesList(
            searchField.text,
            orderBy: newSelection,
            pageNumber: textStepperView.currentValue
        )
    }
}
