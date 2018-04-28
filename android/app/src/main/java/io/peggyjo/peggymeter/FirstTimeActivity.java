package io.peggyjo.peggymeter;

import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;

import com.crashlytics.android.Crashlytics;

import io.peggyjo.peggymeter.database.DataController;

import static io.peggyjo.peggymeter.model.Constants.OPT_IN_PROPERTY;

public class FirstTimeActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_first_time);
        DataController controller = new DataController();
        ((Button) findViewById(R.id.OptInButton)).setOnClickListener((x) -> {
            controller.getSettingAdapter().setProperty(OPT_IN_PROPERTY, true);
            finish();
        });

        ((Button) findViewById(R.id.OptOutButton)).setOnClickListener((x) -> {
            controller.getSettingAdapter().setProperty(OPT_IN_PROPERTY, false);
            finish();
        });

        // Adds a button that will crash the app
        // Is used to test Crashlytics in the console.
        Button crashButton = new Button(this);
        crashButton.setText("Crash!");
        crashButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View view) {
                Crashlytics.getInstance().crash(); // Force a crash
            }
        });
        addContentView(crashButton,
                new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                        ViewGroup.LayoutParams.WRAP_CONTENT));
    }

}
