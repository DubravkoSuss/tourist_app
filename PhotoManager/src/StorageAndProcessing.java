import java.io.*;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;

/**
 * Strategy Pattern for Storage
 */
interface StorageStrategy {
    String upload(File file, String userId);
    File download(String path);
    void delete(String path);
}

class LocalStorageStrategy implements StorageStrategy {
    private static final String STORAGE_PATH = "./photos/";
    
    @Override
    public String upload(File file, String userId) {
        try {
            File userDir = new File(STORAGE_PATH + userId);
            userDir.mkdirs();
            File destination = new File(userDir, file.getName());
            copyFile(file, destination);
            Logger.getInstance().log("LocalStorage", "File uploaded: " + destination.getPath());
            return destination.getPath();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    @Override
    public File download(String path) {
        return new File(path);
    }
    
    @Override
    public void delete(String path) {
        new File(path).delete();
        Logger.getInstance().log("LocalStorage", "File deleted: " + path);
    }
    
    private void copyFile(File source, File dest) throws IOException {
        try (InputStream in = new FileInputStream(source);
             OutputStream out = new FileOutputStream(dest)) {
            byte[] buffer = new byte[1024];
            int length;
            while ((length = in.read(buffer)) > 0) {
                out.write(buffer, 0, length);
            }
        }
    }
}

class CloudStorageStrategy implements StorageStrategy {
    @Override
    public String upload(File file, String userId) {
        // Simulate cloud upload (e.g., AWS S3)
        String cloudPath = "s3://bucket/" + userId + "/" + file.getName();
        Logger.getInstance().log("CloudStorage", "File uploaded to cloud: " + cloudPath);
        return cloudPath;
    }
    
    @Override
    public File download(String path) {
        // Simulate cloud download
        System.out.println("Downloading from cloud: " + path);
        return null;
    }
    
    @Override
    public void delete(String path) {
        Logger.getInstance().log("CloudStorage", "File deleted from cloud: " + path);
    }
}

/**
 * Decorator Pattern for Image Processing
 */
interface ImageProcessor {
    BufferedImage process(BufferedImage image);
}

class BaseImageProcessor implements ImageProcessor {
    @Override
    public BufferedImage process(BufferedImage image) {
        return image;
    }
}

abstract class ImageProcessorDecorator implements ImageProcessor {
    protected ImageProcessor wrapped;
    
    public ImageProcessorDecorator(ImageProcessor wrapped) {
        this.wrapped = wrapped;
    }
}

class ResizeDecorator extends ImageProcessorDecorator {
    private int width, height;
    
    public ResizeDecorator(ImageProcessor wrapped, int width, int height) {
        super(wrapped);
        this.width = width;
        this.height = height;
    }
    
    @Override
    public BufferedImage process(BufferedImage image) {
        BufferedImage processed = wrapped.process(image);
        // Simplified resize
        Logger.getInstance().log("ImageProcessor", "Image resized to " + width + "x" + height);
        return processed;
    }
}

class SepiaDecorator extends ImageProcessorDecorator {
    public SepiaDecorator(ImageProcessor wrapped) {
        super(wrapped);
    }
    
    @Override
    public BufferedImage process(BufferedImage image) {
        BufferedImage processed = wrapped.process(image);
        // Apply sepia filter logic
        Logger.getInstance().log("ImageProcessor", "Sepia filter applied");
        return processed;
    }
}

class BlurDecorator extends ImageProcessorDecorator {
    public BlurDecorator(ImageProcessor wrapped) {
        super(wrapped);
    }
    
    @Override
    public BufferedImage process(BufferedImage image) {
        BufferedImage processed = wrapped.process(image);
        // Apply blur logic
        Logger.getInstance().log("ImageProcessor", "Blur filter applied");
        return processed;
    }
}
