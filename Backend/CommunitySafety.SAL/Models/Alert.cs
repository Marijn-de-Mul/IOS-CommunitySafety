namespace CommunitySafety.SAL.Models;

public class Alert { 
    public string Title { get; set; } 
    public string Description { get; set; } 
    public AlertSeverity Severity { get; set; } 
    public AlertType Type { get; set; } 
    public Coordinates Location { get; set; } 
} 