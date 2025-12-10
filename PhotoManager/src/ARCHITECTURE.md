# Photo Manager - Architecture & Design Patterns

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │  Login   │  │   Main   │  │  Upload  │  │  Admin   │   │
│  │  Frame   │  │  Frame   │  │  Dialog  │  │  Panel   │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
│         MVC Pattern - User Interface Components             │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                 BUSINESS LOGIC LAYER                         │
│  ┌──────────────────────────────────────────────────────┐   │
│  │      PhotoManagementFacade (Facade Pattern)         │   │
│  │  - uploadPhoto()  - searchPhotos()  - updatePhoto() │   │
│  └──────────────────────────────────────────────────────┘   │
│                            │                                 │
│  ┌──────────────────────────────────────────────────────┐   │
│  │     CommandInvoker (Command Pattern)                 │   │
│  │  - UploadPhotoCommand  - UpdatePhotoCommand          │   │
│  └──────────────────────────────────────────────────────┘   │
│                            │                                 │
│  ┌──────────────────────────────────────────────────────┐   │
│  │   ImageProcessor (Decorator Pattern)                 │   │
│  │  - ResizeDecorator - SepiaDecorator - BlurDecorator  │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                DATA & SERVICE LAYER                          │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  UserRepository (Repository + Singleton Pattern)     │   │
│  │  PhotoRepository (Repository + Singleton Pattern)    │   │
│  └──────────────────────────────────────────────────────┘   │
│                            │                                 │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  AuthenticationFactory (Factory Pattern)             │   │
│  │  - LocalAuth  - GoogleAuth  - GithubAuth             │   │
│  └──────────────────────────────────────────────────────┘   │
│                            │                                 │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  StorageStrategy (Strategy Pattern)                  │   │
│  │  - LocalStorageStrategy  - CloudStorageStrategy      │   │
│  └──────────────────────────────────────────────────────┘   │
│                            │                                 │
│  ┌──────────────────────────────────────────────────────┐   │
│  │     Logger (Singleton + Observer Pattern)            │   │
│  │     - Logs all system actions                        │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## Design Patterns Mapping

### 1. Singleton Pattern (3 implementations)
**Purpose**: Ensure only one instance exists
- `PhotoManagerApp`: Application entry point
- `UserRepository`, `PhotoRepository`: Data access
- `Logger`: System-wide logging

**Benefits**:
- Controlled access to shared resources
- Reduced memory footprint
- Global access point

### 2. Builder Pattern
**Purpose**: Construct complex objects step by step
- `User.UserBuilder`: Creates User objects with many optional parameters

**Benefits**:
- Readable object creation
- Immutability support
- Flexible construction

### 3. Factory Pattern
**Purpose**: Create objects without specifying exact class
- `AuthenticationFactory`: Creates appropriate auth service

**Benefits**:
- Loose coupling
- Easy to add new auth providers
- Centralized object creation

### 4. Repository Pattern
**Purpose**: Abstract data access
- `UserRepository`, `PhotoRepository`: Centralized data management

**Benefits**:
- Separation of concerns
- Easy to swap data sources
- Testable business logic

### 5. Strategy Pattern
**Purpose**: Select algorithm at runtime
- `StorageStrategy`: Choose local or cloud storage

**Benefits**:
- Runtime flexibility
- Easy to add new storage types
- Configuration-based selection

### 6. Decorator Pattern
**Purpose**: Add functionality dynamically
- `ImageProcessor` chain: Stack multiple image filters

**Benefits**:
- Flexible feature combination
- Open/Closed principle
- No class explosion

### 7. Facade Pattern
**Purpose**: Simplify complex subsystems
- `PhotoManagementFacade`: Single interface for photo operations

**Benefits**:
- Simplified API
- Reduced coupling
- Easier to use

### 8. Command Pattern
**Purpose**: Encapsulate operations
- `UploadPhotoCommand`, `UpdatePhotoCommand`, etc.

**Benefits**:
- Undo/Redo support
- Operation queuing
- Logging and auditing

## Data Flow Examples

### Example 1: User Registration
```
1. User clicks "Register" → RegistrationDialog
2. User fills form and selects AuthProvider
3. AuthenticationFactory creates appropriate service
4. Service creates User (using Builder pattern)
5. UserRepository saves user (Singleton)
6. Logger records action (Observer pattern)
```

### Example 2: Photo Upload
```
1. User clicks "Upload" → UploadDialog
2. User selects file and processing options
3. ImageProcessor chain created (Decorator pattern)
4. UploadPhotoCommand created (Command pattern)
5. CommandInvoker executes command
6. PhotoManagementFacade handles upload (Facade pattern)
7. StorageStrategy saves file (Strategy pattern)
8. PhotoRepository stores metadata (Repository pattern)
9. Logger records action (Observer pattern)
```

### Example 3: Photo Search
```
1. User enters search criteria → SearchDialog
2. PhotoSearchCriteria built (Specification pattern)
3. PhotoManagementFacade.searchPhotos() called (Facade)
4. PhotoRepository.findAll() retrieves data (Repository)
5. Criteria filters results
6. Results displayed in table
7. Logger records search (Observer)
```

## Pattern Interaction Matrix

```
┌────────────┬──────────┬──────────┬──────────┬──────────┐
│ Pattern    │ Layer    │ Uses     │ Used By  │ Related  │
├────────────┼──────────┼──────────┼──────────┼──────────┤
│ Singleton  │ All      │ -        │ Everyone │ -        │
├────────────┼──────────┼──────────┼──────────┼──────────┤
│ Builder    │ Data     │ -        │ Factory  │ -        │
├────────────┼──────────┼──────────┼──────────┼──────────┤
│ Factory    │ Service  │ Builder  │ Facade   │ Strategy │
├────────────┼──────────┼──────────┼──────────┼──────────┤
│ Repository │ Data     │ Logger   │ Facade   │ Singleton│
├────────────┼──────────┼──────────┼──────────┼──────────┤
│ Strategy   │ Service  │ Logger   │ Facade   │ -        │
├────────────┼──────────┼──────────┼──────────┼──────────┤
│ Decorator  │ Business │ Logger   │ Command  │ -        │
├────────────┼──────────┼──────────┼──────────┼──────────┤
│ Facade     │ Business │ All      │ UI/Cmd   │ -        │
├────────────┼──────────┼──────────┼──────────┼──────────┤
│ Command    │ Business │ Facade   │ UI       │ -        │
└────────────┴──────────┴──────────┴──────────┴──────────┘
```

## Key Design Decisions

1. **In-Memory Storage**: Simplified for demo (can be replaced with DB)
2. **Swing GUI**: Desktop application requirement
3. **Pattern Layering**: Each layer has appropriate patterns
4. **Loose Coupling**: Interfaces and abstractions throughout
5. **Extensibility**: Easy to add new features
6. **Testability**: Each component can be tested independently

## Performance Considerations

- Repositories use HashMap for O(1) lookups
- Image processing uses chained decorators
- Logging is non-blocking (could be async in production)
- GUI updates on event dispatch thread

## Security Notes

- Passwords should be hashed (simplified for demo)
- OAuth tokens should be encrypted
- File uploads should be validated
- Admin actions should be authenticated
