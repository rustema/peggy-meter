package io.peggyjo.peggymeter;

import android.content.Context;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.util.Log;
import com.audacious_software.passive_data_kit.generators.Generators;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.firestore.FirebaseFirestore;

import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.concurrent.TimeUnit;

public class PDKListener implements Generators.GeneratorUpdatedListener,
        OnCompleteListener<Void> {
    private final HashMap<String, Long> timestamps = new HashMap<>();
    private final FirebaseFirestore db = FirebaseFirestore.getInstance();
    private final String uid = FirebaseAuth.getInstance().getCurrentUser().getUid();

    public void onGeneratorUpdated(String identifier, long timestamp, Bundle data) {
        boolean shouldUpload = shouldUploadData(identifier, timestamp);

        if (shouldUpload) {
            String docKey = uid + "-" + identifier + "-" + timestamp;
            uploadData(data, docKey);
        }
    }

    public void initialize(Context context) {
        Context appCtx = context.getApplicationContext();
        Generators.getInstance(appCtx).addNewGeneratorUpdatedListener(this);
    }

    @Override
    public void onComplete(@NonNull Task<Void> task) {
        if (task.isSuccessful()) {
            Log.i("PDKListener", "File write succeeded.");
        } else {
            Log.i("PDKListener", "Error writing file.");
        }
    }

    private long calculateDeltaMins(Date current, Date previous) {
        long diffMills = current.getTime() - previous.getTime();
        long deltaMins = TimeUnit.MINUTES.convert(
                diffMills, TimeUnit.MILLISECONDS);
        return deltaMins;
    }

    private boolean shouldUploadData(String identifier, long timestamp) {
        if (!timestamps.containsKey(identifier)) {
            timestamps.put(identifier, timestamp);
            return true;
        }
        Date now = Calendar.getInstance().getTime();
        Date entry = new Date(timestamps.get(identifier));
        long deltaMins = calculateDeltaMins(now, entry);

        if (deltaMins > 20) {
            timestamps.put(identifier, timestamp);
            return true;
        }
        return false;
    }

    private void uploadData(Bundle data, String docKey) {
        HashMap<String, Object> dataMap = new HashMap<>();
        dataMap.put("data", data.toString());
        db.collection("pdk")
                .document(docKey)
                .set(dataMap)
                .addOnCompleteListener(this);
    }
}
