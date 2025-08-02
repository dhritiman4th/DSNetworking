//
//  NetworkManager.swift
//  SampleMVVM
//
//  Created by Dhritiman Saha on 23/07/25.
//

import Foundation
import Combine

@available(iOS 13.0, *)
public class APIManager: NSObject {
    static let shared = APIManager()
    private override init() {}
    private var cancellable = Set<AnyCancellable>()
    
    public func get<T: Codable>(from urlString: String, responseType: T.Type) -> Future<T, Error> {
        return Future<T, Error> { [weak self] promise in
            guard let self = self, let url = URL(string: urlString) else {
                promise(.failure(APIError.invalidURL))
                return
            }
            URLSession.shared.dataTaskPublisher(for: url)
                .tryMap { (data, response) -> Data in
                    guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                        throw APIError.invalidResponse
                    }
                    return data
                }
                .decode(type: responseType, decoder: JSONDecoder())
                .receive(on: RunLoop.main)
                .sink { (completion) in
                    if case let .failure(error) = completion {
                        switch error {
                        case let decodingError as DecodingError:
                            promise(.failure(decodingError))
                        case let apiError as APIError:
                            promise(.failure(apiError))
                        default:
                            promise(.failure(error))
                        }
                    }
                } receiveValue: { result in
                    promise(.success(result))
                }
                .store(in: &self.cancellable)
        }
    }
}
 

