package com.traininginstitute.model;

import java.util.List;

/**
 * Question Model - Exam Questions (MCQ + Subjective)
 * @author Dr. Geeta Mete
 */
public class Question {
    private int questionId;
    private int examId;
    private String questionText;
    private String type;       // MCQ, SUBJECTIVE
    private int marks;
    private String difficulty; // EASY, MEDIUM, HARD
    private int sequenceNo;
    private String imagePath;

    // For MCQ: options list
    private List<Option> options;

    // For exam attempt: student's answer
    private Integer selectedOption;    // option_id chosen
    private String descriptiveAnswer;
    private boolean isMarkedReview;
    private boolean isSkipped;
    private double marksAwarded;
    private int answerId;

    public Question() {}

    public int getQuestionId() { return questionId; }
    public void setQuestionId(int questionId) { this.questionId = questionId; }

    public int getExamId() { return examId; }
    public void setExamId(int examId) { this.examId = examId; }

    public String getQuestionText() { return questionText; }
    public void setQuestionText(String questionText) { this.questionText = questionText; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public int getMarks() { return marks; }
    public void setMarks(int marks) { this.marks = marks; }

    public String getDifficulty() { return difficulty; }
    public void setDifficulty(String difficulty) { this.difficulty = difficulty; }

    public int getSequenceNo() { return sequenceNo; }
    public void setSequenceNo(int sequenceNo) { this.sequenceNo = sequenceNo; }

    public String getImagePath() { return imagePath; }
    public void setImagePath(String imagePath) { this.imagePath = imagePath; }

    public List<Option> getOptions() { return options; }
    public void setOptions(List<Option> options) { this.options = options; }

    public Integer getSelectedOption() { return selectedOption; }
    public void setSelectedOption(Integer selectedOption) { this.selectedOption = selectedOption; }

    public String getDescriptiveAnswer() { return descriptiveAnswer; }
    public void setDescriptiveAnswer(String descriptiveAnswer) { this.descriptiveAnswer = descriptiveAnswer; }

    public boolean isMarkedReview() { return isMarkedReview; }
    public void setMarkedReview(boolean markedReview) { isMarkedReview = markedReview; }

    public boolean isSkipped() { return isSkipped; }
    public void setSkipped(boolean skipped) { isSkipped = skipped; }

    public double getMarksAwarded() { return marksAwarded; }
    public void setMarksAwarded(double marksAwarded) { this.marksAwarded = marksAwarded; }

    public int getAnswerId() { return answerId; }
    public void setAnswerId(int answerId) { this.answerId = answerId; }

    public boolean isMCQ() { return "MCQ".equals(type); }
    public boolean isSubjective() { return "SUBJECTIVE".equals(type); }

    public boolean isAnswered() {
        return (selectedOption != null) || (descriptiveAnswer != null && !descriptiveAnswer.trim().isEmpty());
    }
}
