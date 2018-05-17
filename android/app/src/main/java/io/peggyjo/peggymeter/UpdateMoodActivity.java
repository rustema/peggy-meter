package io.peggyjo.peggymeter;

import android.media.MediaPlayer;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;

import com.google.common.collect.ImmutableList;

import java.util.Date;

import io.peggyjo.peggymeter.database.DataController;
import io.peggyjo.peggymeter.model.LogEntry;

public class UpdateMoodActivity extends AppCompatActivity implements MediaPlayer.OnCompletionListener {
    private static final ImmutableList<String> messages = ImmutableList.of(
            "Don't touch me",
            "Not my best day...",
            "Normal",
            "Feeling good",
            "Feeling awesome!"
    );
    private static final String TAG = "PeggiMeter.update";
    private DataController controller = new DataController();
    private MediaPlayer sfxWidget;

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
            MoodControlFragment mcf = new MoodControlFragment();
            sfxWidget = mcf.getSfxPlayer();

            if (sfxWidget == null) {
                sfxWidget = MediaPlayer.create(getApplicationContext(), R.raw.peggyjoemojitap1);
            }

            if (!sfxWidget.isPlaying()) {
                sfxWidget.setOnCompletionListener(this);
                sfxWidget.start();
            }
        }


        finish();

    }

    @Override
    public void onCompletion(MediaPlayer mediaPlayer) {
        //free resources
        mediaPlayer.release();
        mediaPlayer = null;
    }
}
