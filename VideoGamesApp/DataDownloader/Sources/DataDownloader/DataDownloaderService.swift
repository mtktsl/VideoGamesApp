import Foundation

public protocol DataDownloaderServiceProtocol: AnyObject {
    func fetchData<T: Decodable>(
        from urlString: String,
        dataType: T.Type,
        decode: Bool,
        completion: @escaping (Result<T, DataDownloaderServiceError>) -> Void
    ) -> URLSessionDataTask?
}

public class DataDownloaderService: DataDownloaderServiceProtocol {
    
    public static let shared: DataDownloaderServiceProtocol = DataDownloaderService()
    
    private init() {}
    
    public func fetchData<T: Decodable>(
        from urlString: String,
        dataType: T.Type = Data.self,
        decode: Bool = false,
        completion: @escaping (Result<T, DataDownloaderServiceError>) -> Void
    ) -> URLSessionDataTask? {
        
        guard let url = URL(string: urlString)
        else {
            completion(.failure(.urlError))
            return nil
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard let response = response as? HTTPURLResponse
            else {
                if let error, error.localizedDescription == "cancelled" {
                    completion(.failure(.cancelled))
                } else {
                    completion(.failure(.noResponse))
                }
                return
            }
            
            if response.statusCode < 200 || response.statusCode > 299 {
                completion(.failure(.statusCode(response.statusCode,
                                                responseData: data)))
                return
            }
            
            guard let data
            else {
                completion(.failure(.emptyResponse))
                return
            }
            
            if !decode {
                if let data = data as? T {
                    completion(.success(data))
                } else {
                    completion(.failure(.typeMissMatchError))
                }
                
            } else if let resultData = try? JSONDecoder().decode(T.self,
                                                                 from: data) {
                completion(.success(resultData))
            } else {
                completion(.failure(.decodeError))
            }
        }
        task.resume()
        return task
    }
}
