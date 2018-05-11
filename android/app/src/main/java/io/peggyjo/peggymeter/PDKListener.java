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


public class PDKListener implements Generators.GeneratorUpdatedListener,
        OnCompleteListener<Void> {
    private HashMap<String, Long> timestamps = new HashMap<>();
    private  final FirebaseFirestore db = FirebaseFirestore.getInstance();

    public void onGeneratorUpdated(String identifier, long timestamp, Bundle data) {
       //Log.i("PDK listener", "id: " + identifier + " | ts: " + timestamp + " | data.size = " + data.size());
        if (!timestamps.containsKey(identifier)) {
            timestamps.put(identifier, timestamp);
        } else {
            Date lastEntry = new Date(timestamps.get(identifier));
            Date current = Calendar.getInstance().getTime();

            long deltaMins = calculateDeltaMins(current, lastEntry);
            Log.i(identifier, "" + deltaMins);

            if (deltaMins > 20) {
                // TODO: implement uploading to Firebase.

                //Sample generator data
               String uid = FirebaseAuth.getInstance().getCurrentUser().getUid();
                HashMap<String, Object> dataMap = new HashMap<>();
                dataMap.put("data", data.toString());
                //write the data to a collection
                WriteBatch batch = db.batch();
                String docKey = uid + "-" + identifier + "-" + timestamp;
                DocumentReference docRef = db.collection("pdk").document(docKey);
                batch.set(docRef, dataMap);
                batch.commit().addOnCompleteListener(this);

                //update the timestamp for this generator
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
        long secondsInMills = 1000;
        long minutesInMills = secondsInMills * 60;
        long hoursInMills = minutesInMills * 60;
        long daysInMills = hoursInMills * 24;

        long difActual = current.getTime() - previous.getTime();

        difActual = difActual % daysInMills;
        difActual = difActual % hoursInMills;

        long minuteDiff = difActual / minutesInMills;
        return minuteDiff;
    }
}
