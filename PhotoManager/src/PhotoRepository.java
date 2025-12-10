import java.util.*;

/**
 * Repository Pattern with Singleton - Data Layer
 */
public class PhotoRepository {
    private static PhotoRepository instance;
    private Map<String, Photo> photos;

    private PhotoRepository() {
        photos = new HashMap<>();
    }

    public static PhotoRepository getInstance() {
        if (instance == null) {
            instance = new PhotoRepository();
        }
        return instance;
    }

    public void save(Photo photo) {
        photos.put(photo.getPhotoId(), photo);
        Logger.getInstance().log("PhotoRepository", "Photo saved: " + photo.getFilename());
    }

    public Photo findById(String photoId) {
        return photos.get(photoId);
    }

    public List<Photo> findAll() {
        return new ArrayList<>(photos.values());
    }

    public List<Photo> findByAuthor(String authorId) {
        List<Photo> result = new ArrayList<>();
        for (Photo photo : photos.values()) {
            if (photo.getAuthorId().equals(authorId)) {
                result.add(photo);
            }
        }
        return result;
    }
    
    public void delete(String photoId) {
        photos.remove(photoId);
        Logger.getInstance().log("PhotoRepository", "Photo deleted: " + photoId);
    }
}