//
//  CoreDataService.swift
//  CommonsDining
//
//  Created by Caden Cooley on 3/31/25.
//

import Foundation
import CoreData

class CoreDataManager {
    
    private let container: NSPersistentContainer
    private let containerName: String = "FavoritesContainer"
    private let itemName: String = "FavoritedItem"
    
    static let shared = CoreDataManager()
    
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    init() {
        container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Error with core data \(error)")
            }
        }
    }
    
    func getFavoritedItems(completion: @escaping ([FavoritedItem]) -> Void) {
        let context = container.newBackgroundContext()
        context.perform {
            let request = NSFetchRequest<FavoritedItem>(entityName: self.itemName)
            do {
                let items = try context.fetch(request)
                completion(items)
            } catch {
                print("Error fetching items: \(error)")
                completion([])
            }
        }
    }
    
    func addFavorite(item: Item) {
        let context = container.newBackgroundContext()
        context.perform {
            let newItem = FavoritedItem(context: context)
            newItem.id = item.id
            newItem.name = item.name
            do {
                try context.save()
                print("Item added")
            } catch {
                print("Error saving item: \(error)")
            }
        }
        
        /// + add to firebase
    }
    
    func deleteFavorite(id: String) {
        let context = container.newBackgroundContext()
        context.perform {
            let request = NSFetchRequest<FavoritedItem>(entityName: self.itemName)
            request.predicate = NSPredicate(format: "id == %@", id)
            request.fetchLimit = 1
            do {
                if let item = try context.fetch(request).first {
                    context.delete(item)
                    try context.save()
                    print("Item deleted")
                }
            } catch {
                print("Error deleting item: \(error)")
            }
        }
        
        //// + delete from firebase 
    }
    
}
