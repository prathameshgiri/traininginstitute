package com.traininginstitute.model;

/**
 * Option Model - MCQ Answer Options
 * @author Dr. Geeta Mete
 */
public class Option {
    private int optionId;
    private int questionId;
    private String optionText;
    private boolean isCorrect;
    private String optionLabel;  // A, B, C, D

    public Option() {}

    public Option(int optionId, int questionId, String optionText, boolean isCorrect, String optionLabel) {
        this.optionId = optionId;
        this.questionId = questionId;
        this.optionText = optionText;
        this.isCorrect = isCorrect;
        this.optionLabel = optionLabel;
    }

    public int getOptionId() { return optionId; }
    public void setOptionId(int optionId) { this.optionId = optionId; }

    public int getQuestionId() { return questionId; }
    public void setQuestionId(int questionId) { this.questionId = questionId; }

    public String getOptionText() { return optionText; }
    public void setOptionText(String optionText) { this.optionText = optionText; }

    public boolean isCorrect() { return isCorrect; }
    public void setCorrect(boolean correct) { isCorrect = correct; }

    public String getOptionLabel() { return optionLabel; }
    public void setOptionLabel(String optionLabel) { this.optionLabel = optionLabel; }
}
