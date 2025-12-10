/**
 * Factory Pattern for Authentication Providers
 */
interface AuthenticationService {
    User authenticate(String credential, String password);
    User register(String username, String email, String password, SubscriptionPackage pkg);
}

class LocalAuthService implements AuthenticationService {
    @Override
    public User authenticate(String credential, String password) {
        // Simplified authentication logic
        UserRepository repo = UserRepository.getInstance();
        return repo.findByUsernameAndPassword(credential, password);
    }
    
    @Override
    public User register(String username, String email, String password, SubscriptionPackage pkg) {
        User user = new User.UserBuilder()
            .userId(generateId())
            .username(username)
            .email(email)
            .subscriptionPackage(pkg)
            .authProvider(AuthProvider.LOCAL)
            .build();
        UserRepository.getInstance().save(user);
        return user;
    }
    
    private String generateId() {
        return "USER_" + System.currentTimeMillis();
    }
}

class GoogleAuthService implements AuthenticationService {
    @Override
    public User authenticate(String credential, String password) {
        // Simulate Google OAuth
        System.out.println("Authenticating with Google...");
        return null;
    }
    
    @Override
    public User register(String username, String email, String password, SubscriptionPackage pkg) {
        User user = new User.UserBuilder()
            .userId(generateId())
            .username(username)
            .email(email)
            .subscriptionPackage(pkg)
            .authProvider(AuthProvider.GOOGLE)
            .build();
        UserRepository.getInstance().save(user);
        return user;
    }
    
    private String generateId() {
        return "GOOGLE_" + System.currentTimeMillis();
    }
}

class GithubAuthService implements AuthenticationService {
    @Override
    public User authenticate(String credential, String password) {
        // Simulate Github OAuth
        System.out.println("Authenticating with Github...");
        return null;
    }
    
    @Override
    public User register(String username, String email, String password, SubscriptionPackage pkg) {
        User user = new User.UserBuilder()
            .userId(generateId())
            .username(username)
            .email(email)
            .subscriptionPackage(pkg)
            .authProvider(AuthProvider.GITHUB)
            .build();
        UserRepository.getInstance().save(user);
        return user;
    }
    
    private String generateId() {
        return "GITHUB_" + System.currentTimeMillis();
    }
}

// Factory Pattern
class AuthenticationFactory {
    public static AuthenticationService getAuthService(AuthProvider provider) {
        switch (provider) {
            case LOCAL:
                return new LocalAuthService();
            case GOOGLE:
                return new GoogleAuthService();
            case GITHUB:
                return new GithubAuthService();
            default:
                return new LocalAuthService();
        }
    }
}
