import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Photo Model
 */
public class Photo {
    private String photoId;
    private String filename;
    private String description;
    private List<String> hashtags;
    private String authorId;
    private String authorName;
    private LocalDateTime uploadDateTime;
    private long fileSize;
    private String format;
    private int width;
    private int height;
    private String storagePath;
    private String thumbnailPath;
    
    public Photo() {
        this.hashtags = new ArrayList<>();
        this.uploadDateTime = LocalDateTime.now();
    }
    
    // Getters and Setters
    public String getPhotoId() { return photoId; }
    public void setPhotoId(String photoId) { this.photoId = photoId; }
    
    public String getFilename() { return filename; }
    public void setFilename(String filename) { this.filename = filename; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public List<String> getHashtags() { return hashtags; }
    public void setHashtags(List<String> hashtags) { this.hashtags = hashtags; }
    
    public String getAuthorId() { return authorId; }
    public void setAuthorId(String authorId) { this.authorId = authorId; }
    
    public String getAuthorName() { return authorName; }
    public void setAuthorName(String authorName) { this.authorName = authorName; }
    
    public LocalDateTime getUploadDateTime() { return uploadDateTime; }
    public void setUploadDateTime(LocalDateTime uploadDateTime) { this.uploadDateTime = uploadDateTime; }
    
    public long getFileSize() { return fileSize; }
    public void setFileSize(long fileSize) { this.fileSize = fileSize; }
    
    public String getFormat() { return format; }
    public void setFormat(String format) { this.format = format; }
    
    public int getWidth() { return width; }
    public void setWidth(int width) { this.width = width; }
    
    public int getHeight() { return height; }
    public void setHeight(int height) { this.height = height; }
    
    public String getStoragePath() { return storagePath; }
    public void setStoragePath(String storagePath) { this.storagePath = storagePath; }
    
    public String getThumbnailPath() { return thumbnailPath; }
    public void setThumbnailPath(String thumbnailPath) { this.thumbnailPath = thumbnailPath; }
}
