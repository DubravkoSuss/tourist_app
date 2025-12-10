import javax.swing.*;
import java.awt.*;
import java.awt.event.*;

public class Main {
    public static void main(String[] args) {
        // Create the main window
        JFrame frame = new JFrame("Simple Calculator");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setSize(400, 200);
        frame.setLayout(new FlowLayout());

        // Create input fields
        JTextField num1Field = new JTextField(10);
        JTextField num2Field = new JTextField(10);

        // Create labels
        JLabel label1 = new JLabel("First Number:");
        JLabel label2 = new JLabel("Second Number:");
        JLabel resultLabel = new JLabel("Result: ");

        // Create buttons
        JButton addButton = new JButton("Add");
        JButton subtractButton = new JButton("Subtract");
        JButton multiplyButton = new JButton("Multiply");

        // Add action listeners to buttons
        addButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                try {
                    double n1 = Double.parseDouble(num1Field.getText());
                    double n2 = Double.parseDouble(num2Field.getText());
                    resultLabel.setText("Result: " + (n1 + n2));
                } catch (NumberFormatException ex) {
                    resultLabel.setText("Result: Invalid input!");
                }
            }
        });

        subtractButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                try {
                    double n1 = Double.parseDouble(num1Field.getText());
                    double n2 = Double.parseDouble(num2Field.getText());
                    resultLabel.setText("Result: " + (n1 - n2));
                } catch (NumberFormatException ex) {
                    resultLabel.setText("Result: Invalid input!");
                }
            }
        });

        multiplyButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                try {
                    double n1 = Double.parseDouble(num1Field.getText());
                    double n2 = Double.parseDouble(num2Field.getText());
                    resultLabel.setText("Result: " + (n1 * n2));
                } catch (NumberFormatException ex) {
                    resultLabel.setText("Result: Invalid input!");
                }
            }
        });

        // Add components to frame
        frame.add(label1);
        frame.add(num1Field);
        frame.add(label2);
        frame.add(num2Field);
        frame.add(addButton);
        frame.add(subtractButton);
        frame.add(multiplyButton);
        frame.add(resultLabel);

        // Make the window visible
        frame.setVisible(true);
    }
}