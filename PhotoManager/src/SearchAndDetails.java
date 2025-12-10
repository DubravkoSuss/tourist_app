import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.*;
import java.util.List;

/**
 * Search Dialog
 */
class SearchDialog extends JDialog {
    private PhotoManagementFacade facade;
    private JTextField hashtagsField;
    private JTextField authorField;
    private JTextField minSizeField;
    private JTextField maxSizeField;
    private JTextField startDateField;
    private JTextField endDateField;
    
    public SearchDialog(JFrame parent, PhotoManagementFacade facade) {
        super(parent, "Search Photos", true);
        this.facade = facade;
        
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
        
        // Hashtags
        gbc.gridx = 0; gbc.gridy = row;
        panel.add(new JLabel("Hashtags (comma-separated):"), gbc);
        gbc.gridx = 1;
        hashtagsField = new JTextField(20);
        panel.add(hashtagsField, gbc);
        
        // Author
        row++; gbc.gridx = 0; gbc.gridy = row;
        panel.add(new JLabel("Author:"), gbc);
        gbc.gridx = 1;
        authorField = new JTextField(20);
        panel.add(authorField, gbc);
        
        // Min Size
        row++; gbc.gridx = 0; gbc.gridy = row;
        panel.add(new JLabel("Min Size (bytes):"), gbc);
        gbc.gridx = 1;
        minSizeField = new JTextField(20);
        panel.add(minSizeField, gbc);
        
        // Max Size
        row++; gbc.gridx = 0; gbc.gridy = row;
        panel.add(new JLabel("Max Size (bytes):"), gbc);
        gbc.gridx = 1;
        maxSizeField = new JTextField(20);
        panel.add(maxSizeField, gbc);
        
        // Start Date
        row++; gbc.gridx = 0; gbc.gridy = row;
        panel.add(new JLabel("Start Date (YYYY-MM-DD):"), gbc);
        gbc.gridx = 1;
        startDateField = new JTextField(20);
        panel.add(startDateField, gbc);
        
        // End Date
        row++; gbc.gridx = 0; gbc.gridy = row;
        panel.add(new JLabel("End Date (YYYY-MM-DD):"), gbc);
        gbc.gridx = 1;
        endDateField = new JTextField(20);
        panel.add(endDateField, gbc);
        
        // Buttons
        row++; gbc.gridx = 0; gbc.gridy = row; gbc.gridwidth = 2;
        JPanel btnPanel = new JPanel();
        JButton searchBtn = new JButton("Search");
        JButton cancelBtn = new JButton("Cancel");
        
        searchBtn.addActionListener(e -> performSearch());
        cancelBtn.addActionListener(e -> dispose());
        
        btnPanel.add(searchBtn);
        btnPanel.add(cancelBtn);
        panel.add(btnPanel, gbc);
        
        add(panel);
    }
    
    private void performSearch() {
        PhotoSearchCriteria criteria = new PhotoSearchCriteria();
        
        // Parse hashtags
        String hashtagsText = hashtagsField.getText();
        if (!hashtagsText.isEmpty()) {
            List<String> tags = new ArrayList<>();
            for (String tag : hashtagsText.split(",")) {
                tags.add(tag.trim());
            }
            criteria.setHashtags(tags);
        }
        
        // Author
        if (!authorField.getText().isEmpty()) {
            criteria.setAuthor(authorField.getText());
        }
        
        // Size range
        try {
            if (!minSizeField.getText().isEmpty()) {
                criteria.setMinSize(Long.parseLong(minSizeField.getText()));
            }
            if (!maxSizeField.getText().isEmpty()) {
                criteria.setMaxSize(Long.parseLong(maxSizeField.getText()));
            }
        } catch (NumberFormatException e) {
            JOptionPane.showMessageDialog(this, "Invalid size format", "Error", JOptionPane.ERROR_MESSAGE);
            return;
        }
        
        // Date range
        try {
            if (!startDateField.getText().isEmpty()) {
                LocalDate date = LocalDate.parse(startDateField.getText());
                criteria.setStartDate(LocalDateTime.of(date, LocalTime.MIN));
            }
            if (!endDateField.getText().isEmpty()) {
                LocalDate date = LocalDate.parse(endDateField.getText());
                criteria.setEndDate(LocalDateTime.of(date, LocalTime.MAX));
            }
        } catch (Exception e) {
            JOptionPane.showMessageDialog(this, "Invalid date format", "Error", JOptionPane.ERROR_MESSAGE);
            return;
        }
        
        List<Photo> results = facade.searchPhotos(criteria);
        showResults(results);
    }
    
    private void showResults(List<Photo> results) {
        JDialog resultDialog = new JDialog(this, "Search Results", true);
        resultDialog.setSize(600, 400);
        resultDialog.setLocationRelativeTo(this);
        
        String[] columns = {"Filename", "Author", "Upload Date", "Size", "Hashtags"};
        Object[][] data = new Object[results.size()][5];
        
        for (int i = 0; i < results.size(); i++) {
            Photo p = results.get(i);
            data[i][0] = p.getFilename();
            data[i][1] = p.getAuthorName();
            data[i][2] = p.getUploadDateTime().toLocalDate();
            data[i][3] = formatFileSize(p.getFileSize());
            data[i][4] = String.join(", ", p.getHashtags());
        }
        
        JTable table = new JTable(data, columns);
        resultDialog.add(new JScrollPane(table));
        resultDialog.setVisible(true);
    }
    
    private String formatFileSize(long size) {
        if (size < 1024) return size + " B";
        if (size < 1024 * 1024) return (size / 1024) + " KB";
        return (size / (1024 * 1024)) + " MB";
    }
}

/**
 * Photo Details Dialog
 */
class PhotoDetailsDialog extends JDialog {
    private Photo photo;
    private User currentUser;
    private PhotoManagementFacade facade;
    
    public PhotoDetailsDialog(JFrame parent, Photo photo, User currentUser, PhotoManagementFacade facade) {
        super(parent, "Photo Details", true);
        this.photo = photo;
        this.currentUser = currentUser;
        this.facade = facade;
        
        setSize(600, 500);
        setLocationRelativeTo(parent);
        initComponents();
    }
    
    private void initComponents() {
        setLayout(new BorderLayout());
        
        // Image panel (placeholder)
        JPanel imagePanel = new JPanel();
        imagePanel.setBackground(Color.LIGHT_GRAY);
        imagePanel.setPreferredSize(new Dimension(600, 300));
        JLabel imageLabel = new JLabel("📷 Full Image: " + photo.getFilename(), SwingConstants.CENTER);
        imageLabel.setFont(new Font("Arial", Font.BOLD, 20));
        imagePanel.add(imageLabel);
        add(imagePanel, BorderLayout.CENTER);
        
        // Info panel
        JPanel infoPanel = new JPanel(new GridLayout(0, 2, 5, 5));
        infoPanel.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));
        
        infoPanel.add(new JLabel("Filename:"));
        infoPanel.add(new JLabel(photo.getFilename()));
        
        infoPanel.add(new JLabel("Author:"));
        infoPanel.add(new JLabel(photo.getAuthorName()));
        
        infoPanel.add(new JLabel("Upload Date:"));
        infoPanel.add(new JLabel(photo.getUploadDateTime().toString()));
        
        infoPanel.add(new JLabel("Size:"));
        infoPanel.add(new JLabel(formatFileSize(photo.getFileSize())));
        
        infoPanel.add(new JLabel("Description:"));
        infoPanel.add(new JLabel(photo.getDescription()));
        
        infoPanel.add(new JLabel("Hashtags:"));
        infoPanel.add(new JLabel(String.join(", ", photo.getHashtags())));
        
        add(infoPanel, BorderLayout.SOUTH);
        
        // Button panel
        JPanel buttonPanel = new JPanel();
        
        JButton downloadBtn = new JButton("Download");
        downloadBtn.addActionListener(e -> handleDownload());
        buttonPanel.add(downloadBtn);
        
        // Only allow edit if user is owner or admin
        if (canModify()) {
            JButton editBtn = new JButton("Edit");
            editBtn.addActionListener(e -> handleEdit());
            buttonPanel.add(editBtn);
            
            JButton deleteBtn = new JButton("Delete");
            deleteBtn.addActionListener(e -> handleDelete());
            buttonPanel.add(deleteBtn);
        }
        
        JButton closeBtn = new JButton("Close");
        closeBtn.addActionListener(e -> dispose());
        buttonPanel.add(closeBtn);
        
        add(buttonPanel, BorderLayout.NORTH);
    }
    
    private boolean canModify() {
        return currentUser.getUserType() == UserType.ADMINISTRATOR || 
               currentUser.getUserId().equals(photo.getAuthorId());
    }
    
    private void handleDownload() {
        JOptionPane.showMessageDialog(this, "Photo downloaded to: " + photo.getStoragePath());
        Logger.getInstance().log(currentUser.getUserId(), "Downloaded photo: " + photo.getPhotoId());
    }
    
    private void handleEdit() {
        String newDesc = JOptionPane.showInputDialog(this, "New Description:", photo.getDescription());
        String newTags = JOptionPane.showInputDialog(this, "New Hashtags (comma-separated):", 
            String.join(", ", photo.getHashtags()));
        
        if (newDesc != null && newTags != null) {
            List<String> hashtags = new ArrayList<>();
            for (String tag : newTags.split(",")) {
                hashtags.add(tag.trim());
            }
            
            facade.updatePhoto(currentUser, photo.getPhotoId(), newDesc, hashtags);
            JOptionPane.showMessageDialog(this, "Photo updated successfully!");
            dispose();
        }
    }
    
    private void handleDelete() {
        int confirm = JOptionPane.showConfirmDialog(this, 
            "Are you sure you want to delete this photo?", 
            "Confirm Delete", 
            JOptionPane.YES_NO_OPTION);
        
        if (confirm == JOptionPane.YES_OPTION) {
            facade.deletePhoto(currentUser, photo.getPhotoId());
            JOptionPane.showMessageDialog(this, "Photo deleted successfully!");
            dispose();
        }
    }
    
    private String formatFileSize(long size) {
        if (size < 1024) return size + " B";
        if (size < 1024 * 1024) return (size / 1024) + " KB";
        return (size / (1024 * 1024)) + " MB";
    }
}
