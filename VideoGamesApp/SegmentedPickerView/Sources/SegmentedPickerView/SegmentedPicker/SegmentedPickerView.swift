import UIKit
import GridLayout

extension SegmentedPickerView {
    fileprivate enum Constants {
        static let segmentGray = UIColor(
            hue: 240.0/360.0,
            saturation: 0,
            brightness: 0.94,
            alpha: 1
        )
        static let darkSegmentGray = UIColor(
            hue: 240.0/360.0,
            saturation: 0,
            brightness: 0.94,
            alpha: 1
        )
        static let segmentRadius: CGFloat = 6
        static let segmentFont: CGFloat = 14
        
        static let buttonInset: CGFloat = 1
        
        static let buttonEdgeInset = UIEdgeInsets (
            top: buttonInset,
            left: buttonInset,
            bottom: buttonInset,
            right: buttonInset
        )
    }
}

public protocol SegmentedPickerViewDelegate: AnyObject {
    func onSelectionChanged(_ newSelection: String)
}

internal protocol SegmentedPickerViewProtocol: AnyObject {
    
    var pickerWidth: CGFloat { get }
    var pickerHeight: CGFloat { get }
    var popupCancelColor: UIColor { get }
    
    func setupMoreButton(title: String, image: UIImage?)
    func setupSegmentedControl()
    func setupInitialValue(_ value: String?)
    func setupMainGrid(_ isMoreButtonActive: Bool)
    func changeSegment(_ filters: [String], buttonTitle: String)
    func toggleMoreButton(_ title: String, selected: Bool)
}

public class SegmentedPickerView: UIView {
    
    public private(set) var selectedValue: String?
    
    public let segmentedControl: UISegmentedControl
    
    public let moreButton: UIButton
    
    
    //TODO: - add didSet for the values in order to change UI when they change later
    public var selectedSegmentTintColor: UIColor = .white
    public var selectedSegmentTitleColor: UIColor = .black
    public var normalTitleColor: UIColor = .black
    public var popupCancelColor: UIColor = .lightGray
    
    
    var presenter: SegmentedPickerPresenterProtocol!
    
    public weak var delegate: SegmentedPickerViewDelegate?
    
    private var didInitOnce: Bool = false

    private var mainGrid: Grid!
    
    var pickerWidth: CGFloat {
        return self.window?.bounds.inset(by: self.window?.safeAreaInsets ?? .zero).size.width ?? 400
    }
    
    var pickerHeight: CGFloat {
        return 200//(self.window?.screen.bounds.size.height ?? 300.0) / 5
    }
    
    public static func build(
        segmentedFilters: [String]?,
        moreFilters: [String]?,
        moreButtonTitle: String,
        moreButtonImage: UIImage?,
        pickerTitle: String,
        pickerConfig: ModalPickerConfig?
    ) -> SegmentedPickerView {
        
        let view = SegmentedPickerRouter.createModule(
            .init(
                segmentedFilters: segmentedFilters,
                moreFilters: moreFilters,
                moreButtonTitle: moreButtonTitle,
                moreButtonImage: moreButtonImage,
                pickerTitle: pickerTitle,
                modalConfig: pickerConfig
            )
        )
        return view
    }
    
    internal init(
        _ config: SegmentedPickerConfig
    ) {
        segmentedControl = UISegmentedControl(items: config.segmentedFilters)
        moreButton = UIButton(frame: .zero)
        
        super.init(frame: .zero)
        self.backgroundColor = Constants.segmentGray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func willMove(toSuperview newSuperview: UIView?) {
        if !didInitOnce {
            presenter.viewDidInit()
        }
        didInitOnce = true
    }
    
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        let segmentSize = segmentedControl.sizeThatFits(size)
        let buttonSize = moreButton.sizeThatFits(size)
        
        return .init(
            width: max(segmentSize.width, buttonSize.width),
            height: max(segmentSize.height, buttonSize.height)
        )
    }
    
    @objc private func onSegmentChanged(_ sender: UISegmentedControl) {
        presenter.onSegmentChanged()
    }
    
    @objc private func onMoreButtonTapped(_ sender: UIButton) {
        presenter.onMoreButtonTap()
    }
}

extension SegmentedPickerView: SegmentedPickerViewProtocol {
    
    func toggleMoreButton(_ title: String, selected: Bool) {
        if selected {
            moreButton.backgroundColor = selectedSegmentTintColor
            moreButton.setTitleColor(selectedSegmentTitleColor, for: .normal)
            moreButton.layer.shadowOpacity = 0.5
        } else {
            moreButton.backgroundColor = self.backgroundColor
            moreButton.setTitleColor(normalTitleColor, for: .normal)
            moreButton.layer.shadowOpacity = 0
        }
        moreButton.setTitle(title, for: .normal)
    }
    
    func changeSegment(
        _ filters: [String],
        buttonTitle: String
    ) {
        if segmentedControl.selectedSegmentIndex != -1 {
            let value = filters[segmentedControl.selectedSegmentIndex]
            selectedValue = value
            delegate?.onSelectionChanged(value)
            toggleMoreButton(buttonTitle, selected: false)
        }
    }
    
    func setupMoreButton(
        title: String,
        image: UIImage?
    ) {
        moreButton.setTitle(title, for: .normal)
        moreButton.setImage(image, for: .normal)
        moreButton.tintColor = selectedSegmentTitleColor
        moreButton.setTitleColor(normalTitleColor, for: .normal)
        moreButton.backgroundColor = self.backgroundColor
        moreButton.layer.cornerRadius = Constants.segmentRadius
        moreButton.layer.shadowRadius = 1
        moreButton.layer.shadowOpacity = 0
        moreButton.layer.shadowColor = UIColor.black.cgColor
        moreButton.layer.shadowOffset = .zero
        
        moreButton.titleLabel?.font = .systemFont(ofSize: Constants.segmentFont)
        
        moreButton.addTarget(
            self,
            action: #selector(onMoreButtonTapped(_:)),
            for: .touchUpInside
        )
    }
    
    func setupSegmentedControl() {
        segmentedControl.addTarget(
            self,
            action: #selector(onSegmentChanged(_:)),
            for: .valueChanged
        )
        segmentedControl.selectedSegmentTintColor = selectedSegmentTintColor
        segmentedControl.setTitleTextAttributes(
            [NSAttributedString.Key.foregroundColor:selectedSegmentTitleColor],
            for: .selected
        )
        segmentedControl.setTitleTextAttributes(
            [NSAttributedString.Key.foregroundColor:normalTitleColor],
            for: .normal
        )
        segmentedControl.selectedSegmentIndex = 0
    }
    
    func setupInitialValue(_ value: String?) {
        selectedValue = value
    }
    
    func setupMainGrid(_ isMoreButtonActive: Bool) {
        
        if isMoreButtonActive {
            mainGrid = Grid.horizontal {
                segmentedControl
                    .Expanded(value: CGFloat(segmentedControl.numberOfSegments))
                moreButton
                    .Expanded(value: 1,
                              margin: Constants.buttonEdgeInset)
            }
        } else {
            mainGrid = Grid.horizontal {
                moreButton
                    .Expanded()
            }
        }
        
        self.addSubview(mainGrid)
        mainGrid.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainGrid.topAnchor.constraint(equalTo: self.topAnchor),
            mainGrid.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            mainGrid.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            mainGrid.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
}

extension SegmentedPickerView: ModalPickerControllerDelegate {
    func onFilterSelected(_ filter: String) {
        selectedValue = filter
        delegate?.onSelectionChanged(filter)
        segmentedControl.selectedSegmentIndex = -1
        toggleMoreButton(filter, selected: true)
    }
}
