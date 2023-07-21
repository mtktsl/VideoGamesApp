import DataDownloader
import Foundation

public protocol RAWG_GamesServiceProtocol: AnyObject {
    func getGamesList(
        _ parameters: RAWG_GamesListParameters,
        completion: @escaping ((Result<RAWG_GamesListResponse, RAWG_NetworkError>) -> Void)
    )
    
    func getGameDetails(
        _ gameID: Int,
        apiKey: String,
        completion: @escaping ((Result<RAWG_GameDetails, RAWG_NetworkError>) -> Void)
    )
    
    func downloadImage(
        _ imageURLString: String,
        completion: @escaping ((Result<Data, RAWG_NetworkError>) -> Void)
    )
}

public class RAWG_GamesService {
    
    public static let shared = RAWG_GamesService()
    let webService = DataDownloaderService.shared
    
    private init() {}
}

extension RAWG_GamesService: RAWG_GamesServiceProtocol {
    
    
    public func getGamesList(
        _ parameters: RAWG_GamesListParameters,
        completion: @escaping ((Result<RAWG_GamesListResponse, RAWG_NetworkError>) -> Void)
    ) {
        let gamesListURLString = RAWG_Constants
            .gamesURLConfiguration
            .generateGamesListURLString(parameters)
        
        webService.fetchData(
            from: gamesListURLString,
            dataType: RAWG_GamesListResponse.self,
            decode: true) { result in
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
    ) {
        let gamesListURLString = RAWG_Constants
            .gamesURLConfiguration
            .generateGameDetailURLString(
                gameID,
                key: apiKey
            )
        
        webService.fetchData(
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
        completion: @escaping ((Result<Data, RAWG_NetworkError>) -> Void)
    ) {
        webService.fetchData(
            from: imageURLString,
            dataType: Data.self,
            decode: false) { result in
                switch result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(.generateError(error)))
                }
            }
    }
    
}
