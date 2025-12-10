import javax.swing.*;
import javax.swing.table.*;
import java.awt.*;
import java.util.List;

/**
 * Admin Panel - Administrator Features
 */
class AdminPanel extends JFrame {
    private User adminUser;
    private JTabbedPane tabbedPane;
    
    public AdminPanel(JFrame parent, User adminUser) {
        this.adminUser = adminUser;
        
        setTitle("Admin Panel");
        setSize(800, 600);
        setLocationRelativeTo(parent);
        
        initComponents();
    }
    
    private void initComponents() {
        tabbedPane = new JTabbedPane();
        
        // User Management Tab
        tabbedPane.addTab("Users", createUserManagementPanel());
        
        // Photo Management Tab
        tabbedPane.addTab("Photos", createPhotoManagementPanel());
        
        // Logs Tab
        tabbedPane.addTab("System Logs", createLogsPanel());
        
        // Statistics Tab
        tabbedPane.addTab("Statistics", createStatisticsPanel());
        
        add(tabbedPane);
    }
    
    private JPanel createUserManagementPanel() {
        JPanel panel = new JPanel(new BorderLayout());
        
        String[] columns = {"User ID", "Username", "Email", "Type", "Package", "Registration Date"};
        List<User> users = UserRepository.getInstance().findAll();
        Object[][] data = new Object[users.size()][6];
        
        for (int i = 0; i < users.size(); i++) {
            User u = users.get(i);
            data[i][0] = u.getUserId();
            data[i][1] = u.getUsername();
            data[i][2] = u.getEmail();
            data[i][3] = u.getUserType();
            data[i][4] = u.getSubscriptionPackage();
            data[i][5] = u.getRegistrationDate() != null ? u.getRegistrationDate().toLocalDate() : "N/A";
        }
        
        JTable table = new JTable(data, columns);
        JScrollPane scrollPane = new JScrollPane(table);
        panel.add(scrollPane, BorderLayout.CENTER);
        
        // Buttons
        JPanel buttonPanel = new JPanel();
        JButton viewUserBtn = new JButton("View User Details");
        JButton changePackageBtn = new JButton("Change Package");
        
        viewUserBtn.addActionListener(e -> {
            int row = table.getSelectedRow();
            if (row >= 0) {
                String userId = (String) table.getValueAt(row, 0);
                showUserDetails(userId);
            }
        });
        
        changePackageBtn.addActionListener(e -> {
            int row = table.getSelectedRow();
            if (row >= 0) {
                String userId = (String) table.getValueAt(row, 0);
                changeUserPackage(userId);
            }
        });
        
        buttonPanel.add(viewUserBtn);
        buttonPanel.add(changePackageBtn);
        panel.add(buttonPanel, BorderLayout.SOUTH);
        
        return panel;
    }
    
    private JPanel createPhotoManagementPanel() {
        JPanel panel = new JPanel(new BorderLayout());
        
        String[] columns = {"Photo ID", "Filename", "Author", "Upload Date", "Size"};
        List<Photo> photos = PhotoRepository.getInstance().findAll();
        Object[][] data = new Object[photos.size()][5];
        
        for (int i = 0; i < photos.size(); i++) {
            Photo p = photos.get(i);
            data[i][0] = p.getPhotoId();
            data[i][1] = p.getFilename();
            data[i][2] = p.getAuthorName();
            data[i][3] = p.getUploadDateTime().toLocalDate();
            data[i][4] = formatFileSize(p.getFileSize());
        }
        
        JTable table = new JTable(data, columns);
        JScrollPane scrollPane = new JScrollPane(table);
        panel.add(scrollPane, BorderLayout.CENTER);
        
        // Buttons
        JPanel buttonPanel = new JPanel();
        JButton deletePhotoBtn = new JButton("Delete Photo");
        
        deletePhotoBtn.addActionListener(e -> {
            int row = table.getSelectedRow();
            if (row >= 0) {
                String photoId = (String) table.getValueAt(row, 0);
                deletePhoto(photoId);
            }
        });
        
        buttonPanel.add(deletePhotoBtn);
        panel.add(buttonPanel, BorderLayout.SOUTH);
        
        return panel;
    }
    
    private JPanel createLogsPanel() {
        JPanel panel = new JPanel(new BorderLayout());
        
        JTextArea logsArea = new JTextArea();
        logsArea.setEditable(false);
        logsArea.setFont(new Font("Monospaced", Font.PLAIN, 12));
        
        List<String> logs = Logger.getInstance().getLogs();
        for (String log : logs) {
            logsArea.append(log + "\n");
        }
        
        JScrollPane scrollPane = new JScrollPane(logsArea);
        panel.add(scrollPane, BorderLayout.CENTER);
        
        // Refresh button
        JPanel buttonPanel = new JPanel();
        JButton refreshBtn = new JButton("Refresh");
        refreshBtn.addActionListener(e -> {
            logsArea.setText("");
            List<String> newLogs = Logger.getInstance().getLogs();
            for (String log : newLogs) {
                logsArea.append(log + "\n");
            }
        });
        buttonPanel.add(refreshBtn);
        panel.add(buttonPanel, BorderLayout.SOUTH);
        
        return panel;
    }
    
    private JPanel createStatisticsPanel() {
        JPanel panel = new JPanel(new GridLayout(0, 2, 10, 10));
        panel.setBorder(BorderFactory.createEmptyBorder(20, 20, 20, 20));
        
        List<User> users = UserRepository.getInstance().findAll();
        List<Photo> photos = PhotoRepository.getInstance().findAll();
        
        // Total statistics
        panel.add(new JLabel("Total Users:"));
        panel.add(new JLabel(String.valueOf(users.size())));
        
        panel.add(new JLabel("Total Photos:"));
        panel.add(new JLabel(String.valueOf(photos.size())));
        
        // User type breakdown
        long admins = users.stream().filter(u -> u.getUserType() == UserType.ADMINISTRATOR).count();
        long registered = users.stream().filter(u -> u.getUserType() == UserType.REGISTERED).count();
        
        panel.add(new JLabel("Administrators:"));
        panel.add(new JLabel(String.valueOf(admins)));
        
        panel.add(new JLabel("Registered Users:"));
        panel.add(new JLabel(String.valueOf(registered)));
        
        // Package breakdown
        long freeUsers = users.stream().filter(u -> u.getSubscriptionPackage() == SubscriptionPackage.FREE).count();
        long proUsers = users.stream().filter(u -> u.getSubscriptionPackage() == SubscriptionPackage.PRO).count();
        long goldUsers = users.stream().filter(u -> u.getSubscriptionPackage() == SubscriptionPackage.GOLD).count();
        
        panel.add(new JLabel("FREE Package Users:"));
        panel.add(new JLabel(String.valueOf(freeUsers)));
        
        panel.add(new JLabel("PRO Package Users:"));
        panel.add(new JLabel(String.valueOf(proUsers)));
        
        panel.add(new JLabel("GOLD Package Users:"));
        panel.add(new JLabel(String.valueOf(goldUsers)));
        
        // Total storage
        long totalStorage = photos.stream().mapToLong(Photo::getFileSize).sum();
        panel.add(new JLabel("Total Storage Used:"));
        panel.add(new JLabel(formatFileSize(totalStorage)));
        
        return panel;
    }
    
    private void showUserDetails(String userId) {
        User user = UserRepository.getInstance().findById(userId);
        if (user != null) {
            List<Photo> userPhotos = PhotoRepository.getInstance().findByAuthor(userId);
            List<String> userLogs = Logger.getInstance().getLogsByUser(userId);
            
            String info = String.format(
                "User: %s\nEmail: %s\nType: %s\nPackage: %s\nTotal Photos: %d\nTotal Actions: %d",
                user.getUsername(), user.getEmail(), user.getUserType(), 
                user.getSubscriptionPackage(), userPhotos.size(), userLogs.size()
            );
            
            JOptionPane.showMessageDialog(this, info, "User Details", JOptionPane.INFORMATION_MESSAGE);
        }
    }
    
    private void changeUserPackage(String userId) {
        User user = UserRepository.getInstance().findById(userId);
        if (user != null) {
            SubscriptionPackage newPackage = (SubscriptionPackage) JOptionPane.showInputDialog(
                this,
                "Select new package for " + user.getUsername(),
                "Change Package",
                JOptionPane.QUESTION_MESSAGE,
                null,
                SubscriptionPackage.values(),
                user.getSubscriptionPackage()
            );
            
            if (newPackage != null) {
                user.setSubscriptionPackage(newPackage);
                UserRepository.getInstance().save(user);
                Logger.getInstance().log(adminUser.getUserId(), 
                    "Changed package for user " + userId + " to " + newPackage);
                JOptionPane.showMessageDialog(this, "Package changed successfully!");
            }
        }
    }
    
    private void deletePhoto(String photoId) {
        int confirm = JOptionPane.showConfirmDialog(this, 
            "Are you sure you want to delete this photo?", 
            "Confirm Delete", 
            JOptionPane.YES_NO_OPTION);
        
        if (confirm == JOptionPane.YES_OPTION) {
            PhotoManagementFacade facade = new PhotoManagementFacade();
            facade.deletePhoto(adminUser, photoId);
            JOptionPane.showMessageDialog(this, "Photo deleted successfully!");
            // Refresh the panel
            tabbedPane.setComponentAt(1, createPhotoManagementPanel());
        }
    }
    
    private String formatFileSize(long size) {
        if (size < 1024) return size + " B";
        if (size < 1024 * 1024) return (size / 1024) + " KB";
        return (size / (1024 * 1024)) + " MB";
    }
}
