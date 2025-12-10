import javax.swing.*;
import java.awt.*;
import java.awt.event.*;

/**
 * MVC Pattern - Login View
 */
class LoginFrame extends JFrame {
    private JTextField usernameField;
    private JPasswordField passwordField;
    private JComboBox<AuthProvider> authProviderCombo;
    private JButton loginButton;
    private JButton registerButton;
    private JButton anonymousButton;
    
    public LoginFrame() {
        setTitle("Photo Manager - Login");
        setSize(400, 300);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLocationRelativeTo(null);
        
        initComponents();
    }
    
    private void initComponents() {
        JPanel panel = new JPanel(new GridBagLayout());
        GridBagConstraints gbc = new GridBagConstraints();
        gbc.insets = new Insets(5, 5, 5, 5);
        gbc.fill = GridBagConstraints.HORIZONTAL;
        
        // Title
        JLabel titleLabel = new JLabel("Photo Manager");
        titleLabel.setFont(new Font("Arial", Font.BOLD, 24));
        gbc.gridx = 0; gbc.gridy = 0; gbc.gridwidth = 2;
        panel.add(titleLabel, gbc);
        
        // Username
        gbc.gridwidth = 1; gbc.gridy = 1;
        panel.add(new JLabel("Username:"), gbc);
        gbc.gridx = 1;
        usernameField = new JTextField(20);
        panel.add(usernameField, gbc);
        
        // Password
        gbc.gridx = 0; gbc.gridy = 2;
        panel.add(new JLabel("Password:"), gbc);
        gbc.gridx = 1;
        passwordField = new JPasswordField(20);
        panel.add(passwordField, gbc);
        
        // Auth Provider
        gbc.gridx = 0; gbc.gridy = 3;
        panel.add(new JLabel("Login with:"), gbc);
        gbc.gridx = 1;
        authProviderCombo = new JComboBox<>(AuthProvider.values());
        panel.add(authProviderCombo, gbc);
        
        // Buttons
        JPanel buttonPanel = new JPanel(new FlowLayout());
        loginButton = new JButton("Login");
        registerButton = new JButton("Register");
        anonymousButton = new JButton("Continue as Guest");
        
        loginButton.addActionListener(e -> handleLogin());
        registerButton.addActionListener(e -> handleRegister());
        anonymousButton.addActionListener(e -> handleAnonymous());
        
        buttonPanel.add(loginButton);
        buttonPanel.add(registerButton);
        buttonPanel.add(anonymousButton);
        
        gbc.gridx = 0; gbc.gridy = 4; gbc.gridwidth = 2;
        panel.add(buttonPanel, gbc);
        
        add(panel);
    }
    
    private void handleLogin() {
        String username = usernameField.getText();
        String password = new String(passwordField.getPassword());
        AuthProvider provider = (AuthProvider) authProviderCombo.getSelectedItem();
        
        AuthenticationService authService = AuthenticationFactory.getAuthService(provider);
        User user = authService.authenticate(username, password);
        
        if (user != null) {
            Logger.getInstance().log(user.getUserId(), "User logged in");
            openMainFrame(user);
        } else {
            JOptionPane.showMessageDialog(this, "Invalid credentials", "Error", JOptionPane.ERROR_MESSAGE);
        }
    }
    
    private void handleRegister() {
        RegistrationDialog dialog = new RegistrationDialog(this);
        dialog.setVisible(true);
    }
    
    private void handleAnonymous() {
        User anonymous = new User.UserBuilder()
            .userId("ANON_" + System.currentTimeMillis())
            .username("Anonymous")
            .userType(UserType.ANONYMOUS)
            .build();
        Logger.getInstance().log(anonymous.getUserId(), "Anonymous user entered");
        openMainFrame(anonymous);
    }
    
    private void openMainFrame(User user) {
        this.dispose();
        MainFrame mainFrame = new MainFrame(user);
        mainFrame.setVisible(true);
    }
}

class RegistrationDialog extends JDialog {
    private JTextField usernameField;
    private JTextField emailField;
    private JPasswordField passwordField;
    private JComboBox<AuthProvider> authProviderCombo;
    private JComboBox<SubscriptionPackage> packageCombo;
    
    public RegistrationDialog(JFrame parent) {
        super(parent, "Register", true);
        setSize(400, 350);
        setLocationRelativeTo(parent);
        
        initComponents();
    }
    
    private void initComponents() {
        JPanel panel = new JPanel(new GridBagLayout());
        GridBagConstraints gbc = new GridBagConstraints();
        gbc.insets = new Insets(5, 5, 5, 5);
        gbc.fill = GridBagConstraints.HORIZONTAL;
        
        int row = 0;
        
        // Username
        gbc.gridx = 0; gbc.gridy = row;
        panel.add(new JLabel("Username:"), gbc);
        gbc.gridx = 1;
        usernameField = new JTextField(20);
        panel.add(usernameField, gbc);
        
        // Email
        row++; gbc.gridx = 0; gbc.gridy = row;
        panel.add(new JLabel("Email:"), gbc);
        gbc.gridx = 1;
        emailField = new JTextField(20);
        panel.add(emailField, gbc);
        
        // Password
        row++; gbc.gridx = 0; gbc.gridy = row;
        panel.add(new JLabel("Password:"), gbc);
        gbc.gridx = 1;
        passwordField = new JPasswordField(20);
        panel.add(passwordField, gbc);
        
        // Auth Provider
        row++; gbc.gridx = 0; gbc.gridy = row;
        panel.add(new JLabel("Register with:"), gbc);
        gbc.gridx = 1;
        authProviderCombo = new JComboBox<>(AuthProvider.values());
        panel.add(authProviderCombo, gbc);
        
        // Package
        row++; gbc.gridx = 0; gbc.gridy = row;
        panel.add(new JLabel("Package:"), gbc);
        gbc.gridx = 1;
        packageCombo = new JComboBox<>(SubscriptionPackage.values());
        panel.add(packageCombo, gbc);
        
        // Buttons
        row++; gbc.gridx = 0; gbc.gridy = row; gbc.gridwidth = 2;
        JPanel buttonPanel = new JPanel();
        JButton registerBtn = new JButton("Register");
        JButton cancelBtn = new JButton("Cancel");
        
        registerBtn.addActionListener(e -> handleRegister());
        cancelBtn.addActionListener(e -> dispose());
        
        buttonPanel.add(registerBtn);
        buttonPanel.add(cancelBtn);
        panel.add(buttonPanel, gbc);
        
        add(panel);
    }
    
    private void handleRegister() {
        String username = usernameField.getText();
        String email = emailField.getText();
        String password = new String(passwordField.getPassword());
        AuthProvider provider = (AuthProvider) authProviderCombo.getSelectedItem();
        SubscriptionPackage pkg = (SubscriptionPackage) packageCombo.getSelectedItem();
        
        if (username.isEmpty() || email.isEmpty() || password.isEmpty()) {
            JOptionPane.showMessageDialog(this, "Please fill all fields", "Error", JOptionPane.ERROR_MESSAGE);
            return;
        }
        
        AuthenticationService authService = AuthenticationFactory.getAuthService(provider);
        User user = authService.register(username, email, password, pkg);
        
        if (user != null) {
            JOptionPane.showMessageDialog(this, "Registration successful!", "Success", JOptionPane.INFORMATION_MESSAGE);
            dispose();
        }
    }
}
