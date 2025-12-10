import java.time.LocalDateTime;

/**
 * User Model - Uses Builder Pattern
 */
public class User {
    private String userId;
    private String username;
    private String email;
    private UserType userType;
    private SubscriptionPackage subscriptionPackage;
    private LocalDateTime registrationDate;
    private AuthProvider authProvider;
    
    private User(UserBuilder builder) {
        this.userId = builder.userId;
        this.username = builder.username;
        this.email = builder.email;
        this.userType = builder.userType;
        this.subscriptionPackage = builder.subscriptionPackage;
        this.registrationDate = builder.registrationDate;
        this.authProvider = builder.authProvider;
    }
    
    // Getters
    public String getUserId() { return userId; }
    public String getUsername() { return username; }
    public String getEmail() { return email; }
    public UserType getUserType() { return userType; }
    public SubscriptionPackage getSubscriptionPackage() { return subscriptionPackage; }
    public LocalDateTime getRegistrationDate() { return registrationDate; }
    public AuthProvider getAuthProvider() { return authProvider; }
    
    public void setSubscriptionPackage(SubscriptionPackage subscriptionPackage) {
        this.subscriptionPackage = subscriptionPackage;
    }
    
    // Builder Pattern
    public static class UserBuilder {
        private String userId;
        private String username;
        private String email;
        private UserType userType = UserType.REGISTERED;
        private SubscriptionPackage subscriptionPackage = SubscriptionPackage.FREE;
        private LocalDateTime registrationDate = LocalDateTime.now();
        private AuthProvider authProvider = AuthProvider.LOCAL;
        
        public UserBuilder userId(String userId) {
            this.userId = userId;
            return this;
        }
        
        public UserBuilder username(String username) {
            this.username = username;
            return this;
        }
        
        public UserBuilder email(String email) {
            this.email = email;
            return this;
        }
        
        public UserBuilder userType(UserType userType) {
            this.userType = userType;
            return this;
        }
        
        public UserBuilder subscriptionPackage(SubscriptionPackage pkg) {
            this.subscriptionPackage = pkg;
            return this;
        }
        
        public UserBuilder authProvider(AuthProvider provider) {
            this.authProvider = provider;
            return this;
        }
        
        public User build() {
            return new User(this);
        }
    }
}

enum UserType {
    ANONYMOUS, REGISTERED, ADMINISTRATOR
}

enum AuthProvider {
    LOCAL, GOOGLE, GITHUB
}

enum SubscriptionPackage {
    FREE(5 * 1024 * 1024, 10, 50),      // 5MB per upload, 10 uploads/day, 50 total photos
    PRO(20 * 1024 * 1024, 50, 500),     // 20MB per upload, 50 uploads/day, 500 total photos
    GOLD(100 * 1024 * 1024, -1, -1);    // 100MB per upload, unlimited uploads and photos
    
    private final long maxUploadSize;
    private final int dailyUploadLimit;
    private final int maxTotalPhotos;
    
    SubscriptionPackage(long maxUploadSize, int dailyUploadLimit, int maxTotalPhotos) {
        this.maxUploadSize = maxUploadSize;
        this.dailyUploadLimit = dailyUploadLimit;
        this.maxTotalPhotos = maxTotalPhotos;
    }
    
    public long getMaxUploadSize() { return maxUploadSize; }
    public int getDailyUploadLimit() { return dailyUploadLimit; }
    public int getMaxTotalPhotos() { return maxTotalPhotos; }
}
