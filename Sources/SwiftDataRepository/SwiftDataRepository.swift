import Foundation
import SwiftData

public protocol SwiftDataRepository<T> {
    associatedtype T: PersistentModel
    func fetchData(predicate: Predicate<T>?, sortBy: [SortDescriptor<T>]) -> [T]
    func addData(_ notepad: T)
    func removeData(_ notepad: T)
}

// Default Arguments for Protocol
extension SwiftDataRepository {
    public func fetchData(predicate: Predicate<T>? = nil,
                          sortBy: [SortDescriptor<T>] = .init()) -> [T] {
        self.fetchData(predicate: predicate, sortBy: sortBy)
    }
}


public final class SwiftDataRepositoryImpl<T: PersistentModel>: SwiftDataRepository {
    
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    init(modelContainer: ModelContainer, modelContext: ModelContext) {
        self.modelContext = modelContext
        self.modelContainer = modelContainer
    }
    
    @MainActor
    required public init() {
        let schema = Schema([
            T.self,
        ])
        self.modelContainer = try! ModelContainer(for: schema,
                                                  configurations: ModelConfiguration(isStoredInMemoryOnly: false))
        self.modelContext = modelContainer.mainContext
    }
    
    public func fetchData(predicate: Predicate<T>? = nil,
                   sortBy: [SortDescriptor<T>] = .init()) -> [T] {
        do {
            return try modelContext.fetch(FetchDescriptor<T>(predicate: predicate,
                                                             sortBy: sortBy))
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    public func addData(_ item: T) {
        modelContext.insert(item)
        saveContext()
    }
    
    public func removeData(_ item: T) {
        modelContext.delete(item)
        saveContext()
    }
    
    public func saveContext() {
        do {
            try modelContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
