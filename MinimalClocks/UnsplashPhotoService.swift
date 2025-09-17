//
//  UnsplashPhotoService.swift
//  MinimalClocks
//
//  Created by NovoTrax Dev1 on 19/01/25.
//

import Foundation
class UnsplashPhotoService: ObservableObject {
    
    private static var service: UnsplashPhotoService?
    
    static func shared() -> UnsplashPhotoService {
        if service == nil {
            service = UnsplashPhotoService()
        }
        return service!
    }
    
    private init() {
        
    }
    func fetchRandomPhoto(query: String) async throws -> UnsplashPhoto {
        // Construct the URL
        let urlString = "https://api.unsplash.com/photos/random"
        guard let url = URL(string: urlString) else {
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
        decoder.dateDecodingStrategy = .iso8601 // To handle createdAt if you want it as a Date
        let photo = try decoder.decode(UnsplashPhoto.self, from: data)
        
        return photo
    }
}
