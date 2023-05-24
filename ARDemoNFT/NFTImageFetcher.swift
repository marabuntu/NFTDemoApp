//
//  NFTImageFetcher.swift
//  ARDemoNFT
//
//  Created by Edgar Borovik on 14/04/2022.
//

import UIKit

final class NFTImageFetcher {
    func fetchRandom(completion: @escaping (UIImage?) -> Void) {
        let randomNftNumber = "\(Int.random(in: 1..<200))"
        let path = "https://testnets-api.opensea.io/api/v1/asset/0x16baf0de678e52367adc69fd067e5edd1d33e3bf/" + randomNftNumber
        guard let url = URL(string: path) else {
            completion(nil)
            return
        }
        let request = NSMutableURLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "GET"

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest) { [weak self] data, response, error in
            guard
                let data = data,
                let model = try? JSONDecoder().decode(NFTResponse.self, from: data),
                let url = URL(string: model.image_url)
            else {
                print(response as? HTTPURLResponse ?? "response missing")
                completion(nil)
                return
            }
            self?.loadImage(url: url, completion: completion)
        }
        dataTask.resume()
    }

    private func loadImage(url: URL, completion: @escaping (UIImage?) -> Void) {
        let request = NSMutableURLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "GET"

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest) { data, response, error in
            guard let data = data, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            completion(image)
        }
        dataTask.resume()
    }
}

fileprivate struct NFTResponse: Codable {
    let image_url: String
}
