Swift Data by default doesn't have very good MVVM Interface, so I created one.

# Example Implementation

Notepad.swift
```swift
import Foundation
import SwiftData

@Model
final class Notepad {
...
}
```

Ext_SwiftDataRepository.swift
```swift
import SwiftDataRepository

extension SwiftDataRepository where Self == SwiftDataRepositoryImpl<Notepad> {
    
    @MainActor
    static var notepad: Self {
        SwiftDataRepositoryImpl<Notepad>()
    }
    
}
```

ViewModel.swift
```swift
...
import SwiftDataRepository

@Observable
class AppViewModel {
    
    let notepadRepository: any SwiftDataRepository<Notepad>

...

    @MainActor
    public init<NotepadRepository: SwiftDataRepository<Notepad>>(
        notepadRepository: NotepadRepository,
    ) {
...
```

View Model Implementation (anywhere)
```swift
HomeView()
    .environment(AppViewModel(notepadRepository: .notepad))
```

# Summary

This is a very simple implementation of what I wanted that allows for mockability for testing purposes. If you feel there should be any changes or improvements feel free to leave an issue. My implementation is just a example of how I use it in my code; there is no correct way.
