package io.peggyjo.peggymeter;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;

public class MainActivity extends AppCompatActivity {
    public MainActivity() {

    }
    private static final String TAG = "PeggiMeter.Main";

    public DataController getDataController() {
        return dataController;
    }

    private DataController dataController;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        this.dataController = new DataController();
        setContentView(R.layout.activity_main);
    }

    @Override
    protected void onStart() {
        super.onStart();

        FirebaseUser user = FirebaseAuth.getInstance().getCurrentUser();
        if (user == null) {
            Log.i(TAG, "Logging user");
            Intent intent = new Intent(this, LoginActivity.class);
            startActivity(intent);
        } else {
            Log.i(TAG, "Logged as user " + user.getEmail());
        }
    }
}
