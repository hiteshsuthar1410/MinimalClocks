//
//  File.swift
//  MinimalClocks
//
//  Created by NovoTrax Dev1 on 18/01/25.
//

import Foundation
import Firebase

final class QuoteService: NetworkService {
    // Singleton instance
    static let shared = QuoteService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // Generic fetch function
    func fetch<T: Codable>(_ type: T.Type,
                          from collection: String,
                          whereField: String? = nil,
                          isEqualTo: Any? = nil) async throws -> [T] {
        var query: Query = db.collection(collection)
        
        if let field = whereField, let value = isEqualTo {
            query = query.whereField(field, isEqualTo: value)
        }
        
        let snapshot = try await query.getDocuments()
        
        return try snapshot.documents.compactMap { document -> T? in
            var data = document.data()
            data["id"] = document.documentID
            
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            return try JSONDecoder().decode(T.self, from: jsonData)
        }
    }
    
    func fetch<T: Codable>(_ type: T.Type,
                           from collection: String,
                           whereField: String? = nil,
                           isEqualTo: Any? = nil,
                           completion: @escaping (Result<[T], Error>) -> Void) {
        
        var query: Query = db.collection(collection)
        
        if let field = whereField, let value = isEqualTo {
            query = query.whereField(field, isEqualTo: value)
        }
        
        query.getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion(.success([]))
                return
            }
            
            do {
                let items: [T] = try documents.compactMap { document in
                    var data = document.data()
                    data["id"] = document.documentID
                    
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    return try JSONDecoder().decode(T.self, from: jsonData)
                }
                completion(.success(items))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
//    func fetch<T: Codable>(_ type: T.Type,
//                          from collection: String,
//                          whereField: String? = nil,
//                          isEqualTo: Any? = nil,
//                           completion: @escaping (Result<T, Error>) -> ()) {
//        var query: Query = db.collection(collection)
//        
//        if let field = whereField, let value = isEqualTo {
//            query = query.whereField(field, isEqualTo: value)
//        }
//        
//        let snapshot = try await query.getDocuments()
//        
//        return try snapshot.documents.compactMap { document -> T? in
//            var data = document.data()
//            data["id"] = document.documentID
//            
//            let jsonData = try JSONSerialization.data(withJSONObject: data)
//            return try JSONDecoder().decode(T.self, from: jsonData)
//        }
//    }
    
    // MARK: - Quote specific functions
    func fetchRandomQuote() async throws -> Quote {
        // Get all quotes
        let quotes = try await fetch(Quote.self, from: "PositiveQuotesDataset")
        guard !quotes.isEmpty else {
            throw NSError(domain: "QuoteService", code: 404, userInfo: [NSLocalizedDescriptionKey: "No quotes found"])
        }
        
        // Get random quote
        let randomIndex = Int.random(in: 0..<quotes.count)
        return quotes[randomIndex]
    }
    
    // Optimized version for large collections
    func fetchRandomQuoteOptimized() async throws -> Quote {
        let _snapshot = try await db.collection("quotes").count.getAggregation(source: .server)
        let count = Int(truncating: _snapshot.count)
        
        guard count > 0 else {
            throw NSError(domain: "QuoteService", code: 404, userInfo: [NSLocalizedDescriptionKey: "No quotes found"])
        }
        
        let randomIndex = Int.random(in: 0..<count)
        let snapshot = try await db.collection("quotes")
            .limit(to: 1)
            .start(at: [randomIndex])
            .getDocuments()
        
        guard let document = snapshot.documents.first else {
            throw NSError(domain: "QuoteService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Quote not found"])
        }
        
        var data = document.data()
        data["id"] = document.documentID
        
        let jsonData = try JSONSerialization.data(withJSONObject: data)
        return try JSONDecoder().decode(Quote.self, from: jsonData)
    }
    
    // Function to fetch quote excluding already sent quotes
    func fetchRandomQuote(excluding sentQuoteIds: [String]) async throws -> Quote {
        var attempts = 0
        let maxAttempts = 5
        
        while attempts < maxAttempts {
            let quote = try await fetchRandomQuote()
            if !sentQuoteIds.contains(quote.id) {
                return quote
            }
            attempts += 1
        }
        
        throw NSError(domain: "QuoteService", code: 404,
                     userInfo: [NSLocalizedDescriptionKey: "No new quotes available"])
    }
}
