package io.peggyjo.peggymeter;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;

import com.google.common.collect.ImmutableList;

import java.util.Date;

import io.peggyjo.peggymeter.database.DataController;
import io.peggyjo.peggymeter.model.LogEntry;

public class UpdateMoodActivity extends AppCompatActivity {
    private static final ImmutableList<String> messages = ImmutableList.of(
            "Don't touch me",
            "Not my best day...",
            "Normal",
            "Feeling good",
            "Feeling awesome!"
    );
    private static final String TAG = "PeggiMeter.update";
    private DataController controller = new DataController();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        moveTaskToBack(true); // TODO or add comment?
        if (getIntent().getAction().startsWith("SET_MOOD_")) {
            Log.i(TAG, getIntent().getAction());
            int mood = Integer.valueOf(getIntent().getAction().substring(9));
            //@param id is empty because
            // entryId is set
            // in MoodAdapter
            controller.getMoodAdapter().addEntry(new LogEntry(
                    "", new Date(), mood, ""));
            Toast toast = Toast.makeText(getApplicationContext(), messages.get(mood), Toast.LENGTH_SHORT);
            toast.show();
        }
        finish();

    }
}
