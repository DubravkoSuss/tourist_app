# Photo Manager Application

A Java desktop application for uploading, browsing, and managing photos with user authentication, subscription packages, and comprehensive logging.

## Features

### User Management
- **User Types**: Anonymous, Registered, Administrator
- **Authentication**: Local, Google, Github (OAuth)
- **Subscription Packages**: FREE, PRO, GOLD with different limits
- User can track package consumption and change packages

### Photo Management
- Upload photos with description and hashtags
- Image processing options (resize, sepia, blur)
- Browse photos with thumbnails
- Search photos by hashtags, size, date range, and author
- Download photos (original or with filters)
- Edit photo descriptions and hashtags (registered users)
- Administrator can manage all photos and users

### System Features
- Comprehensive logging of all actions
- Configurable storage (local or cloud)
- Admin panel with statistics and user management

## Design Patterns Implementation (8 Patterns)

### 1. **Singleton Pattern** (Business Logic Layer)
- **Classes**: `PhotoManagerApp`, `UserRepository`, `PhotoRepository`, `Logger`
- **Purpose**: Ensures single instance of critical system components
- **Location**: `PhotoManagerApp.java`, `Repository.java`, `BusinessLogic.java`

### 2. **Builder Pattern** (Data Layer)
- **Class**: `User.UserBuilder`
- **Purpose**: Constructs complex User objects with flexible configuration
- **Location**: `User.java`

### 3. **Factory Pattern** (Service Layer)
- **Class**: `AuthenticationFactory`
- **Purpose**: Creates appropriate authentication service based on provider type
- **Location**: `AuthenticationFactory.java`

### 4. **Repository Pattern** (Data Layer)
- **Classes**: `UserRepository`, `PhotoRepository`
- **Purpose**: Abstracts data access and provides centralized data management
- **Location**: `Repository.java`

### 5. **Strategy Pattern** (Service Layer)
- **Interface**: `StorageStrategy`
- **Implementations**: `LocalStorageStrategy`, `CloudStorageStrategy`
- **Purpose**: Allows runtime selection of storage mechanism
- **Location**: `StorageAndProcessing.java`

### 6. **Decorator Pattern** (Business Logic Layer)
- **Interface**: `ImageProcessor`
- **Decorators**: `ResizeDecorator`, `SepiaDecorator`, `BlurDecorator`
- **Purpose**: Dynamically adds image processing features
- **Location**: `StorageAndProcessing.java`

### 7. **Facade Pattern** (Business Logic Layer)
- **Class**: `PhotoManagementFacade`
- **Purpose**: Simplifies complex photo management operations
- **Location**: `BusinessLogic.java`

### 8. **Command Pattern** (Business Logic Layer)
- **Interface**: `Command`
- **Implementations**: `UploadPhotoCommand`, `UpdatePhotoCommand`, `DeletePhotoCommand`
- **Invoker**: `CommandInvoker`
- **Purpose**: Encapsulates operations as objects, supports undo functionality
- **Location**: `CommandPattern.java`

### Additional Pattern: **Observer Pattern** (Cross-cutting)
- **Class**: `Logger`
- **Purpose**: System-wide logging and event tracking
- **Location**: `BusinessLogic.java`

### Additional Pattern: **MVC Pattern** (Presentation Layer)
- **Classes**: `LoginFrame`, `MainFrame`, `UploadDialog`, `SearchDialog`, etc.
- **Purpose**: Separates presentation, business logic, and user interaction
- **Location**: `LoginFrame.java`, `MainFrame.java`, `SearchAndDetails.java`

## Architecture Layers

### Presentation Layer
- GUI components using Java Swing
- MVC pattern implementation
- User dialogs and frames

### Business Logic Layer
- `PhotoManagementFacade`: Core business operations
- `CommandInvoker`: Action management
- Image processing chain

### Data & Service Layer
- Repositories for data access
- Authentication services
- Storage strategies
- Logging service

## Functional Requirements Coverage

✅ User registration (local, Google, Github)
✅ Subscription packages (FREE, PRO, GOLD)
✅ Package consumption tracking
✅ Photo upload with hashtags and description
✅ Image processing options
✅ Browse uploaded photos (thumbnails)
✅ Search by hashtags, size, date, author
✅ Photo download (original and filtered)
✅ Anonymous user browsing
✅ Registered user photo editing
✅ Administrator privileges
✅ User profile and package management
✅ User action logging
✅ Configurable storage (local/cloud)

## Non-functional Requirements Coverage

✅ Comprehensive logging of all actions
✅ Configurable storage strategy (local/cloud)
✅ Desktop application using Java Swing
✅ Object-oriented design
✅ 8+ design patterns implemented

## Project Structure

```
PhotoManagerApp.java        - Main entry point (Singleton)
User.java                   - User model (Builder pattern)
Photo.java                  - Photo model
AuthenticationFactory.java  - Auth services (Factory pattern)
Repository.java             - Data access (Repository, Singleton)
StorageAndProcessing.java   - Storage and image processing (Strategy, Decorator)
BusinessLogic.java          - Core logic (Facade, Observer)
CommandPattern.java         - Action commands (Command pattern)
LoginFrame.java             - Login GUI (MVC)
MainFrame.java              - Main application GUI (MVC)
SearchAndDetails.java       - Search and details dialogs
AdminPanel.java             - Administrator panel
```

## How to Run

### Prerequisites
- Java JDK 8 or higher
- Java Swing libraries (included in JDK)

### Compile
```bash
javac *.java
```

### Run
```bash
java PhotoManagerApp
```

### Default Admin Account
- Username: `admin`
- Password: (any - simplified authentication)
- Type: Administrator
- Package: GOLD

## Usage Guide

### For Anonymous Users
1. Click "Continue as Guest"
2. Browse uploaded photos
3. Search photos
4. View photo details

### For Registered Users
1. Click "Register" to create account
2. Choose authentication provider
3. Select subscription package
4. Login with credentials
5. Upload photos with processing options
6. Edit your own photos
7. Search and download photos

### For Administrators
1. Login with admin account
2. Access Admin Panel
3. Manage users and packages
4. View all photos
5. Check system logs
6. View statistics

## Design Pattern Benefits

1. **Maintainability**: Easy to modify and extend
2. **Scalability**: Can add new features without breaking existing code
3. **Testability**: Each component can be tested independently
4. **Flexibility**: Runtime configuration and strategy selection
5. **Reusability**: Common patterns can be reused
6. **Separation of Concerns**: Clear layer boundaries

## Future Enhancements

- Actual OAuth integration for Google/Github
- Real cloud storage implementation (AWS S3, Azure)
- Advanced image processing filters
- Photo sharing and social features
- RESTful API for mobile app integration
- Database persistence (currently in-memory)
- Email notifications
- Two-factor authentication
