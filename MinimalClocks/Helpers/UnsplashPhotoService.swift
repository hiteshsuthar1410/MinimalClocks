//
//  UnsplashPhotoService.swift
//  MinimalClocks
//
//  Created by Hitesh Suthar on 19/01/25.
//

import Foundation
import UIKit.UIImage

@Observable
class UnsplashPhotoService {
    
    private static var service: UnsplashPhotoService?
    
    static func shared() -> UnsplashPhotoService {
        if service == nil {
            service = UnsplashPhotoService()
        }
        return service!
    }
    
    private init() {
        
    }
    func fetchRandomPhoto(query: String) async throws -> (UIImage, UnsplashPhoto) {
        // Construct the URL with orientation and query
        var urlComponents = URLComponents(string: "https://api.unsplash.com/photos/random")!
        var queryItems = [URLQueryItem(name: "orientation", value: "landscape")]
        if !query.isEmpty {
            queryItems.append(URLQueryItem(name: "query", value: query))
        }
        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.setValue("Client-ID bvIdxXmtuKQcImGYyivBDAZsPEjJ0kMybBLgbAdy9MU", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        // Make the network call
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check for HTTP response status
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // Decode the JSON response
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        let photoData = try decoder.decode(UnsplashPhoto.self, from: data)
        
        let (imageData, _) = try await URLSession.shared.data(from: URL(string: photoData.urls!.regular)!)
        return (UIImage(data: imageData) ?? UIImage(named: "backupGradi")!, photoData)
    }

//    func fetchRandomPhoto(query: String) async throws -> (UIImage, UnsplashPhoto) {
//        // Construct the URL
//        let urlString = "https://api.unsplash.com/photos/random"
//        guard let url = URL(string: urlString) else {
//            throw URLError(.badURL)
//        }
//        
//        // Create the request
//        var request = URLRequest(url: url)
//        request.setValue("Client-ID bvIdxXmtuKQcImGYyivBDAZsPEjJ0kMybBLgbAdy9MU", forHTTPHeaderField: "Authorization")
//        request.httpMethod = "GET"
//        
//        // Make the network call
//        let (data, response) = try await URLSession.shared.data(for: request)
//        
//        // Check for HTTP response status
//        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
//            throw URLError(.badServerResponse)
//        }
//        
//        // Decode the JSON response
//        let decoder = JSONDecoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
//        decoder.dateDecodingStrategy = .iso8601 // To handle createdAt if you want it as a Date
//        let photoData = try decoder.decode(UnsplashPhoto.self, from: data)
//        
//        let (imageData, _) = try await URLSession.shared.data(from: URL(string: photoData.urls!.regular)!)
//        return (UIImage(data: imageData) ?? UIImage(named: "backupGradi")!, photoData)
//    }
}
