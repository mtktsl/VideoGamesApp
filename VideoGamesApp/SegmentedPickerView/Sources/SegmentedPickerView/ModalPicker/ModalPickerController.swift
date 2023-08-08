//
//  File.swift
//  
//
//  Created by Metin Tarık Kiki on 12.06.2023.
//

import UIKit
import GridLayout

internal protocol ModalPickerControllerProtocol: AnyObject {
    
    func reloadData()
    func setupView()
    func setupColors(
        viewColor: UIColor,
        titleTextColor: UIColor,
        tableColor: UIColor,
        cellColor: UIColor,
        cellTextColor: UIColor,
        searchColor: UIColor,
        searchTextColor: UIColor,
        cancelColor: UIColor,
        cancelTextColor: UIColor
    )
    func layoutViews()
    func sendToDelegate(_ filter: String)
    func endEditting()
}

internal protocol ModalPickerControllerDelegate: AnyObject {
    func onFilterSelected(_ filter: String)
}

internal final class ModalPickerController: UIViewController {
    
    var presenter: ModalPickerPresenter!
    
    weak var delegate: ModalPickerControllerDelegate?
    var selectedIndex: Int?
    
    var height: CGFloat = 0
    var horizontalInset: CGFloat = 0
    var minTableHeight: CGFloat = 150
    
    var tableCellColor: UIColor?
    var tableCellTextColor: UIColor?
    
    weak var windowKVO: NSKeyValueObservation?
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchTextField.enablesReturnKeyAutomatically = true
        searchBar.returnKeyType = .done
        searchBar.delegate = self
        searchBar.layer.cornerRadius = 10
        searchBar.clipsToBounds = true
        return searchBar
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "defaultCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        return tableView
    }()
    
    lazy var cancelButton: UIButton = {
        let cancelButton = UIButton()
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.layer.cornerRadius = 10
        cancelButton.addTarget(self,
                               action: #selector(cancelTap(_:)),
                               for: .touchUpInside)
        cancelButton.backgroundColor = .systemGray
        return cancelButton
    }()
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        return titleLabel
    }()

    lazy var mainGrid = Grid.vertical {
        
        titleLabel
            .Auto(margin: .init(top: 10, left: 10, bottom: 10, right: 10))
        tableView
            .Expanded()
        
        Grid.horizontal {
            searchBar
                .Expanded()
            cancelButton
                .Constant(value: 100,
                          margin: .init(top: 10, left: 10, bottom: 10, right: 10))
        }.Auto(margin: .init(top: 0, left: 5, bottom: 0, right: 5))
    }
    
    override func viewDidLayoutSubviews() {
        presenter.viewDidLoad()
        presenter.viewDidLayout()
    }
    
    @objc private func cancelTap(_ sender: UIButton) {
        presenter.onCancelTap()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter.onDisappear()
    }
}

extension ModalPickerController: UISearchBarDelegate {
    func searchBar(
        _ searchBar: UISearchBar,
        textDidChange searchText: String
    ) {
        presenter.onSearch(searchText)
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        presenter.onReturnTap()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        presenter.onReturnTap()
    }
}

extension ModalPickerController: ModalPickerControllerProtocol {
    func endEditting() {
        view.endEditing(true)
    }
    
    func sendToDelegate(_ filter: String) {
        delegate?.onFilterSelected(filter)
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func setupView() {
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        
        view.addSubview(mainGrid)
        mainGrid.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainGrid.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainGrid.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mainGrid.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            mainGrid.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        windowKVO = observe(\.view?.window?.bounds) { [weak self] kvo, change in
            guard let self else { return }
            presenter.viewDidLayout()
        }
    }
    
    func setupColors(
        viewColor: UIColor,
        titleTextColor: UIColor,
        tableColor: UIColor,
        cellColor: UIColor,
        cellTextColor: UIColor,
        searchColor: UIColor,
        searchTextColor: UIColor,
        cancelColor: UIColor,
        cancelTextColor: UIColor
    ) {
        view.backgroundColor = viewColor
        titleLabel.textColor = titleTextColor
        tableView.backgroundColor = tableColor
        tableCellColor = cellColor
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = searchColor
            textField.textColor = searchTextColor
        }
        searchBar.barTintColor = viewColor
        cancelButton.backgroundColor = cancelColor
        cancelButton.setTitleColor(cancelTextColor, for: .normal)
        tableCellTextColor = cellTextColor
    }
    
    func layoutViews() {
        
        guard let window = view.window else { return }
        
        view.frame = CGRect(
            origin: .zero,
            size: .init(
                width: view.bounds.size.width,
                height: window.bounds.size.height * 0.4
            )
        )
        
        mainGrid.setNeedsLayout()
    }
    
    
}

extension ModalPickerController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        presenter.onItemSelected(at: indexPath.row)
    }
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return presenter.itemCount
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell")
        else { fatalError("Failed to retreive default cell in modal picker controller") }
        
        let cellText = presenter.getFilter(at: indexPath.row)
        
        if #available(iOS 14, *) {
            var config = cell.defaultContentConfiguration()
            config.text = cellText
            config.textProperties.color = tableCellTextColor ?? .black
            config.textProperties.alignment = .center
            cell.contentConfiguration = config
        } else {
            cell.textLabel?.text = cellText
            cell.textLabel?.textColor = tableCellTextColor
            cell.textLabel?.textAlignment = .center
        }
        
        cell.backgroundColor = tableCellColor
        
        return cell
    }
}
