package io.peggyjo.peggymeter;

import android.content.Context;
import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;

import java.util.Date;

public class UpdateMoodActivity extends AppCompatActivity {
    private static final String TAG = "PeggiMeter.update";
    private DataController controller = new DataController();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        moveTaskToBack(true); // TODO or add comment?
        if (getIntent().getAction().startsWith("SET_MOOD_")) {
            Log.i(TAG, getIntent().getAction());
            controller.addEntry(new LogEntry(
                    new Date(), Integer.valueOf(getIntent().getAction().substring(9)), ""));
        }
        finish();

    }
}
