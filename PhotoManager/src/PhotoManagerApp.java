import javax.swing.*;

/**
 * Main Application Entry Point
 * Uses Singleton pattern for application instance
 */
public class PhotoManagerApp {
    private static PhotoManagerApp instance;
    
    private PhotoManagerApp() {
        // Private constructor for Singleton
    }
    
    public static PhotoManagerApp getInstance() {
        if (instance == null) {
            instance = new PhotoManagerApp();
        }
        return instance;
    }
    
    public void start() {
        SwingUtilities.invokeLater(() -> {
            LoginFrame loginFrame = new LoginFrame();
            loginFrame.setVisible(true);
        });
    }
    
    public static void main(String[] args) {
        PhotoManagerApp.getInstance().start();
    }
}
