package io.peggyjo.peggymeter.database;

import android.util.Log;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

/**
 * Created by vyakunin on 3/4/18.
 */
public class DataController {
    private static final String TAG = "PeggiMeter.DataCtrl";

    private MoodAdapter moodAdapter;
    private SettingAdapter settingAdapter;
    private DatabaseReference settings;
    private String uid;

    public DataController() {
        FirebaseAuth firebaseAuth = FirebaseAuth.getInstance();
        FirebaseUser user = firebaseAuth.getCurrentUser();
        if (user == null) {
            Log.i(TAG, "Logging user");
            firebaseAuth.signInAnonymously().addOnCompleteListener((x) -> initDB());
        } else {
            initDB();
            Log.i(TAG, "Logged as user " + user.getUid());
        }
    }

    private void initDB() {
        FirebaseAuth firebaseAuth = FirebaseAuth.getInstance();
        FirebaseUser user = firebaseAuth.getCurrentUser();
        uid = user.getUid();
        moodAdapter = new MoodAdapter(this);
        settingAdapter = new SettingAdapter(this);
    }

    public DatabaseReference getReference() {
        return FirebaseDatabase.getInstance().getReference("users").child(uid);
    }

    public MoodAdapter getMoodAdapter() {
        return moodAdapter;
    }

    public SettingAdapter getSettingAdapter() {
        return settingAdapter;
    }
}
