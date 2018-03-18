package io.peggyjo.peggymeter;

import android.util.Log;

import com.google.common.collect.ImmutableMap;
import com.google.common.collect.Lists;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * Created by vyakunin on 3/4/18.
 */
public class DataController implements ValueEventListener {
    private static final String TAG = "PeggiMeter.DataCtrl";

    private List<LogEntry> logs;
    private HistoryGraphFragment graph;
    private DatabaseReference moods;
    private String uid;

    public DataController() {
        FirebaseAuth firebaseAuth = FirebaseAuth.getInstance();
        FirebaseUser user = firebaseAuth.getCurrentUser();
        if (user == null) {
            Log.i(TAG, "Logging user");
            firebaseAuth.signInAnonymously().addOnCompleteListener((x) -> initDB());
        } else {
            initDB();
            Log.i(TAG, "Logged as user " + user.getEmail());
        }
        this.logs = new ArrayList<>();
    }

    private void initDB() {
        FirebaseDatabase database = FirebaseDatabase.getInstance();
        FirebaseAuth firebaseAuth = FirebaseAuth.getInstance();
        FirebaseUser user = firebaseAuth.getCurrentUser();
        uid = user.getUid();
        moods = database.getReference("users").child(uid).child("mood").getRef();
        moods.addValueEventListener(this);
    }

    void addEntry(LogEntry entry) {
        logs.add(entry);
        graph.refresh(logs);
        DatabaseReference newEntry = moods.push();
        newEntry.setValue(ImmutableMap.<String, Object>builder()
                .put("timestamp", entry.getTime().getTime())
                .put("moodLevel", entry.getMood_level())
                .put("comment", entry.getComment())
                .build());
    }

    void setGraph(HistoryGraphFragment graph) {
        this.graph = graph;
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
            Collections.sort(logs, (a, b) -> a.getTime().compareTo(b.getTime()));
            if (graph != null) {
                graph.refresh(logs);
            }
        }
    }

    @Override
    public void onCancelled(DatabaseError databaseError) {
    }


}
