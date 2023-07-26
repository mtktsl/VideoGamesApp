import DataDownloader
import Foundation

public protocol RAWG_GamesServiceProtocol: AnyObject {
    func getGamesList(
        _ parameters: RAWG_GamesListParameters,
        completion: @escaping ((Result<RAWG_GamesListResponse, RAWG_NetworkError>) -> Void)
    ) -> URLSessionDataTask?
    
    func getGameDetails(
        _ gameID: Int,
        apiKey: String,
        completion: @escaping ((Result<RAWG_GameDetails, RAWG_NetworkError>) -> Void)
    ) -> URLSessionDataTask?
    
    func downloadImage(
        _ imageURLString: String,
        isCropped: Bool,
        completion: @escaping ((Result<Data, RAWG_NetworkError>) -> Void)
    ) -> URLSessionDataTask?
}

public class RAWG_GamesService {
    
    public static let shared = RAWG_GamesService()
    let webService = DataDownloaderService.shared
    
    public var imageCacheSize = RAWG_Constants.imageCacheSize
    
    //TODO: - Make a proper cache algorithm that brings last reached element to front and removes oldest element.
    private var webImageCache = [String: Data]()

    private func cacheImageData(_ key: String, value: Data) {
        let count = webImageCache.count
        if count > imageCacheSize {
            _ = webImageCache.popFirst()
        }
        webImageCache[key] = value
    }
    
    private init() {}
}

extension RAWG_GamesService: RAWG_GamesServiceProtocol {
    
    public func getGamesList(
        _ parameters: RAWG_GamesListParameters,
        completion: @escaping ((Result<RAWG_GamesListResponse, RAWG_NetworkError>) -> Void)
    ) -> URLSessionDataTask? {
        let gamesListURLString = RAWG_Constants
            .gamesURLConfiguration
            .generateGamesListURLString(parameters)
        
        return webService.fetchData(
            from: gamesListURLString,
            dataType: RAWG_GamesListResponse.self,
            decode: true
        ) { result in
                switch result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(.generateError(error)))
                }
        }
    }
    
    public func getGameDetails(
        _ gameID: Int,
        apiKey: String,
        completion: @escaping ((Result<RAWG_GameDetails, RAWG_NetworkError>) -> Void)
    ) -> URLSessionDataTask? {
        
        let gamesListURLString = RAWG_Constants
            .gamesURLConfiguration
            .generateGameDetailURLString(
                gameID,
                key: apiKey
            )
        
        return webService.fetchData(
            from: gamesListURLString,
            dataType: RAWG_GameDetails.self,
            decode: true) { result in
                switch result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(.generateError(error)))
                }
            }
    }
    
    public func downloadImage(
        _ imageURLString: String,
        isCropped: Bool,
        completion: @escaping ((Result<Data, RAWG_NetworkError>) -> Void)
    ) -> URLSessionDataTask? {
        
        let urlString = isCropped
        ? imageURLString.replacingOccurrences(
            of: RAWG_Constants.fullSizeMediaBaseURL,
            with: RAWG_Constants.croppedSizeMediaBaseURL
        )
        : imageURLString
        
        if let cachedData = webImageCache[urlString] {
            completion(.success(cachedData))
            return nil
        }
        
        return webService.fetchData(
            from: urlString,
            dataType: Data.self,
            decode: false) { [weak self] result in
                guard let self else { return }
                
                switch result {
                case .success(let data):
                    cacheImageData(urlString, value: data)
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(.generateError(error)))
                }
            }
    }
    
}
