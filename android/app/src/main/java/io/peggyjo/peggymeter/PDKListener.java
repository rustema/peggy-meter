package io.peggyjo.peggymeter;

import android.content.Context;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.util.Log;
import com.audacious_software.passive_data_kit.generators.Generators;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.WriteBatch;


import java.util.Calendar;
import java.util.HashMap;
import java.util.Date;
import java.util.concurrent.TimeUnit;


public class PDKListener implements Generators.GeneratorUpdatedListener,
        OnCompleteListener<Void> {
    private final HashMap<String, Long> timestamps = new HashMap<>();
    private final FirebaseFirestore db = FirebaseFirestore.getInstance();
    private final String uid = FirebaseAuth.getInstance().getCurrentUser().getUid();

    public void onGeneratorUpdated(String identifier, long timestamp, Bundle data) {

        if (!timestamps.containsKey(identifier)) {
            String docKey = uid + "-" + identifier + "-" + timestamp;
            uploadBatch(data, docKey);
            timestamps.put(identifier, timestamp);
        } else {
            Date lastEntry = new Date(timestamps.get(identifier));
            Date current = Calendar.getInstance().getTime();
            long deltaMins = calculateDeltaMins(current, lastEntry);

            if (deltaMins > 20) {
                String docKey = uid + "-" + identifier + "-" + timestamp;
                uploadBatch(data, docKey);
                timestamps.put(identifier, timestamp);
            }
        }
    }

    public void initialize(Context context) {
        Context appCtx = context.getApplicationContext();
        Generators.getInstance(appCtx).addNewGeneratorUpdatedListener(this);
    }

    @Override
    public void onComplete(@NonNull Task<Void> task) {
        if (task.isSuccessful()) {
            Log.i("PDKListener", "Batch write succeeded.");
        } else {
            Log.i("PDKListener", "Error writing batch.");
        }
    }

    private long calculateDeltaMins(Date current, Date previous) {
        long diffMills = current.getTime() - previous.getTime();
        long deltaMins = TimeUnit.MINUTES.convert(diffMills, TimeUnit.MILLISECONDS);
        return deltaMins;
    }

    private void uploadBatch(Bundle data, String docKey) {
        HashMap<String, Object> dataMap = new HashMap<>();
        DocumentReference docRef = db.collection("pdk").document(docKey);
        WriteBatch batch = db.batch();
        dataMap.put("data", data.toString());
        batch.set(docRef, dataMap);
        batch.commit().addOnCompleteListener(this);
    }
}
