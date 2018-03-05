package io.peggyjo.peggymeter;

/**
 * Created by vyakunin on 3/4/18.
 */

import android.arch.persistence.room.ColumnInfo;
import android.arch.persistence.room.Entity;
import android.arch.persistence.room.PrimaryKey;
import java.util.Date;

@Entity
class LogEntry {
    @PrimaryKey
    private long uid;

    public Date getTime() {
        return time;
    }

    public int getMood_level() {
        return mood_level;
    }

    public String getComment() {
        return comment;
    }

    @ColumnInfo(name = "time")
    private Date time;

    @ColumnInfo(name = "mood_level")
    private int mood_level;

    @ColumnInfo(name = "comment")
    private String comment;

    LogEntry(Date time, int mood_level, String comment) {
        this.time = time;
        this.mood_level = mood_level;
        this.comment = comment;
    }
}