package io.peggyjo.peggymeter.database;

import android.util.Log;

import com.google.common.collect.ImmutableMap;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Map;

import io.peggyjo.peggymeter.model.LogEntry;
import io.peggyjo.peggymeter.model.MoodListener;

/**
 * Created by demetr on 3/20/18.
 */
public class MoodAdapter implements ValueEventListener {
    private static final String TAG = "PeggiMeter.MoodAdapter";

    private final DatabaseReference moods;
    private final DataController dataController;
    private final List<LogEntry> logs;
    private final List<MoodListener> listeners;

    MoodAdapter(DataController dataController) {
        this.dataController = dataController;
        this.logs = new ArrayList<>();
        this.listeners = new ArrayList<>();
        moods = dataController.getReference().child("mood").getRef();
        moods.addValueEventListener(this);
    }

    public List<LogEntry> getLogs() {
        return logs;
    }

    @Override
    public void onDataChange(DataSnapshot dataSnapshot) {
        Object values = dataSnapshot.getValue(Object.class);
        if (values == null) {
            // TODO init database.
        } else if (values instanceof Map) {
            Map<String, Map<String, Object>> data = (Map<String, Map<String, Object>>) values;
            Log.i(TAG, "" + data);
            logs.clear();
            for (Map<String, Object> entry : data.values()) {
                logs.add(new LogEntry(
                        new Date((Long) entry.get("timestamp")),
                        ((Long) entry.get("moodLevel")).intValue(),
                        "" +entry.get("comment")));
            }
            //set a reference to each entry's id
            for (int i = 0; i < logs.size(); i++) {
                logs.get(i).setEntryId(data.keySet().toArray()[i].toString());

            }

            Collections.sort(logs, (a, b) -> a.getTime().compareTo(b.getTime()));
            for (MoodListener moodListener : listeners) {
                moodListener.refresh(logs);
            }
        }
    }

    @Override
    public void onCancelled(DatabaseError databaseError) {
    }

    public void addEntry(LogEntry entry) {
        logs.add(entry);
        for (MoodListener moodListener : listeners) {
            moodListener.refresh(logs);
        }
        DatabaseReference newEntry = moods.push();
        newEntry.setValue(ImmutableMap.<String, Object>builder()
                .put("timestamp", entry.getTime().getTime())
                .put("moodLevel", entry.getMood_level())
                .put("comment", entry.getComment())
                .build());
    }

    public void editEntry(LogEntry entry, LogEntry localUpdateEntry, int position) {
        logs.set(position, localUpdateEntry);

        for (MoodListener listener : listeners) {
            listener.refresh(logs);
        }
        DatabaseReference currentRecord = moods.child(entry.getEntryId()).getRef();
        currentRecord.setValue(ImmutableMap.<String, Object>builder()
                     .put("timestamp", entry.getTime().getTime())
                     .put("moodLevel", entry.getMood_level())
                     .put("comment", localUpdateEntry.getComment())
                     .build());
    }

    void addListener(MoodListener listener) {
        this.listeners.add(listener);
    }
}
