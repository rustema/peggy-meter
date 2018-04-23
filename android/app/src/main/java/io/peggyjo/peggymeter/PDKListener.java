package io.peggyjo.peggymeter;

import android.content.Context;
import android.os.Bundle;
import android.util.Log;

import com.audacious_software.passive_data_kit.generators.Generators;

public class PDKListener implements Generators.GeneratorUpdatedListener {
    public void onGeneratorUpdated(String identifier, long timestamp, Bundle data) {
        Log.i("PDK listener", "id: " + identifier + " | ts: " + timestamp + " | data.size = " + data.size());
        // TODO: implement uploading to Firebase.
    }
    public void initialize(Context context) {
        Context appCtx = context.getApplicationContext();
        Generators.getInstance(appCtx).addNewGeneratorUpdatedListener(this);
    }
}
