//
//  SongService.swift
//  AppleMusic
//
//  Created by Artyom Petrichenko on 17.06.2024.
//

import Foundation

class SongService {
    private let cache = URLCache(memoryCapacity: 100 * 1024 * 1024,
                                 diskCapacity: 500 * 1024 * 1024,
                                 diskPath: nil)

    func fetchSongs(with keyword: String, completion: @escaping (Result<[Song], Error>) -> Void) {
        let urlString = "https://itunes.apple.com/search?term=\(keyword)&entity=song"
        guard let url = URL(string: urlString) else { return }

        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)

        if let data = cache.cachedResponse(for: request)?.data {
            do {
                let decodedData = try JSONDecoder().decode(SearchResults.self, from: data)
                completion(.success(decodedData.results))
                return
            } catch {
                completion(.failure(error))
                return
            }
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data, let response = response else { return }

            let cachedData = CachedURLResponse(response: response, data: data)
            self.cache.storeCachedResponse(cachedData, for: request)

            do {
                let decodedData = try JSONDecoder().decode(SearchResults.self, from: data)
                completion(.success(decodedData.results))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchTopSongs(completion: @escaping (Result<[Song], Error>) -> Void) {
        let urlString = "https://itunes.apple.com/search?term=deftones&entity=song&limit=15"
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }

            do {
                let decodedData = try JSONDecoder().decode(SearchResults.self, from: data)
                completion(.success(decodedData.results))
            } catch {
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }.resume()
    }
}

enum NetworkError: Error {
    case invalidURL
    case noData
}

struct SearchResults: Codable {
    let results: [Song]
}
