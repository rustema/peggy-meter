package io.peggyjo.peggymeter.database;

import android.util.Log;

import com.google.common.collect.ImmutableMap;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.peggyjo.peggymeter.model.LogEntry;
import io.peggyjo.peggymeter.model.SettingListener;

/**
 * Created by demetr on 3/20/18.
 */
public class SettingAdapter implements ValueEventListener {
    private static final String TAG = "PeggiMeter.Setting";

    private final DatabaseReference settings;
    private final DataController dataController;
    private final Map<String, Object> settingsLocalCache;
    private final List<SettingListener> listeners;

    SettingAdapter(DataController dataController) {
        this.dataController = dataController;
        settingsLocalCache = new HashMap<>();
        listeners = new ArrayList<>();
        settings = dataController.getReference().child("settings").getRef();
        settings.addValueEventListener(this);
    }

    @Override
    public void onDataChange(DataSnapshot dataSnapshot) {
        Object values = dataSnapshot.getValue(Object.class);
        if (values == null) {
            // TODO init database.
        } else if (values instanceof Map) {
            Map<String, Object> data = (Map<String, Object>) values;
            Log.i(TAG, "" + data);
            settingsLocalCache.clear();
            settingsLocalCache.putAll(data);
            for (SettingListener listener : listeners) {
                listener.onSettingUpdate(settingsLocalCache);
            }
        }
    }

    @Override
    public void onCancelled(DatabaseError databaseError) {
    }

    public void setProperty(String key, Object value) {
        settingsLocalCache.put(key, value);
        settings.child(key).setValue(value);
    }
}
