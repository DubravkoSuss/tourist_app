import javafx.application.Application;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.control.*;
import javafx.scene.layout.*;
import javafx.scene.paint.Color;
import javafx.scene.text.Font;
import javafx.scene.text.FontWeight;
import javafx.stage.Stage;

public class JavaFXDemo extends Application {

    private Label resultLabel;
    private int clickCount = 0;

    @Override
    public void start(Stage primaryStage) {
        // Create the main layout
        VBox mainLayout = new VBox(15);
        mainLayout.setPadding(new Insets(20));
        mainLayout.setAlignment(Pos.CENTER);
        mainLayout.setStyle("-fx-background-color: #f0f0f0;");

        // Title Label
        Label titleLabel = new Label("JavaFX Demo Application");
        titleLabel.setFont(Font.font("Arial", FontWeight.BOLD, 24));
        titleLabel.setTextFill(Color.DARKBLUE);

        // Text input section
        HBox inputSection = new HBox(10);
        inputSection.setAlignment(Pos.CENTER);
        Label nameLabel = new Label("Enter your name:");
        TextField nameField = new TextField();
        nameField.setPromptText("Type here...");
        nameField.setPrefWidth(200);
        inputSection.getChildren().addAll(nameLabel, nameField);

        // Button section
        HBox buttonSection = new HBox(10);
        buttonSection.setAlignment(Pos.CENTER);

        Button greetButton = new Button("Greet Me");
        greetButton.setStyle("-fx-background-color: #4CAF50; -fx-text-fill: white; -fx-font-size: 14px; -fx-padding: 10px;");

        Button countButton = new Button("Click Counter");
        countButton.setStyle("-fx-background-color: #2196F3; -fx-text-fill: white; -fx-font-size: 14px; -fx-padding: 10px;");

        Button colorButton = new Button("Change Color");
        colorButton.setStyle("-fx-background-color: #FF9800; -fx-text-fill: white; -fx-font-size: 14px; -fx-padding: 10px;");

        buttonSection.getChildren().addAll(greetButton, countButton, colorButton);

        // Result label
        resultLabel = new Label("Welcome! Try the buttons above.");
        resultLabel.setFont(Font.font("Arial", 16));
        resultLabel.setTextFill(Color.DARKGREEN);
        resultLabel.setWrapText(true);
        resultLabel.setMaxWidth(400);
        resultLabel.setAlignment(Pos.CENTER);

        // Slider section
        HBox sliderSection = new HBox(10);
        sliderSection.setAlignment(Pos.CENTER);
        Label sliderLabel = new Label("Adjust value:");
        Slider slider = new Slider(0, 100, 50);
        slider.setShowTickLabels(true);
        slider.setShowTickMarks(true);
        slider.setMajorTickUnit(25);
        slider.setPrefWidth(200);
        Label sliderValueLabel = new Label("50");
        sliderValueLabel.setMinWidth(30);
        sliderSection.getChildren().addAll(sliderLabel, slider, sliderValueLabel);

        // CheckBox and RadioButton section
        HBox choiceSection = new HBox(20);
        choiceSection.setAlignment(Pos.CENTER);

        CheckBox checkBox = new CheckBox("Enable notifications");

        ToggleGroup radioGroup = new ToggleGroup();
        RadioButton radio1 = new RadioButton("Option 1");
        RadioButton radio2 = new RadioButton("Option 2");
        radio1.setToggleGroup(radioGroup);
        radio2.setToggleGroup(radioGroup);
        radio1.setSelected(true);

        VBox radioBox = new VBox(5);
        radioBox.getChildren().addAll(radio1, radio2);

        choiceSection.getChildren().addAll(checkBox, radioBox);

        // ComboBox (dropdown)
        HBox comboSection = new HBox(10);
        comboSection.setAlignment(Pos.CENTER);
        Label comboLabel = new Label("Choose theme:");
        ComboBox<String> themeCombo = new ComboBox<>();
        themeCombo.getItems().addAll("Light", "Dark", "Blue", "Green");
        themeCombo.setValue("Light");
        comboSection.getChildren().addAll(comboLabel, themeCombo);

        // Event handlers
        greetButton.setOnAction(e -> {
            String name = nameField.getText().trim();
            if (name.isEmpty()) {
                resultLabel.setText("Please enter your name first!");
                resultLabel.setTextFill(Color.RED);
            } else {
                resultLabel.setText("Hello, " + name + "! Nice to meet you!");
                resultLabel.setTextFill(Color.DARKGREEN);
            }
        });

        countButton.setOnAction(e -> {
            clickCount++;
            resultLabel.setText("Button clicked " + clickCount + " times!");
            resultLabel.setTextFill(Color.DARKBLUE);
        });

        colorButton.setOnAction(e -> {
            Color randomColor = Color.rgb(
                    (int)(Math.random() * 256),
                    (int)(Math.random() * 256),
                    (int)(Math.random() * 256)
            );
            mainLayout.setStyle("-fx-background-color: #" +
                    String.format("%02x%02x%02x",
                            (int)(randomColor.getRed() * 255),
                            (int)(randomColor.getGreen() * 255),
                            (int)(randomColor.getBlue() * 255)) + ";");
            resultLabel.setText("Background color changed!");
            resultLabel.setTextFill(Color.DARKBLUE);
        });

        slider.valueProperty().addListener((obs, oldVal, newVal) -> {
            sliderValueLabel.setText(String.format("%.0f", newVal.doubleValue()));
        });

        checkBox.setOnAction(e -> {
            resultLabel.setText("Notifications " +
                    (checkBox.isSelected() ? "enabled" : "disabled"));
            resultLabel.setTextFill(Color.DARKBLUE);
        });

        themeCombo.setOnAction(e -> {
            String theme = themeCombo.getValue();
            resultLabel.setText("Theme changed to: " + theme);
            resultLabel.setTextFill(Color.DARKBLUE);
        });

        // Add all sections to main layout
        mainLayout.getChildren().addAll(
                titleLabel,
                new Separator(),
                inputSection,
                buttonSection,
                resultLabel,
                new Separator(),
                sliderSection,
                choiceSection,
                comboSection
        );

        // Create scene and show
        Scene scene = new Scene(mainLayout, 650, 600);
        primaryStage.setTitle("JavaFX Interactive Demo");
        primaryStage.setScene(scene);
        primaryStage.show();
    }

    public static void main(String[] args) {
        launch(args);
    }
}