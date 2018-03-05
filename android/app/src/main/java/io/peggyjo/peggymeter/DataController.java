package io.peggyjo.peggymeter;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by vyakunin on 3/4/18.
 */

public class DataController {
    public DataController() {
        this.log = new ArrayList<>();
    }

    public List<LogEntry> getLog() {
        return log;
    }

    private List<LogEntry> log;

    void addEntry(LogEntry entry) {
        log.add(entry);
        graph.refresh(log);
    }


     void setGraph(HistoryGraphFragment graph) {
        this.graph = graph;
    }

    HistoryGraphFragment graph;
}
