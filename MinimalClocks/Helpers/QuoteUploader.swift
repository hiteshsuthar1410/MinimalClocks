//
//  QuoteUploader.swift
//  MinimalClocks
//
//  Created by Hitesh Suthar on 18/01/25.
//

import FirebaseSharedSwift
import FirebaseFirestore

import Foundation
class QuoteUploader {
    private let db = Firestore.firestore()
    
    func uploadQuotesFromJSON(fileURL: URL) async throws -> Int {
        // Read and decode JSON
        let data = try Data(contentsOf: fileURL)
        var dict = try JSONDecoder().decode([String: [Quote]].self, from: data)
        
        // Create batch for efficient uploading
        let batch = db.batch()
        var uploadCount = 0
        guard var quotes = dict["Quotes"] else {
            fatalError()
        }
        for index in quotes.indices {
            // Get new document reference and set its ID to the quote
            let docRef = db.collection("PositiveQuotesDataset").document()
            
            quotes[index].id = docRef.documentID
            
            if let data = try? JSONEncoder().encode(quotes[index]),
               let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                batch.setData(dict, forDocument: docRef)
                uploadCount += 1
            }
            
            // Commit batch every 500 documents (Firestore limit)
            if uploadCount % 500 == 0 {
                try await batch.commit()
            }
        }
        
        // Commit any remaining documents
        if uploadCount % 500 != 0 {
            try await batch.commit()
        }
        
        return uploadCount
    }
}

