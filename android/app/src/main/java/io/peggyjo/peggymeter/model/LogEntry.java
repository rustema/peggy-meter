package io.peggyjo.peggymeter.model;

/**
 * Created by vyakunin on 3/4/18.
 */
import java.util.Date;
public class LogEntry {
    private final Date time;
    private final int mood_level;
    private final String comment;
    private String entryId;

    public LogEntry(Date time, int mood_level, String comment) {
        this.time = time;
        this.mood_level = mood_level;
        this.comment = comment;
        this.entryId = "";
    }
    public String getEntryId() {
        return entryId;
    }

    public void setEntryId(String id) {
            entryId = id;
    }
    public Date getTime() {
        return time;
    }

    public int getMood_level() {
        return mood_level;
    }

    public String getComment() {
        return comment;
    }
}