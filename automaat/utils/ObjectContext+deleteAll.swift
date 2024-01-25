import Foundation
import CoreData

extension NSManagedObjectContext {
    func deleteAll(entity: String) throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try self.execute(batchDeleteRequest)
    }
}

