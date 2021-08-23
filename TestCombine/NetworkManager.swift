//
//  NetworkManager.swift
//  TestCombine
//
//  Created by Muzahidul on 22/8/21.
//

import Foundation
import Combine

enum NetworkError: Error {
	case responseError
	case invalidUrl
	case unknownError
}


final class NetworkManager {
	static let shared = NetworkManager()
	
	private var cancellables = Set<AnyCancellable>()
	
	func getData<T: Decodable>(from urlStr: String,  type: T.Type) -> Future<T, Error> {
		return Future<T, Error> { [weak self] promise in
			guard let self = self, let url = URL(string: urlStr) else {
				return promise(.failure(NetworkError.unknownError))
			}
			URLSession.shared.dataTaskPublisher(for: url)
				.tryMap { (data, response) -> Data in
					guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200  else {
						throw NetworkError.responseError
					}
					return data
				}.decode(type: T.self, decoder: JSONDecoder())
				.receive(on: RunLoop.main)
				.sink(receiveCompletion: { completion in
					if case let .failure(error) = completion {
						switch error {
						case let decodingError as DecodingError:
							promise(.failure(decodingError))
						case let networkError as NetworkError:
							promise(.failure(networkError))
							
						default:
							promise(.failure(NetworkError.unknownError))
						}
					}
				}, receiveValue: {
					promise(.success($0))
				}).store(in: &self.cancellables)
		}
		
	}
}
