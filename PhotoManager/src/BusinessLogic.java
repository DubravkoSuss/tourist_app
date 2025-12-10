import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.io.File;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;

/**
 * Observer Pattern for Logging - Singleton Logger
 */
class Logger {
    private static Logger instance;
    private List<String> logs;

    private Logger() {
        logs = new ArrayList<>();
    }

    public static Logger getInstance() {
        if (instance == null) {
            instance = new Logger();
        }
        return instance;
    }

    public void log(String actor, String action) {
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME);
        String logEntry = String.format("[%s] %s: %s", timestamp, actor, action);
        logs.add(logEntry);
        System.out.println(logEntry);
    }

    public List<String> getLogs() {
        return new ArrayList<>(logs);
    }

    public List<String> getLogsByUser(String userId) {
        List<String> userLogs = new ArrayList<>();
        for (String log : logs) {
            if (log.contains(userId)) {
                userLogs.add(log);
            }
        }
        return userLogs;
    }
}

/**
 * Facade Pattern - Simplifies complex business logic
 */
class PhotoManagementFacade {
    private PhotoRepository photoRepo;
    private UserRepository userRepo;
    private StorageStrategy storageStrategy;

    public PhotoManagementFacade() {
        this.photoRepo = PhotoRepository.getInstance();
        this.userRepo = UserRepository.getInstance();
        // Default to local storage
        this.storageStrategy = new LocalStorageStrategy();
    }

    public void setStorageStrategy(StorageStrategy strategy) {
        this.storageStrategy = strategy;
    }

    public Photo uploadPhoto(User user, File file, String description, List<String> hashtags,
                             ImageProcessor processor) {
        // Check subscription limits
        if (!checkUploadLimits(user, file)) {
            Logger.getInstance().log(user.getUserId(), "Upload failed: Limit exceeded");
            return null;
        }

        try {
            // Process image
            BufferedImage image = ImageIO.read(file);
            BufferedImage processed = processor.process(image);

            // Upload to storage
            String storagePath = storageStrategy.upload(file, user.getUserId());

            // Create photo entity
            Photo photo = new Photo();
            photo.setPhotoId("PHOTO_" + System.currentTimeMillis());
            photo.setFilename(file.getName());
            photo.setDescription(description);
            photo.setHashtags(hashtags);
            photo.setAuthorId(user.getUserId());
            photo.setAuthorName(user.getUsername());
            photo.setFileSize(file.length());
            photo.setStoragePath(storagePath);

            // Save to repository
            photoRepo.save(photo);

            Logger.getInstance().log(user.getUserId(), "Photo uploaded: " + photo.getFilename());
            return photo;
        } catch (Exception e) {
            Logger.getInstance().log(user.getUserId(), "Upload failed: " + e.getMessage());
            return null;
        }
    }

    public List<Photo> searchPhotos(PhotoSearchCriteria criteria) {
        List<Photo> allPhotos = photoRepo.findAll();
        List<Photo> filtered = new ArrayList<>();

        for (Photo photo : allPhotos) {
            if (criteria.matches(photo)) {
                filtered.add(photo);
            }
        }

        Logger.getInstance().log("System", "Photo search performed");
        return filtered;
    }

    public void updatePhoto(User user, String photoId, String newDescription, List<String> newHashtags) {
        Photo photo = photoRepo.findById(photoId);
        if (photo != null && canModify(user, photo)) {
            photo.setDescription(newDescription);
            photo.setHashtags(newHashtags);
            photoRepo.save(photo);
            Logger.getInstance().log(user.getUserId(), "Photo updated: " + photoId);
        }
    }

    public void deletePhoto(User user, String photoId) {
        Photo photo = photoRepo.findById(photoId);
        if (photo != null && canModify(user, photo)) {
            storageStrategy.delete(photo.getStoragePath());
            photoRepo.delete(photoId);
            Logger.getInstance().log(user.getUserId(), "Photo deleted: " + photoId);
        }
    }

    private boolean checkUploadLimits(User user, File file) {
        SubscriptionPackage pkg = user.getSubscriptionPackage();

        // Check file size
        if (file.length() > pkg.getMaxUploadSize()) {
            return false;
        }

        // Check total photos limit
        List<Photo> userPhotos = photoRepo.findByAuthor(user.getUserId());
        if (pkg.getMaxTotalPhotos() != -1 && userPhotos.size() >= pkg.getMaxTotalPhotos()) {
            return false;
        }

        return true;
    }

    private boolean canModify(User user, Photo photo) {
        return user.getUserType() == UserType.ADMINISTRATOR ||
                user.getUserId().equals(photo.getAuthorId());
    }
}