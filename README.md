# iOS Combine test drive
 	
[![Swift](https://img.shields.io/badge/Swift-5.3.2-brightgreen)](https://swift.org/)
[![Combine](https://img.shields.io/badge/Combine-Framework-green)](https://developer.apple.com/documentation/combine)
[![Xcode](https://img.shields.io/badge/Xcode-13-yellowgreen)](https://developer.apple.com/)
[![Twitter: @mmsaddam](https://img.shields.io/twitter/follow/espadrine.svg?style=social&logo=twitter&label=Follow)](https://twitter.com/saddm_ruet)

This is sample iOS app which fetch data from remote using Combine Framework

## Sample Code
  ### NetworkManager acts as Publisher
    
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
      
  ### ViewModel as Subscriber
  
    final class ViewModel {
        private var apiClient = NetworkManager.shared
        private(set) var list = [String]()
        private var cancelables: Set<AnyCancellable> = Set<AnyCancellable>()
        weak var delegate: ViewModelDelegate?

        func getData() {
          let url = "https://pastebin.com/raw/A0CgArX3"

          apiClient.getData(from: url, type: MyData.self)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
            self?.delegate?.dataLoadingDidFinished()
            print(completion)
          } receiveValue: { [weak self]  data in
            self?.list = data.data.categories.map { $0["name"] ?? "" }
          }
          .store(in: &cancelables)

        }
	}


 
 
