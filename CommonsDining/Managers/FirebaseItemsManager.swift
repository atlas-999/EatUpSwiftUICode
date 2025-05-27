//
//  ItemsManager.swift
//  CommonsDining
//
//  Created by Caden Cooley on 3/21/25.
//

import Foundation
import FirebaseFirestore

class FirebaseItemsManager {
    
    static let shared = FirebaseItemsManager()
    
    private let itemsCollection = Firestore.firestore().collection("Items")
    private let userCollection = Firestore.firestore().collection("Users")
    
    private func itemDocument(itemId: String) -> DocumentReference {
        itemsCollection.document(itemId)
    }
    
    func fetchItemsFromSearch(keyword: String) async throws -> [Item] {
        
        var items: [Item] = []
        
        do {
            let querySnapshot = try await itemsCollection.whereField("keywords", arrayContains: keyword.lowercased()).limit(to: 30).getDocuments()
          for document in querySnapshot.documents {
              var newitem = await mapItem(item: document)
              items.append(newitem)
          }
        } catch {
          print("Error getting documents: \(error)")
        }
        
        return items
    }
    
    func getAllItems(currentItems: [Item]) async throws -> [Item] {
        var items: [Item] = currentItems
        
        var newdocs: QuerySnapshot
        
        var query: Query = itemsCollection.limit(to: 20)
        
        if items.count > 0 {
            var lastItem = try await getDocumentSnapshot(documentId: items.last!.id)
            query = query.start(afterDocument: lastItem)
            newdocs = try await query.getDocuments()
        } else {
            newdocs = try await query.getDocuments()
        }
        
        for i in newdocs.documents {
            let item = await mapItem(item: i)
            items.append(item)
        }
        
        return items
    }
    
    func getTodaysItems() async throws -> [Item] {
        let snapshot = try await itemsCollection.whereField("today", isEqualTo: "True").getDocuments()
        
        var items: [Item] = []
        
        for i in snapshot.documents {
            let item = await mapItem(item: i)
            items.append(item)
        }
        
        items = sortItems(items: items)
        
        return items
    }
    
    func getOneItem(id: String) async throws -> Item {
        let snapshot = try await itemsCollection.document("\(id)").getDocument()
        
        let item = await mapItem(item: snapshot)
        
        return item
    }
    
    func sortItems(items: [Item]) -> [Item] {
        return items.sorted { lhs, rhs in
            let lhsScore = computeScore(for: lhs)
            let rhsScore = computeScore(for: rhs)
            return lhsScore > rhsScore
        }
    }
    
    private func computeScore(for item: Item) -> Float {
        var score: Float = 0

        if item.isFavorite {
            score += 1.0
        }

        score += Float(item.calories) / 450
        score += Float(item.protein) / 20

        let secondsSinceLastSeen = Calendar.current.dateComponents(
            [.second],
            from: item.lastSeen,
            to: Date()
        ).second ?? 3600

        score += 1 / (1 + Float(secondsSinceLastSeen/60))

        return score
    }
    
    func mapItem(item: DocumentSnapshot) async -> Item {
        var itemName = item["name"] as? String ?? ""
        var itemPeriod: Period = .none
        var itemCategory: Category = .none
        var itemToday = (item["today"] as? String == "True")
        var itemTomorrow = (item["tomorrow"] as? String == "True")
        let itemCalories = Int(item["calories"] as? String ?? "0") ?? 0
        let itemProtein = Int(item["protein"] as? String ?? "0") ?? 0
        let itemID = item["id"] as? String ?? ""
        let keywords = item["keywords"] as? [String] ?? ["Key"]

        let lastSeen: Date = {
            let isoDate = item["lastSeen"] as? String
            let formatter = ISO8601DateFormatter()
            formatter.timeZone = TimeZone(abbreviation: "CST")
            return formatter.date(from: isoDate ?? "") ?? Date()
        }()

        for per in Period.allCases {
            if let period = item["period"] as? String, period == per.rawValue {
                itemPeriod = per
            }
        }

        for cat in Category.allCases {
            if let category = item["category"] as? String, category == cat.rawValue {
                itemCategory = cat
            }
        }

        let isFavorite = await withCheckedContinuation { continuation in
            CoreDataManager.shared.getFavoritedItems { favorites in
                let isFav = favorites.contains(where: { $0.id == itemID })
                continuation.resume(returning: isFav)
            }
        }

        return Item(
            id: itemID,
            name: itemName.capitalized,
            calories: itemCalories,
            protein: itemProtein,
            category: itemCategory,
            period: itemPeriod,
            today: itemToday,
            tomorrow: itemTomorrow,
            isFavorite: isFavorite,
            lastSeen: lastSeen,
            keywords: keywords
        )
    }

    
    func updateLastSeen(id: String) async {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "CST")
        let date = dateFormatter.string(from: Date.now)
        let itemRef = itemsCollection.document(id)
        do {
          try await itemRef.updateData([
            "lastSeen": date
          ])
          print("Document successfully updated")
        } catch {
          print("Error updating document: \(error)")
        }
    }
    
    func getDocumentSnapshot(documentId: String) async throws -> DocumentSnapshot {
        
        let docRef = itemsCollection.document(documentId)
        
        let snapshot = try await docRef.getDocument()
        
        if snapshot.exists {
            return snapshot
        } else {
            throw NSError(domain: "FirestoreError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"])
        }
    }
    
    func favoriteItemInDB(itemId: String, userId: String) async throws {
        
        let docRef = userCollection.document(userId)
        
        do {
            try await docRef.updateData([
                "favorites": FieldValue.arrayUnion([itemId])
            ])
            print("Item successfully added to favorites")
        } catch {
            print("Failed to add favorite: \(error)")
        }
    }
    
    func unFavoriteItemInDB(itemId: String, userId: String) async throws {
        
        let docRef = userCollection.document(userId)
        
        do {
            try await docRef.updateData([
                "favorites": FieldValue.arrayRemove([itemId])
            ])
            print("Item removed from favorites")
        } catch {
            print("Failed to remove favorite: \(error)")
        }
    }
    
    func getItemsWithIds(ids: [String]) async throws -> [Item] {
        var items: [Item] = []
        
        for id in ids {
            var docRef = itemsCollection.document(id)
            do {
              let document = try await docRef.getDocument()
              if document.exists {
                  let newItem = await mapItem(item: document)
                  items.append(newItem)
              }
            } catch {
              print("Error getting document: \(error)")
            }
        }
        
        return items
    }
}
