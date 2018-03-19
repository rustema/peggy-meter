package io.peggyjo.peggymeter;

import java.util.List;

/**
 * Created by vyakunin on 3/18/18.
 */

interface HistoryView {
    public void refresh(List<LogEntry> entries);
}
