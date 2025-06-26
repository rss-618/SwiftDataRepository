import Foundation
import SwiftData

@available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
protocol SwiftDataServiceProtocol<T> {
    associatedtype T: PersistentModel
    func fetchData(predicate: Predicate<T>?, sortBy: [SortDescriptor<T>]) -> [T]
    func addData(_ notepad: T)
    func removeData(_ notepad: T)
}

// Default Arguements for Protocol
@available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
extension SwiftDataServiceProtocol {
    func fetchData(predicate: Predicate<T>? = nil,
                       sortBy: [SortDescriptor<T>] = .init()) -> [T] {
        self.fetchData(predicate: predicate, sortBy: sortBy)
    }
}

@available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
open class SwiftDataService<T: PersistentModel>: SwiftDataServiceProtocol {
    
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
    
    func fetchData(predicate: Predicate<T>? = nil,
                   sortBy: [SortDescriptor<T>] = .init()) -> [T] {
        do {
            return try modelContext.fetch(FetchDescriptor<T>(predicate: predicate,
                                                             sortBy: sortBy))
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func addData(_ item: T) {
        modelContext.insert(item)
        saveContext()
    }
    
    func removeData(_ item: T) {
        modelContext.delete(item)
        saveContext()
    }
    
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
