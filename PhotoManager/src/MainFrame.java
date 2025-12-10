import javax.swing.*;
import javax.swing.border.*;
import java.awt.*;
import java.awt.event.*;
import java.io.File;
import java.util.*;
import java.util.List;

/**
 * Main Application Frame - MVC Pattern
 */
class MainFrame extends JFrame {
    private User currentUser;
    private PhotoManagementFacade facade;
    private CommandInvoker commandInvoker;
    
    private JPanel photoGridPanel;
    private JLabel userInfoLabel;
    private JButton uploadButton;
    private JButton searchButton;
    private JButton logoutButton;
    private JButton adminPanelButton;
    
    public MainFrame(User user) {
        this.currentUser = user;
        this.facade = new PhotoManagementFacade();
        this.commandInvoker = new CommandInvoker();
        
        setTitle("Photo Manager - " + user.getUsername());
        setSize(1000, 700);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLocationRelativeTo(null);
        
        initComponents();
        loadPhotos();
    }
    
    private void initComponents() {
        setLayout(new BorderLayout());
        
        // Top Panel - User Info and Actions
        JPanel topPanel = new JPanel(new BorderLayout());
        topPanel.setBorder(new EmptyBorder(10, 10, 10, 10));
        
        userInfoLabel = new JLabel(getUserInfoText());
        userInfoLabel.setFont(new Font("Arial", Font.BOLD, 14));
        topPanel.add(userInfoLabel, BorderLayout.WEST);
        
        JPanel actionPanel = new JPanel(new FlowLayout(FlowLayout.RIGHT));
        
        if (currentUser.getUserType() != UserType.ANONYMOUS) {
            uploadButton = new JButton("Upload Photo");
            uploadButton.addActionListener(e -> handleUpload());
            actionPanel.add(uploadButton);
        }
        
        searchButton = new JButton("Search");
        searchButton.addActionListener(e -> handleSearch());
        actionPanel.add(searchButton);
        
        if (currentUser.getUserType() == UserType.ADMINISTRATOR) {
            adminPanelButton = new JButton("Admin Panel");
            adminPanelButton.addActionListener(e -> openAdminPanel());
            actionPanel.add(adminPanelButton);
        }
        
        logoutButton = new JButton("Logout");
        logoutButton.addActionListener(e -> handleLogout());
        actionPanel.add(logoutButton);
        
        topPanel.add(actionPanel, BorderLayout.EAST);
        add(topPanel, BorderLayout.NORTH);
        
        // Center - Photo Grid
        photoGridPanel = new JPanel(new GridLayout(0, 3, 10, 10));
        photoGridPanel.setBorder(new EmptyBorder(10, 10, 10, 10));
        
        JScrollPane scrollPane = new JScrollPane(photoGridPanel);
        add(scrollPane, BorderLayout.CENTER);
    }
    
    private String getUserInfoText() {
        SubscriptionPackage pkg = currentUser.getSubscriptionPackage();
        return String.format("User: %s | Type: %s | Package: %s", 
            currentUser.getUsername(), 
            currentUser.getUserType(), 
            pkg);
    }
    
    private void loadPhotos() {
        photoGridPanel.removeAll();
        
        List<Photo> photos = PhotoRepository.getInstance().findAll();
        // Sort by upload date descending
        photos.sort((p1, p2) -> p2.getUploadDateTime().compareTo(p1.getUploadDateTime()));
        
        // Display last 10 photos
        int count = 0;
        for (Photo photo : photos) {
            if (count >= 10) break;
            addPhotoThumbnail(photo);
            count++;
        }
        
        photoGridPanel.revalidate();
        photoGridPanel.repaint();
    }
    
    private void addPhotoThumbnail(Photo photo) {
        JPanel thumbnailPanel = new JPanel(new BorderLayout());
        thumbnailPanel.setBorder(BorderFactory.createLineBorder(Color.GRAY));
        thumbnailPanel.setPreferredSize(new Dimension(250, 280));
        
        // Image placeholder
        JLabel imageLabel = new JLabel("📷 " + photo.getFilename(), SwingConstants.CENTER);
        imageLabel.setPreferredSize(new Dimension(250, 200));
        imageLabel.setOpaque(true);
        imageLabel.setBackground(Color.LIGHT_GRAY);
        imageLabel.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
        imageLabel.addMouseListener(new MouseAdapter() {
            @Override
            public void mouseClicked(MouseEvent e) {
                showPhotoDetails(photo);
            }
        });
        thumbnailPanel.add(imageLabel, BorderLayout.CENTER);
        
        // Info panel
        JPanel infoPanel = new JPanel(new GridLayout(4, 1));
        infoPanel.add(new JLabel("Author: " + photo.getAuthorName()));
        infoPanel.add(new JLabel("Date: " + photo.getUploadDateTime().toLocalDate()));
        infoPanel.add(new JLabel("Tags: " + String.join(", ", photo.getHashtags())));
        infoPanel.add(new JLabel("Size: " + formatFileSize(photo.getFileSize())));
        thumbnailPanel.add(infoPanel, BorderLayout.SOUTH);
        
        photoGridPanel.add(thumbnailPanel);
    }
    
    private String formatFileSize(long size) {
        if (size < 1024) return size + " B";
        if (size < 1024 * 1024) return (size / 1024) + " KB";
        return (size / (1024 * 1024)) + " MB";
    }
    
    private void handleUpload() {
        UploadDialog dialog = new UploadDialog(this, currentUser, facade, commandInvoker);
        dialog.setVisible(true);
        loadPhotos(); // Refresh
    }
    
    private void handleSearch() {
        SearchDialog dialog = new SearchDialog(this, facade);
        dialog.setVisible(true);
    }
    
    private void showPhotoDetails(Photo photo) {
        PhotoDetailsDialog dialog = new PhotoDetailsDialog(this, photo, currentUser, facade);
        dialog.setVisible(true);
        loadPhotos(); // Refresh in case of modifications
    }
    
    private void openAdminPanel() {
        AdminPanel panel = new AdminPanel(this, currentUser);
        panel.setVisible(true);
    }
    
    private void handleLogout() {
        Logger.getInstance().log(currentUser.getUserId(), "User logged out");
        this.dispose();
        LoginFrame loginFrame = new LoginFrame();
        loginFrame.setVisible(true);
    }
}

class UploadDialog extends JDialog {
    private User user;
    private PhotoManagementFacade facade;
    private CommandInvoker invoker;
    
    private JTextField filePathField;
    private JTextArea descriptionArea;
    private JTextField hashtagsField;
    private JCheckBox resizeCheck;
    private JCheckBox sepiaCheck;
    private JCheckBox blurCheck;
    
    public UploadDialog(JFrame parent, User user, PhotoManagementFacade facade, CommandInvoker invoker) {
        super(parent, "Upload Photo", true);
        this.user = user;
        this.facade = facade;
        this.invoker = invoker;
        
        setSize(500, 400);
        setLocationRelativeTo(parent);
        initComponents();
    }
    
    private void initComponents() {
        JPanel panel = new JPanel(new GridBagLayout());
        GridBagConstraints gbc = new GridBagConstraints();
        gbc.insets = new Insets(5, 5, 5, 5);
        gbc.fill = GridBagConstraints.HORIZONTAL;
        
        int row = 0;
        
        // File selection
        gbc.gridx = 0; gbc.gridy = row;
        panel.add(new JLabel("File:"), gbc);
        gbc.gridx = 1;
        filePathField = new JTextField(20);
        panel.add(filePathField, gbc);
        gbc.gridx = 2;
        JButton browseBtn = new JButton("Browse");
        browseBtn.addActionListener(e -> browseFile());
        panel.add(browseBtn, gbc);
        
        // Description
        row++; gbc.gridx = 0; gbc.gridy = row;
        panel.add(new JLabel("Description:"), gbc);
        gbc.gridx = 1; gbc.gridwidth = 2;
        descriptionArea = new JTextArea(3, 20);
        panel.add(new JScrollPane(descriptionArea), gbc);
        
        // Hashtags
        row++; gbc.gridx = 0; gbc.gridy = row; gbc.gridwidth = 1;
        panel.add(new JLabel("Hashtags:"), gbc);
        gbc.gridx = 1; gbc.gridwidth = 2;
        hashtagsField = new JTextField();
        panel.add(hashtagsField, gbc);
        
        // Processing options
        row++; gbc.gridx = 0; gbc.gridy = row; gbc.gridwidth = 3;
        panel.add(new JLabel("Processing Options:"), gbc);
        
        row++; gbc.gridy = row;
        resizeCheck = new JCheckBox("Resize (800x600)");
        panel.add(resizeCheck, gbc);
        
        row++; gbc.gridy = row;
        sepiaCheck = new JCheckBox("Apply Sepia Filter");
        panel.add(sepiaCheck, gbc);
        
        row++; gbc.gridy = row;
        blurCheck = new JCheckBox("Apply Blur");
        panel.add(blurCheck, gbc);
        
        // Buttons
        row++; gbc.gridy = row;
        JPanel btnPanel = new JPanel();
        JButton uploadBtn = new JButton("Upload");
        JButton cancelBtn = new JButton("Cancel");
        
        uploadBtn.addActionListener(e -> handleUpload());
        cancelBtn.addActionListener(e -> dispose());
        
        btnPanel.add(uploadBtn);
        btnPanel.add(cancelBtn);
        panel.add(btnPanel, gbc);
        
        add(panel);
    }
    
    private void browseFile() {
        JFileChooser chooser = new JFileChooser();
        if (chooser.showOpenDialog(this) == JFileChooser.APPROVE_OPTION) {
            filePathField.setText(chooser.getSelectedFile().getAbsolutePath());
        }
    }
    
    private void handleUpload() {
        String filePath = filePathField.getText();
        if (filePath.isEmpty()) {
            JOptionPane.showMessageDialog(this, "Please select a file", "Error", JOptionPane.ERROR_MESSAGE);
            return;
        }
        
        File file = new File(filePath);
        String description = descriptionArea.getText();
        List<String> hashtags = parseHashtags(hashtagsField.getText());
        
        // Build processor chain using Decorator pattern
        ImageProcessor processor = new BaseImageProcessor();
        if (resizeCheck.isSelected()) {
            processor = new ResizeDecorator(processor, 800, 600);
        }
        if (sepiaCheck.isSelected()) {
            processor = new SepiaDecorator(processor);
        }
        if (blurCheck.isSelected()) {
            processor = new BlurDecorator(processor);
        }
        
        // Use Command pattern
        Command uploadCommand = new UploadPhotoCommand(facade, user, file, description, hashtags, processor);
        invoker.executeCommand(uploadCommand);
        
        JOptionPane.showMessageDialog(this, "Photo uploaded successfully!");
        dispose();
    }
    
    private List<String> parseHashtags(String text) {
        List<String> tags = new ArrayList<>();
        if (text != null && !text.isEmpty()) {
            for (String tag : text.split(",")) {
                tags.add(tag.trim());
            }
        }
        return tags;
    }
}
