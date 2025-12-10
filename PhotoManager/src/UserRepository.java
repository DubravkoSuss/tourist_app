import java.util.*;

/**
 * Repository Pattern with Singleton - Data Layer
 */
public class UserRepository {
    private static UserRepository instance;
    private Map<String, User> users;

    private UserRepository() {
        users = new HashMap<>();
        // Add default admin
        User admin = new User.UserBuilder()
                .userId("ADMIN_001")
                .username("admin")
                .email("admin@photomanager.com")
                .userType(UserType.ADMINISTRATOR)
                .subscriptionPackage(SubscriptionPackage.GOLD)
                .build();
        users.put(admin.getUserId(), admin);
    }

    public static UserRepository getInstance() {
        if (instance == null) {
            instance = new UserRepository();
        }
        return instance;
    }

    public void save(User user) {
        users.put(user.getUserId(), user);
        Logger.getInstance().log("UserRepository", "User saved: " + user.getUsername());
    }

    public User findById(String userId) {
        return users.get(userId);
    }

    public User findByUsername(String username) {
        return users.values().stream()
                .filter(u -> u.getUsername().equals(username))
                .findFirst()
                .orElse(null);
    }

    public User findByUsernameAndPassword(String username, String password) {
        // Simplified - in real app, hash and compare passwords
        return findByUsername(username);
    }

    public List<User> findAll() {
        return new ArrayList<>(users.values());
    }
}