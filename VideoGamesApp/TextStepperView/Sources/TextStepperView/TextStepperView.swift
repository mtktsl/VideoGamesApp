
import UIKit

public class TextStepperView: UIView {
    
    //MARK: - View setups
    public private(set) lazy var decreaseImageView: UIImageView = {
        let decreaseImageView = UIImageView()
        decreaseImageView.contentMode = .scaleAspectFit
        decreaseImageView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(onDecreaseTap(_:))
            )
        )
        decreaseImageView.isUserInteractionEnabled = true
        return decreaseImageView
    }()
    
    public private(set) lazy var increaseImageView: UIImageView = {
        let increaseImageView = UIImageView()
        increaseImageView.contentMode = .scaleAspectFit
        increaseImageView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(onIncreaseTap(_:))
            )
        )
        increaseImageView.isUserInteractionEnabled = true
        return increaseImageView
    }()
    
    public let stepperTextLabel: UILabel = {
        let stepperTextLabel = UILabel()
        stepperTextLabel.textAlignment = .right
        return stepperTextLabel
    }()
    
    public let stepperTotalValueLabel: UILabel = {
        let stepperTotalValueLabel = UILabel()
        stepperTotalValueLabel.textAlignment = .left
        return stepperTotalValueLabel
    }()
    
    private lazy var stepperTextContainerView: UIStackView = {
        let stepperTextContainer = UIStackView()
        stepperTextContainer.axis = .horizontal
        stepperTextContainer.addArrangedSubview(stepperTextLabel)
        stepperTextContainer.addArrangedSubview(stepperTotalValueLabel)
        return stepperTextContainer
    }()
    
    //MARK: - Class Setups
    private var stepperText: String?
    
    public var currentValue: Int = 0 {
        didSet {
            if currentValue < minimumValue {
                currentValue = minimumValue
            } else if currentValue > maximumValue {
                currentValue = maximumValue
            }
            
            delegate?.onCurrentValueChange(
                self,
                oldValue: oldValue,
                newValue: currentValue
            )
            resetTextLabel()
        }
    }
    
    public var minimumValue: Int = 0 {
        didSet {
            if currentValue < minimumValue {
                currentValue = minimumValue
            } else {
                resetTextLabel()
            }
        }
    }
    
    public var maximumValue: Int = 10 {
        didSet {
            if currentValue > maximumValue {
                currentValue = maximumValue
            } else {
                resetTextLabel()
            }
        }
    }
    
    public weak var delegate: TextStepperViewDelegate?
    
    public var decreaseImageWidth: CGFloat = 35 {
        didSet {
            setupWidthConstraints()
        }
    }
    public var increaseImageWidth: CGFloat = 35 {
        didSet {
            setupWidthConstraints()
        }
    }
    
    public var contentInset = UIEdgeInsets.zero {
        didSet {
            setupLayoutConstraints()
        }
    }
    public var spacing: CGFloat = .zero {
        didSet {
            setupLayoutConstraints()
        }
    }
    
    private var widthConstraints = [NSLayoutConstraint]()
    private var layoutConstraints = [NSLayoutConstraint]()
    
    //MARK: - Private function implementations
    public init(
        startUpValue: Int = 0,
        stepperText: String? = nil
    ) {
        super.init(frame: .zero)
        self.currentValue = startUpValue
        self.stepperText = stepperText
        
        setupSubviews()
        setupWidthConstraints()
        setupLayoutConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented for TextStepperView")
    }
    
    @objc private func onDecreaseTap(_ recognizer: UITapGestureRecognizer) {
        currentValue -= 1
    }
    
    @objc private func onIncreaseTap(_ recognizer: UITapGestureRecognizer) {
        currentValue += 1
    }
    
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        
        let innerSize = CGSize(
            width: size.width
            - contentInset.left
            - contentInset.right,
            height: size.height
            - contentInset.top
            - contentInset.bottom
        )
        
        let calculatedDecreaseSize = decreaseImageView.sizeThatFits(innerSize)
        
        let calculatedIncreaseSize = increaseImageView.sizeThatFits(innerSize)
        
        let remainingLabelSize = CGSize(
            width: innerSize.width
            - calculatedDecreaseSize.width
            - calculatedIncreaseSize.width
            - (spacing * 2),
            height: innerSize.height
        )
        
        let calculatedLabelSize = stepperTextLabel.sizeThatFits(remainingLabelSize)
        
        let calculatedWidth = calculatedLabelSize.width
        + decreaseImageWidth
        + increaseImageWidth
        
        return .init(
            width: max(calculatedWidth, size.width),
            height: max(calculatedLabelSize.height, size.height)
        )
    }
    
    private func setupSubviews() {
        addSubview(decreaseImageView)
        addSubview(stepperTextContainerView)
        addSubview(increaseImageView)
        
        decreaseImageView.translatesAutoresizingMaskIntoConstraints = false
        stepperTextContainerView.translatesAutoresizingMaskIntoConstraints = false
        increaseImageView.translatesAutoresizingMaskIntoConstraints = false
        
        resetTextLabel()
    }
    
    private func setupWidthConstraints() {
        
        NSLayoutConstraint.deactivate(widthConstraints)
        widthConstraints = [
            decreaseImageView.widthAnchor.constraint(
                equalToConstant: decreaseImageWidth
            ),
            increaseImageView.widthAnchor.constraint(
                equalToConstant: increaseImageWidth
            )
        ]
        NSLayoutConstraint.activate(widthConstraints)
    }
    
    private func setupLayoutConstraints() {
        
        NSLayoutConstraint.deactivate(layoutConstraints)
        
        layoutConstraints = [
            decreaseImageView.topAnchor.constraint(
                equalTo: self.topAnchor,
                constant: contentInset.top
            ),
            decreaseImageView.leadingAnchor.constraint(
                equalTo: self.leadingAnchor,
                constant: contentInset.left
            ),
            decreaseImageView.bottomAnchor.constraint(
                equalTo: self.bottomAnchor,
                constant: -contentInset.bottom
            ),
            
            /*stepperTextLabel.topAnchor.constraint(
                equalTo: self.topAnchor,
                constant: contentInset.top
            ),
            stepperTextLabel.leadingAnchor.constraint(
                equalTo: decreaseImageView.trailingAnchor,
                constant: spacing
            ),
            stepperTextLabel.bottomAnchor.constraint(
                equalTo: self.bottomAnchor,
                constant: -contentInset.bottom
            ),
            stepperTextLabel.trailingAnchor.constraint(
                equalTo: increaseImageView.leadingAnchor,
                constant: -spacing
            ),*/
            
            stepperTextContainerView.topAnchor.constraint(
                equalTo: self.topAnchor,
                constant: contentInset.top
            ),
            stepperTextContainerView.bottomAnchor.constraint(
                equalTo: self.bottomAnchor,
                constant: -contentInset.bottom
            ),
            
            stepperTextContainerView.centerXAnchor.constraint(
                equalTo: self.centerXAnchor
            ),

            
            increaseImageView.topAnchor.constraint(
                equalTo: self.topAnchor,
                constant: contentInset.top
            ),
            increaseImageView.bottomAnchor.constraint(
                equalTo: self.bottomAnchor,
                constant: -contentInset.bottom
            ),
            increaseImageView.trailingAnchor.constraint(
                equalTo: self.trailingAnchor,
                constant: -contentInset.right
            ),
        ]
        
        NSLayoutConstraint.activate(layoutConstraints)
    }
    
    private func setImage(
        for imageView: UIImageView,
        to image: UIImage?
    ) {
        DispatchQueue.main.async {
            imageView.image = image
        }
    }
}

//MARK: - Public Function Implementations
extension TextStepperView {
    public func setDecreaseImage(_ image: UIImage?) {
        setImage(
            for: decreaseImageView,
            to: image
        )
    }
    
    public func setIncreaseImage(_ image: UIImage?) {
        setImage(
            for: increaseImageView,
            to: image
        )
    }
    
    public func setStepperText(_ text: String?) {
        stepperText = text
    }
    
    public func resetTextLabel() {
        stepperTextLabel.text = "\(stepperText ?? "") \(currentValue)"
        stepperTotalValueLabel.text = " ... \(maximumValue)"
    }
}
