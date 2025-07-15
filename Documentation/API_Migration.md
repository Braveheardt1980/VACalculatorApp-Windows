# SwiftUI to SwiftCrossUI Migration Guide

## Overview

This document outlines the migration process from SwiftUI to SwiftCrossUI for the VA Calculator App Windows conversion.

## Direct Replacements

### Imports
```swift
// Original SwiftUI
import SwiftUI

// SwiftCrossUI
import SwiftCrossUI
import DefaultBackend
```

### Basic Components
Most SwiftUI components have direct SwiftCrossUI equivalents:

```swift
// Layout containers - NO CHANGES NEEDED
VStack { ... }
HStack { ... }
ZStack { ... }

// Basic controls - NO CHANGES NEEDED
Text("Hello")
Button("Click me") { action() }
TextField("Input", text: $binding)

// Property wrappers - NO CHANGES NEEDED
@State private var value = 0
@Binding var data: String
```

## Components Requiring Adaptation

### Navigation
```swift
// SwiftUI
NavigationView {
    NavigationLink("Details", destination: DetailView())
}

// SwiftCrossUI
NavigationView {
    NavigationLink("Details", destination: DetailView())
}
// Note: API is the same, but behavior may differ slightly
```

### Sheets and Modals
```swift
// SwiftUI
.sheet(isPresented: $showSheet) {
    SheetContent()
}

// SwiftCrossUI
.sheet(isPresented: $showSheet) {
    SheetContent()
}
// Note: Same API, cross-platform implementation
```

## Migration Checklist

- [ ] Replace `import SwiftUI` with `import SwiftCrossUI`
- [ ] Add `import DefaultBackend` for Windows backend
- [ ] Test all UI components on Windows
- [ ] Verify navigation flows work correctly
- [ ] Check sheet/modal presentations
- [ ] Validate text input and form controls
- [ ] Test color schemes and styling
- [ ] Ensure proper window sizing and positioning

## Known Differences

1. **Rendering Backend**: SwiftCrossUI uses native Windows controls vs SwiftUI's custom rendering
2. **Performance**: Different optimization characteristics
3. **Platform Integration**: Native Windows behavior vs macOS conventions
4. **Font Rendering**: May differ slightly from macOS appearance

## Testing Strategy

1. **Component-by-Component**: Test each UI component individually
2. **Integration Testing**: Verify component interactions
3. **Cross-Platform**: Compare behavior with original macOS app
4. **User Experience**: Ensure Windows-native feel while preserving functionality