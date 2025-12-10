import java.time.LocalDateTime;
import java.util.*;
import java.io.File;
import java.awt.image.BufferedImage;

/**
 * Command Pattern - Encapsulates user actions
 */
interface Command {
    void execute();
    void undo();
}

class UploadPhotoCommand implements Command {
    private PhotoManagementFacade facade;
    private User user;
    private File file;
    private String description;
    private List<String> hashtags;
    private ImageProcessor processor;
    private Photo uploadedPhoto;
    
    public UploadPhotoCommand(PhotoManagementFacade facade, User user, File file, 
                             String description, List<String> hashtags, ImageProcessor processor) {
        this.facade = facade;
        this.user = user;
        this.file = file;
        this.description = description;
        this.hashtags = hashtags;
        this.processor = processor;
    }
    
    @Override
    public void execute() {
        uploadedPhoto = facade.uploadPhoto(user, file, description, hashtags, processor);
    }
    
    @Override
    public void undo() {
        if (uploadedPhoto != null) {
            facade.deletePhoto(user, uploadedPhoto.getPhotoId());
        }
    }
}

class UpdatePhotoCommand implements Command {
    private PhotoManagementFacade facade;
    private User user;
    private String photoId;
    private String newDescription;
    private List<String> newHashtags;
    private String oldDescription;
    private List<String> oldHashtags;
    
    public UpdatePhotoCommand(PhotoManagementFacade facade, User user, String photoId,
                             String newDescription, List<String> newHashtags) {
        this.facade = facade;
        this.user = user;
        this.photoId = photoId;
        this.newDescription = newDescription;
        this.newHashtags = newHashtags;
    }
    
    @Override
    public void execute() {
        Photo photo = PhotoRepository.getInstance().findById(photoId);
        if (photo != null) {
            oldDescription = photo.getDescription();
            oldHashtags = new ArrayList<>(photo.getHashtags());
        }
        facade.updatePhoto(user, photoId, newDescription, newHashtags);
    }
    
    @Override
    public void undo() {
        facade.updatePhoto(user, photoId, oldDescription, oldHashtags);
    }
}

class DeletePhotoCommand implements Command {
    private PhotoManagementFacade facade;
    private User user;
    private String photoId;
    private Photo deletedPhoto;
    
    public DeletePhotoCommand(PhotoManagementFacade facade, User user, String photoId) {
        this.facade = facade;
        this.user = user;
        this.photoId = photoId;
    }
    
    @Override
    public void execute() {
        deletedPhoto = PhotoRepository.getInstance().findById(photoId);
        facade.deletePhoto(user, photoId);
    }
    
    @Override
    public void undo() {
        // In real app, would restore the photo
        Logger.getInstance().log(user.getUserId(), "Undo delete not fully implemented");
    }
}

/**
 * Command Invoker
 */
class CommandInvoker {
    private Stack<Command> commandHistory;
    
    public CommandInvoker() {
        commandHistory = new Stack<>();
    }
    
    public void executeCommand(Command command) {
        command.execute();
        commandHistory.push(command);
    }
    
    public void undoLastCommand() {
        if (!commandHistory.isEmpty()) {
            Command command = commandHistory.pop();
            command.undo();
        }
    }
}

/**
 * Specification Pattern for Search Criteria
 */
class PhotoSearchCriteria {
    private List<String> hashtags;
    private Long minSize;
    private Long maxSize;
    private LocalDateTime startDate;
    private LocalDateTime endDate;
    private String author;
    
    public PhotoSearchCriteria() {
        hashtags = new ArrayList<>();
    }
    
    public boolean matches(Photo photo) {
        if (hashtags != null && !hashtags.isEmpty()) {
            boolean hasTag = false;
            for (String tag : hashtags) {
                if (photo.getHashtags().contains(tag)) {
                    hasTag = true;
                    break;
                }
            }
            if (!hasTag) return false;
        }
        
        if (minSize != null && photo.getFileSize() < minSize) {
            return false;
        }
        
        if (maxSize != null && photo.getFileSize() > maxSize) {
            return false;
        }
        
        if (startDate != null && photo.getUploadDateTime().isBefore(startDate)) {
            return false;
        }
        
        if (endDate != null && photo.getUploadDateTime().isAfter(endDate)) {
            return false;
        }
        
        if (author != null && !photo.getAuthorName().equalsIgnoreCase(author)) {
            return false;
        }
        
        return true;
    }
    
    // Setters
    public void setHashtags(List<String> hashtags) { this.hashtags = hashtags; }
    public void setMinSize(Long minSize) { this.minSize = minSize; }
    public void setMaxSize(Long maxSize) { this.maxSize = maxSize; }
    public void setStartDate(LocalDateTime startDate) { this.startDate = startDate; }
    public void setEndDate(LocalDateTime endDate) { this.endDate = endDate; }
    public void setAuthor(String author) { this.author = author; }
}
