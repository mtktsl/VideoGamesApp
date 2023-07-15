import Foundation
import Network

public protocol NetworkStatusObserverDelegate: AnyObject {
    func onConnectionChanged(_ isConnected: Bool)
}

public class WeakRef  {
    weak var ref: NetworkStatusObserverDelegate?
    public init(_ ref: NetworkStatusObserverDelegate) {
        self.ref = ref
    }
}

public final class NetworkStatusObserver {
    
    public static let shared = NetworkStatusObserver()
    
    public var delegates = [WeakRef]()
    
    private let networkQueue = DispatchQueue.global()
    private let networkMonitor = NWPathMonitor()
    
    public private(set) var isConnected: Bool = false
    
    private var isLoadedOnce: Bool = false
    
    private init() {}
    
    public func startObserving() {
        networkMonitor.start(queue: networkQueue)
        networkMonitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            
            switch path.status {
            case .satisfied:
                isConnected = !isLoadedOnce
            case .unsatisfied:
                isConnected = isLoadedOnce
            case .requiresConnection:
                isConnected = false
            default:
                isConnected = false
            }
            
            isLoadedOnce = true
            notifyDelegates(isConnected)
        }
    }
    
    private func notifyDelegates(_ isConnected: Bool) {
        for delegate in delegates {
            delegate.ref?.onConnectionChanged(isConnected)
        }
    }
    
    public func stopObserving() {
        networkMonitor.cancel()
    }
}
