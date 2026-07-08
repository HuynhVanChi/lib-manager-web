package categories;

import java.sql.Timestamp;

public class Category {
    private int categoryId;
    private String name;
    private String description;
    private String colorTheme;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private Timestamp deletedAt;
    private Integer deletedBy;

    public Category() {
    }

    public Category(int categoryId, String name, String description) {
        this.categoryId = categoryId;
        this.name = name;
        this.description = description;
    }

    public Category(int categoryId, String name, String description, String colorTheme) {
        this.categoryId = categoryId;
        this.name = name;
        this.description = description;
        this.colorTheme = colorTheme;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public Timestamp getDeletedAt() {
        return deletedAt;
    }

    public void setDeletedAt(Timestamp deletedAt) {
        this.deletedAt = deletedAt;
    }

    public Integer getDeletedBy() {
        return deletedBy;
    }

    public void setDeletedBy(Integer deletedBy) {
        this.deletedBy = deletedBy;
    }

    public String getColorTheme() {
        return colorTheme;
    }

    public void setColorTheme(String colorTheme) {
        this.colorTheme = colorTheme;
    }

    public String getHexColor() {
        if (this.colorTheme == null) return "#64748b"; // slate default
        switch (this.colorTheme.toLowerCase()) {
            case "blue": return "#3b82f6";
            case "indigo": return "#6366f1";
            case "purple": return "#a855f7";
            case "pink": return "#ec4899";
            case "rose": return "#f43f5e";
            case "red": return "#ef4444";
            case "orange": return "#f97316";
            case "amber": return "#f59e0b";
            case "emerald": return "#10b981";
            case "teal": return "#14b8a6";
            default: return "#64748b"; // slate
        }
    }
}
