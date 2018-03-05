package io.peggyjo.peggymeter;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by vyakunin on 3/4/18.
 */

public class DataController {
    public DataController() {
        this.entries = new ArrayList<>();
    }

    private List<LogEntry> entries;

    void addEntry(LogEntry entry) {
        entries.add(entry);
        graph.refresh(entries);
    }


     void setGraph(HistoryGraphFragment graph) {
        this.graph = graph;
    }

    HistoryGraphFragment graph;
}
