import UIKit
import GridLayout
import NSLayoutConstraintExtensionPackage

public class ImageViewPager: UIView {
    
    public weak var delegate: ImageViewPagerDelegate?
    
    public var swipeContainers = [SwipeContainerModel]() {
        willSet {
            resetSwipeContainers()
        }
        didSet {
            pageControl.numberOfPages = swipeContainers.count
            scrollView.setContentOffset(.zero, animated: true)
            setupScrollView()
            reLayoutViews()
        }
    }
    
    public private(set) var imageViews = [UIImageView]()
    
    public var containerCornerRadius: CGFloat = 10
    
    public var titleBackgroundColor: UIColor = .black
    public var titleBackgroundOpacity: Float = 0.5
    public var titleTextColor: UIColor = .white
    public var titleTextAlignment: NSTextAlignment = .left
    public var titleNumberOfLines: Int = 1
    public var titleFont: UIFont = .systemFont(ofSize: 16)
    public var titleEdgeInsets: UIEdgeInsets = .init(top: 5, left: 10, bottom: 5, right: -10)
    
    public var imageContentMode: UIView.ContentMode = .scaleToFill
    
    public let scrollView = UIScrollView()
    public let pageControl = UIPageControl()
    
    private var containerGrid: Grid?
    private var scrollThroughPageControl = false
    
    lazy var mainGrid = Grid.vertical {
        scrollView
            .Expanded()
        pageControl
            .Auto()
    }
    
    public init(
        _ containers: [SwipeContainerModel]
    ) {
        super.init(frame: .zero)
        self.swipeContainers = containers
        setupScrollView()
        setupPageControl()
        setupMainGrid()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented for ImageViewPager")
    }
    
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        reLayoutViews()
    }
    
    private func reLayoutViews() {
        mainGrid.setNeedsLayout()
        mainGrid.layoutIfNeeded()
        layoutContentGrid()
    }
    
    private func layoutContentGrid() {
        let contentSize = CGSize(
            width: scrollView.bounds.size.width * CGFloat(swipeContainers.count),
            height: scrollView.bounds.size.height
        )
        scrollView.contentSize = contentSize
        containerGrid?.frame = CGRect(origin: .zero, size: contentSize)
    }
    
    private func setupPageControl() {
        pageControl.numberOfPages = swipeContainers.count
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .gray
        pageControl.addTarget(
            self,
            action: #selector(pageControlDidChange(_:)),
            for: .valueChanged
        )
    }
    
    @objc private func pageControlDidChange(_ sender: UIPageControl) {
        let current = sender.currentPage
        scrollView.setContentOffset(
            CGPoint(
                x: scrollView.contentSize.width / CGFloat(swipeContainers.count) * CGFloat(current),
                y: .zero
            ),
            animated: true
        )
        scrollThroughPageControl = true
    }
    
    private func setupMainGrid() {
        addSubview(mainGrid)
        mainGrid.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.expand(mainGrid, to: self)
    }
    
    private func setupScrollView() {
        if let containerView = generateContainerViews() {
            scrollView.addSubview(containerView)
            containerGrid = containerView
        }
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
    }
    
    private func generateContainerViews() -> Grid? {
        
        guard !swipeContainers.isEmpty else { return nil }
        
        var containers = [UIView]()
        for i in 0 ..< swipeContainers.count {
            let container = generateSwipeContainer(
                image: swipeContainers[i].image,
                title: swipeContainers[i].title
            )
            container.tag = i
            
            container.addGestureRecognizer(
                UITapGestureRecognizer(
                    target: self,
                    action: #selector(onImageTap(_:))
                )
            )
            container.isUserInteractionEnabled = true
            
            containers.append(container)
        }
        
        return Grid.horizontal {
            for container in containers {
                container
                    .Expanded()
            }
        }
    }
    
    @objc private func onImageTap(_ recognizer: UITapGestureRecognizer) {
        guard let view = recognizer.view else { return }
        delegate?.onImageTap(imageViewPager: self, at: view.tag)
    }
    
    private func generateTitleLabel(_ title: String) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = titleTextColor
        titleLabel.textAlignment = titleTextAlignment
        titleLabel.numberOfLines = titleNumberOfLines
        titleLabel.font = titleFont
        
        let textBackground = UIView()
        textBackground.backgroundColor = titleBackgroundColor
        textBackground.layer.opacity = titleBackgroundOpacity
        
        let container = UIView()
        container.addSubview(textBackground)
        container.addSubview(titleLabel)
        
        textBackground.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.expand(textBackground, to: container)
        NSLayoutConstraint.expand(titleLabel, to: container, padding: titleEdgeInsets)
        
        return container
    }
    
    private func generateSwipeContainer(
        image: UIImage?,
        title: String?
    ) -> UIImageView {
        
        let imageView = UIImageView()
        setImage(of: imageView, to: image)
        imageView.contentMode = imageContentMode
        
        if let title {
            let titleLabel = generateTitleLabel(title)
            
            imageView.addSubview(titleLabel)
            
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.expand(titleLabel, to: imageView, alignment: .bottom)
        }
        imageViews.append(imageView)
        return imageView
    }
    
    private func setImage(
        of imageView: UIImageView,
        to image: UIImage?
    ) {
        DispatchQueue.main.async {
            imageView.image = image
        }
    }
    
    private func resetSwipeContainers() {
        for view in scrollView.subviews {
            view.removeFromSuperview()
        }
        pageControl.numberOfPages = 0
        imageViews.removeAll()
        containerGrid = nil
    }
}

extension ImageViewPager: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if !scrollThroughPageControl {
            
            let centerXOfContainer = scrollView.contentOffset.x + scrollView.contentSize.width / 2 / CGFloat(swipeContainers.count)
            
            
            let pageNumer = Int(floor(Float(centerXOfContainer / scrollView.bounds.size.width)))
            pageControl.currentPage = pageNumer
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollThroughPageControl = false
    }
}
