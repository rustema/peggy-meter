package io.peggyjo.peggymeter.model;

import java.util.List;

import io.peggyjo.peggymeter.model.LogEntry;

/**
 * Created by vyakunin on 3/18/18.
 */

public interface MoodListener {
    public void refresh(List<LogEntry> entries);
}
