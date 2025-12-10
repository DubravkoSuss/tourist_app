# Tourist Sights App - Architecture Documentation

## 🏗️ Architecture Overview

This application follows a **Clean Architecture** pattern with clear separation of concerns across three main layers: **Domain**, **Data**, and **Presentation**. The architecture is designed for a tourist sights application with authentication, favorites management, and sight exploration features.

```
lib/
├── data/                  # Data layer (external data sources)
├── domain/                # Business logic layer (pure Dart)
├── presentation/          # UI layer (Flutter widgets)
├── injection_container.dart  # Dependency injection setup
└── main.dart              # Application entry point
```

---

## 📁 Detailed Architecture Structure

### 1. Domain Layer (Business Logic)

The domain layer contains the core business logic and is independent of any framework or external dependencies.

```
domain/
├── entities/
│   ├── sight.dart                     # Sight entity (tourist attraction)
│   │   └── Core business object representing a tourist sight
│   │       - Properties: id, name, description, location, imageUrl, rating, etc.
│   │       - Pure Dart class with no dependencies
│   │
│   └── user.dart                      # User entity
│       └── Core business object representing an authenticated user
│           - Properties: uid, email, displayName, photoUrl
│           - Pure Dart class with no dependencies
│
├── repositories/
│   ├── auth_repository.dart           # Authentication contract
│   │   └── Abstract interface for authentication operations
│   │       - signIn(email, password)
│   │       - signUp(email, password)
│   │       - signOut()
│   │       - getCurrentUser()
│   │
│   ├── sights_repository.dart         # Sights management contract
│   │   └── Abstract interface for sight operations
│   │       - getSights()
│   │       - getSightById(id)
│   │       - searchSights(query)
│   │
│   └── favorites_repository.dart      # Favorites management contract
│       └── Abstract interface for favorites operations
│           - getFavorites(userId)
│           - addFavorite(userId, sightId)
│           - removeFavorite(userId, sightId)
│           - isFavorite(userId, sightId)
│
└── usecases/
    ├── auth/
    │   ├── sign_in_usecase.dart       # UseCase: Sign in user
    │   │   └── Handles user authentication with email/password
    │   │
    │   ├── sign_up_usecase.dart       # UseCase: Register new user
    │   │   └── Handles new user registration
    │   │
    │   ├── sign_out_usecase.dart      # UseCase: Sign out user
    │   │   └── Handles user sign out
    │   │
    │   └── get_current_user_usecase.dart  # UseCase: Get current user
    │       └── Retrieves currently authenticated user
    │
    ├── sights/
    │   └── get_sights_usecase.dart    # UseCase: Get all sights
    │       └── Retrieves list of tourist sights
    │
    └── favorites/
        ├── get_favorites_usecase.dart  # UseCase: Get user favorites
        │   └── Retrieves user's favorite sights
        │
        ├── add_favorite_usecase.dart   # UseCase: Add favorite
        │   └── Adds a sight to user's favorites
        │
        ├── remove_favorite_usecase.dart # UseCase: Remove favorite
        │   └── Removes a sight from user's favorites
        │
        └── is_favorite_usecase.dart    # UseCase: Check if favorite
            └── Checks if a sight is in user's favorites
```

**Key Principles:**
- **Entities**: Pure business objects with no dependencies
- **Repositories**: Abstract interfaces defining contracts
- **UseCases**: Single-responsibility business operations
- **Dependency Rule**: Domain layer has no dependencies on outer layers

---

### 2. Data Layer (External Data)

The data layer implements the repository interfaces and handles all external data operations.

```
data/
├── datasources/
│   ├── local/
│   │   ├── favorites_local_datasource.dart  # Local favorites storage
│   │   │   └── Manages favorites using Hive/SharedPreferences
│   │   │       - saveFavorite(userId, sightId)
│   │   │       - getFavorites(userId)
│   │   │       - deleteFavorite(userId, sightId)
│   │   │
│   │   └── mock_sights_data.dart            # Mock data for development
│   │       └── Provides sample sight data for testing
│   │           - List of predefined sights
│   │           - Used for offline development/testing
│   │
│   └── remote/
│       ├── firebase_service.dart             # Firebase client wrapper
│       │   └── Initializes and configures Firebase services
│       │       - Firebase Auth setup
│       │       - Firestore setup
│       │       - Error handling wrapper
│       │
│       └── firebase_sights_datasource.dart   # Firebase sights data source
│           └── Fetches sights from Firebase Firestore
│               - getSightsFromFirestore()
│               - getSightById(id)
│               - Real-time updates support
│
├── models/
│   ├── sight_model.dart                      # Sight Data Transfer Object
│   │   └── JSON-serializable model for Sight entity
│   │       - Extends/implements Sight entity
│   │       - fromJson() and toJson() methods
│   │       - Firebase document mapping
│   │
│   └── sight_model.g.dart                    # Generated JSON serialization
│       └── Auto-generated by json_serializable
│           - JSON parsing logic
│           - Type-safe serialization
│
└── repositories/
    ├── auth_repository_impl.dart             # Authentication implementation
    │   └── Implements AuthRepository using Firebase Auth
    │       - Uses Firebase Authentication SDK
    │       - Handles auth state changes
    │       - Error mapping to domain failures
    │
    ├── sights_repository_impl.dart           # Sights repository implementation
    │   └── Implements SightsRepository
    │       - Uses FirebaseSightsDataSource for remote data
    │       - Uses MockSightsData as fallback
    │       - Caching strategy (optional)
    │
    └── favorites_repository_impl.dart        # Favorites implementation
        └── Implements FavoritesRepository
            - Uses FavoritesLocalDataSource for persistence
            - Sync with Firebase (optional)
            - Fast local access
```

**Key Principles:**
- **Models**: Data Transfer Objects (DTOs) with JSON serialization
- **DataSources**: Handle local/remote data fetching
- **Repository Implementations**: Concrete implementations of domain contracts
- **Separation**: Local vs Remote data sources clearly separated

---

### 3. Presentation Layer (UI)

The presentation layer contains all UI-related code including widgets, screens, and state management.

```
presentation/
├── bloc/
│   ├── auth/
│   │   └── auth_bloc.dart                    # Authentication state management
│   │       └── Manages authentication state and events
│   │           - Events: SignInRequested, SignUpRequested, SignOutRequested
│   │           - States: AuthInitial, Authenticated, Unauthenticated, AuthLoading
│   │
│   ├── sights/
│   │   └── sights_bloc.dart                  # Sights state management
│   │       └── Manages sights loading and display
│   │           - Events: LoadSights, SearchSights
│   │           - States: SightsInitial, SightsLoading, SightsLoaded, SightsError
│   │
│   └── favorites/
│       └── favorites_bloc.dart               # Favorites state management
│           └── Manages user favorites
│               - Events: LoadFavorites, AddFavorite, RemoveFavorite
│               - States: FavoritesLoading, FavoritesLoaded, FavoritesError
│
├── screens/
│   ├── splash_screen.dart                    # Splash/Loading screen
│   │   └── Initial app loading screen
│   │       - App initialization
│   │       - Check authentication status
│   │       - Navigate to appropriate screen
│   │
│   ├── auth/
│   │   ├── sign_in_screen.dart               # Sign in screen
│   │   │   └── User login interface
│   │   │       - Email/password input
│   │   │       - Social sign-in buttons (optional)
│   │   │       - Navigate to sign up
│   │   │       - Forgot password link
│   │   │
│   │   ├── sign_up_screen.dart               # Sign up screen
│   │   │   └── User registration interface
│   │   │       - Email/password registration
│   │   │       - Profile setup
│   │   │       - Terms acceptance
│   │   │
│   │   ├── forgot_password_screen.dart       # Password reset request
│   │   │   └── Request password reset email
│   │   │       - Email input
│   │   │       - Send reset link
│   │   │
│   │   ├── reset_password_screen.dart        # Password reset confirmation
│   │   │   └── Confirm password reset
│   │   │       - New password input
│   │   │       - Confirm new password
│   │   │
│   │   └── email_confirmation_screen.dart    # Email verification
│   │       └── Email verification prompt
│   │           - Resend verification
│   │           - Check verification status
│   │
│   ├── home/
│   │   ├── home_screen.dart                  # Main home screen
│   │   │   └── Bottom navigation with tabs
│   │   │       - Sights tab
│   │   │       - Favorites tab
│   │   │       - Map tab (optional)
│   │   │       - Profile/Settings tab
│   │   │
│   │   ├── sights_tab.dart                   # Sights list tab
│   │   │   └── Browse all tourist sights
│   │   │       - List/Grid view of sights
│   │   │       - Search functionality
│   │   │       - Filter options
│   │   │       - Pull to refresh
│   │   │
│   │   ├── favorites_tab.dart                # Favorites list tab
│   │   │   └── User's favorite sights
│   │   │       - List of favorited sights
│   │   │       - Remove favorites
│   │   │       - Empty state message
│   │   │
│   │   ├── sight_details_screen.dart         # Sight detail view
│   │   │   └── Detailed information about a sight
│   │   │       - Image gallery
│   │   │       - Description
│   │   │       - Location on map
│   │   │       - Reviews/ratings
│   │   │       - Favorite toggle button
│   │   │
│   │   ├── map_screen.dart                   # Map view of sights
│   │   │   └── Interactive map showing sights
│   │   │       - Map with sight markers
│   │   │       - Tap marker to view details
│   │   │       - Current location
│   │   │
│   │   ├── Profile_screen.dart               # User profile screen
│   │   │   └── User profile and account management
│   │   │       - Profile picture
│   │   │       - User information
│   │   │       - Edit profile
│   │   │       - Sign out
│   │   │
│   │   └── settings_tab.dart                 # Settings screen
│   │       └── App settings and preferences
│   │           - Notification settings
│   │           - Language selection
│   │           - Privacy settings
│   │           - About app
│   │
│   └── messages/
│       ├── messages_screen.dart              # Messages list
│       │   └── User messages/conversations
│       │       - List of conversations
│       │       - Unread message badges
│       │       - Search conversations
│       │
│       └── chat_screen.dart                  # Chat conversation
│           └── Individual chat interface
│               - Message history
│               - Send messages
│               - Image sharing
│
└── widgets/
    ├── sight_card.dart                       # Sight card widget
    │   └── Reusable sight display card
    │       - Sight image
    │       - Name and rating
    │       - Favorite button
    │       - Tap to view details
    │
    ├── loading_widget.dart                   # Loading indicator
    │   └── Reusable loading spinner
    │       - Consistent loading UI
    │       - Custom styling
    │
    └── custom_loading.dart                   # Custom loading animation
        └── Animated loading indicator
            - Lottie animation (optional)
            - Branded loading experience
```

**Key Principles:**
- **BLoC Pattern**: Business Logic Component for state management
- **Screens**: Full-screen views organized by feature
- **Widgets**: Reusable UI components
- **Navigation**: Clear navigation hierarchy

---

## 🔄 Data Flow

### Request Flow (User Action → Data)
```
User Interaction (Screen/Widget)
    ↓
BLoC Event Dispatch
    ↓
BLoC processes event → calls UseCase
    ↓
UseCase executes business logic
    ↓
UseCase calls Repository Interface (Domain)
    ↓
Repository Implementation (Data) called
    ↓
DataSource fetches data
    ↓
External Source (Firebase, Local Storage)
```

### Response Flow (Data → UI Update)
```
External Source returns data
    ↓
DataSource processes raw data
    ↓
Repository maps data to Domain Entity
    ↓
UseCase returns result to BLoC
    ↓
BLoC emits new State
    ↓
UI Widget rebuilds with new state
    ↓
User sees updated interface
```

### Example: Viewing Sight Details
```
1. User taps sight card → SightDetailsScreen
2. Screen dispatches event → SightsBloc
3. BLoC calls GetSightByIdUseCase
4. UseCase calls SightsRepository.getSightById()
5. Repository calls FirebaseSightsDataSource
6. DataSource queries Firestore
7. Data returns as SightModel
8. Mapped to Sight entity
9. BLoC emits SightsLoaded state
10. UI rebuilds with sight details
```

---

##  Key Design Patterns

### 1. Clean Architecture
- **Separation of Concerns**: Three distinct layers
- **Dependency Rule**: Inner layers don't depend on outer layers
- **Testability**: Business logic independent of frameworks
- **Flexibility**: Easy to swap implementations

### 2. Repository Pattern
- **Abstraction**: Domain defines contracts, Data implements
- **Single Source of Truth**: Centralized data access
- **Flexibility**: Easy to switch data sources (Firebase ↔ Local)
- **Caching**: Can add caching layer transparently

### 3. BLoC Pattern
- **State Management**: Predictable state changes
- **Separation**: Business logic separate from UI
- **Testability**: BLoCs can be tested independently
- **Reactive**: Stream-based architecture

### 4. Dependency Injection
- **Container**: `injection_container.dart`
- **Registration**: All dependencies registered at startup
- **Inversion of Control**: Dependencies injected, not created
- **Testability**: Easy to mock dependencies

### 5. UseCase Pattern
- **Single Responsibility**: One use case per operation
- **Reusability**: UseCases can be composed
- **Clarity**: Clear intent of business operations
- **Testability**: Isolated business logic

---

##  Technology Stack

### State Management
- **flutter_bloc**: BLoC pattern implementation
- **equatable**: Value equality for states/events

### Backend & Data
- **Firebase Core**: Firebase SDK initialization
- **Firebase Auth**: User authentication
- **Cloud Firestore**: NoSQL database for sights
- **Hive / SharedPreferences**: Local favorites storage

### Serialization
- **json_serializable**: JSON serialization
- **json_annotation**: JSON annotations
- **build_runner**: Code generation

### UI Components
- **Material Design 3**: Modern UI components
- **Google Maps Flutter**: Map integration (if used)
- **cached_network_image**: Image caching

### Utilities
- **get_it**: Dependency injection container
- **dartz**: Functional programming (Either, Option)
- **intl**: Internationalization
- **lottie**: Animations (custom_loading.dart)

---

##  Module Organization

### Authentication Module
```
Domain:
├── entities/user.dart
├── repositories/auth_repository.dart
└── usecases/auth/
    ├── sign_in_usecase.dart
    ├── sign_up_usecase.dart
    ├── sign_out_usecase.dart
    └── get_current_user_usecase.dart

Data:
└── repositories/auth_repository_impl.dart

Presentation:
├── bloc/auth/auth_bloc.dart
└── screens/auth/
    ├── sign_in_screen.dart
    ├── sign_up_screen.dart
    ├── forgot_password_screen.dart
    ├── reset_password_screen.dart
    └── email_confirmation_screen.dart
```

### Sights Module
```
Domain:
├── entities/sight.dart
├── repositories/sights_repository.dart
└── usecases/sights/
    └── get_sights_usecase.dart

Data:
├── models/
│   ├── sight_model.dart
│   └── sight_model.g.dart
├── datasources/
│   ├── remote/firebase_sights_datasource.dart
│   └── local/mock_sights_data.dart
└── repositories/sights_repository_impl.dart

Presentation:
├── bloc/sights/sights_bloc.dart
├── screens/home/
│   ├── sights_tab.dart
│   ├── sight_details_screen.dart
│   └── map_screen.dart
└── widgets/sight_card.dart
```

### Favorites Module
```
Domain:
├── repositories/favorites_repository.dart
└── usecases/favorites/
    ├── get_favorites_usecase.dart
    ├── add_favorite_usecase.dart
    ├── remove_favorite_usecase.dart
    └── is_favorite_usecase.dart

Data:
├── datasources/local/favorites_local_datasource.dart
└── repositories/favorites_repository_impl.dart

Presentation:
├── bloc/favorites/favorites_bloc.dart
└── screens/home/favorites_tab.dart
```

---

##  Security Considerations

### Authentication
- Firebase Authentication for secure user management
- Password strength validation
- Email verification required
- Secure token storage

### Data Access
- Firestore security rules enforce access control
- User can only access own favorites
- Read-only access to public sights data

### Local Storage
- Favorites stored securely in Hive (encrypted)
- No sensitive data in plain text

---

##  Testing Strategy

### Unit Tests
- **Domain Layer**: 
  - Test entities
  - Test use cases with mocked repositories
- **Data Layer**:
  - Test repository implementations with mocked data sources
  - Test models serialization/deserialization

### Widget Tests
- Test individual widgets (sight_card, loading_widget)
- Test widget interactions
- Test form validation

### BLoC Tests
- Test each BLoC's state transitions
- Test event handling
- Mock use cases for isolation

### Integration Tests
- Test complete user flows (sign up → browse → favorite)
- Test Firebase integration
- Test navigation flows

---

##  Scalability Considerations

### Modular Architecture
- Easy to add new features (e.g., reviews, bookings)
- Clear boundaries between modules
- Feature modules can be developed independently

### Data Layer
- Easy to add caching layer
- Can switch to different backend (REST API, GraphQL)
- Pagination support can be added

### State Management
- BLoC scales well for complex state
- Can add new BLoCs without affecting existing ones

---

## 🔮 Future Improvements

### Recommended Enhancements

1. **Feature-First Organization**
   ```
   lib/features/
   ├── authentication/
   ├── sights/
   ├── favorites/
   ├── messaging/
   └── profile/
   ```

2. **Add Use Cases for All Operations**
   - Add SearchSightsUseCase
   - Add GetSightByIdUseCase
   - Add UpdateProfileUseCase

3. **Implement Freezed for Immutable State**
   - Reduce boilerplate in BLoC states
   - Type-safe unions for states
   - Better state management

4. **Add Offline Support**
   - Cache sights locally
   - Queue favorite actions when offline
   - Sync when online

5. **Add Error Handling Layer**
   - Create Failure classes in domain/error
   - Use Either<Failure, Success> pattern
   - Consistent error handling

6. **Implement Repository Streams**
   - Real-time favorites updates
   - Real-time sight updates from Firestore
   - Better reactive programming

7. **Add Analytics & Monitoring**
   - Firebase Analytics
   - Crash reporting
   - Performance monitoring

---

##  App Flow

### Initial Flow
```
App Start
    ↓
SplashScreen
    ↓
Check Auth Status
    ↓
├─ Authenticated → HomeScreen
└─ Not Authenticated → SignInScreen
```

### Main User Flow
```
HomeScreen (Bottom Navigation)
    ├─ Sights Tab
    │   ├─ Browse sights
    │   ├─ Search sights
    │   └─ Tap sight → SightDetailsScreen
    │       ├─ View details
    │       ├─ Add/remove favorite
    │       └─ View on map
    │
    ├─ Favorites Tab
    │   ├─ View favorite sights
    │   └─ Tap sight → SightDetailsScreen
    │
    ├─ Map Screen (Optional)
    │   ├─ View sights on map
    │   └─ Tap marker → SightDetailsScreen
    │
    └─ Profile/Settings
        ├─ View profile
        ├─ Edit settings
        └─ Sign out
```

---

##  Dependencies

### Core
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_bloc: ^8.0.0
  equatable: ^2.0.0
  
  # Dependency Injection
  get_it: ^7.0.0
  
  # Firebase
  firebase_core: ^2.0.0
  firebase_auth: ^4.0.0
  cloud_firestore: ^4.0.0
  
  # Local Storage
  hive: ^2.0.0
  hive_flutter: ^1.0.0
  
  # Serialization
  json_annotation: ^4.0.0
  
  # Utilities
  dartz: ^0.10.0
  intl: ^0.18.0
  
dev_dependencies:
  # Code Generation
  build_runner: ^2.0.0
  json_serializable: ^6.0.0
  
  # Testing
  mockito: ^5.0.0
  bloc_test: ^9.0.0
```

---

##  Architecture Benefits

### Maintainability
-  Clear separation of concerns
-  Easy to locate and fix bugs
-  Well-organized code structure

### Testability
-  Domain logic is pure Dart (no Flutter dependencies)
-  Easy to mock repositories and data sources
-  BLoCs can be tested independently

### Scalability
-  Easy to add new features
-  Modular architecture supports team development
-  Can swap implementations without affecting business logic

### Flexibility
-  Easy to switch backend (Firebase → REST API)
-  Can add new data sources (GraphQL, etc.)
-  UI can be completely redesigned without changing business logic

---

**Last Updated:** 2025  
**Architecture Version:** 1.0  
**App Type:** Tourist Sights Discovery App  
**Status:** Production Ready
