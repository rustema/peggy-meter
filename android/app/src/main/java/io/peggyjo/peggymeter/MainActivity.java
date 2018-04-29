package io.peggyjo.peggymeter;

import android.content.Intent;
import android.os.Bundle;
import android.support.design.widget.NavigationView;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;

import com.audacious_software.passive_data_kit.PassiveDataKit;

import io.peggyjo.peggymeter.database.DataController;

import static io.peggyjo.peggymeter.model.Constants.OPT_IN_PROPERTY;

public class MainActivity extends AppCompatActivity implements NavigationView.OnNavigationItemSelectedListener {
    private static final String TAG = "PeggiMeter.Main";

    private DrawerLayout mDrawerLayout;

    private DataController dataController;
    private HistoryGraphFragment historyGraphFragment;
    private ViewMode currentMode = ViewMode.Graph;
    private HistoryTextFragment historyTextFragment;
    private MoodControlFragment moodControlFragment;
    private PDKListener pdkListener;

    public MainActivity() {
        this.dataController = new DataController();
    }

    public DataController getDataController() {
        return dataController;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        showStatScreen();
        setContentView(R.layout.activity_main);
        installMenu();
    }

    @Override
    protected void onStart() {
        super.onStart();
    }


    private void showStatScreen() {
        if (moodControlFragment == null) {
            moodControlFragment = new MoodControlFragment();
        }
        switch (currentMode) {
            case Graph:
                dataController.removeListener(historyGraphFragment);
                dataController.removeListener(historyTextFragment);
                // It's unclear when to draw a graph, since on re-show CreateView is not called.
                // Re-creating the whole fragment to have more predictable behavior, hoping overhead
                // is not too big.
                historyGraphFragment = new HistoryGraphFragment();
                dataController.addMoodListener(historyGraphFragment);
                dataController.addSettingListener((setting) -> {
                    if (!setting.containsKey(OPT_IN_PROPERTY)) {
                        startFirstTimeActivity();
                    } else if ((boolean) setting.get(OPT_IN_PROPERTY)) {
                        PassiveDataKit pdk = PassiveDataKit.getInstance(this);
                        pdk.setStartForegroundService(true);
                        pdk.start();
                        pdkListener = new PDKListener();
                        pdkListener.initialize(this);
                    } else {
                        // Stop PDK
                    }
                });

                getSupportFragmentManager().beginTransaction()
                        .replace(R.id.MOOD_CONTROL_FRAGMENT_CONTAINER, moodControlFragment)
                        .replace(R.id.HISTORY_FRAGMENT_CONTAINER, historyGraphFragment)
                        .commit();
                break;
            case Text:
                dataController.removeListener(historyGraphFragment);
                dataController.removeListener(historyTextFragment);
                // See historyGraphFragment re-creation comment above.
                historyTextFragment = new HistoryTextFragment();
                getSupportFragmentManager().beginTransaction().replace(
                        R.id.MOOD_CONTROL_FRAGMENT_CONTAINER, moodControlFragment).
                        replace(R.id.HISTORY_FRAGMENT_CONTAINER, historyTextFragment).commit();
                break;
        }
    }

    private void startFirstTimeActivity() {
        startActivity(new Intent(getApplicationContext(), FirstTimeActivity.class));
    }

    private void installMenu() {
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        ActionBar actionbar = getSupportActionBar();
        assert actionbar != null;
        actionbar.setDisplayHomeAsUpEnabled(true);
        actionbar.setHomeAsUpIndicator(R.drawable.ic_menu_black_24dp);

        mDrawerLayout = findViewById(R.id.drawer_layout);
        NavigationView navigationView = findViewById(R.id.nav_view);
        navigationView.setNavigationItemSelectedListener(this);
    }

    // Menu navigation begin

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                mDrawerLayout.openDrawer(GravityCompat.START);
                return true;
        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    public boolean onNavigationItemSelected(MenuItem menuItem) {
        // set item as selected to persist highlight
        menuItem.setChecked(true);
        // close drawer when item is tapped
        mDrawerLayout.closeDrawers();

        switch (menuItem.getItemId()) {
            case R.id.login_page:
                break;
            case R.id.stats_page:
                showStatScreen();
                break;
            default:
                Log.w(TAG, "Unknown menu item: " + menuItem.getItemId());
        }

        return true;
    }

    public void onToggleButtonClick(View view) {
        switch (currentMode) {
            case Text:
                currentMode = ViewMode.Graph;
                break;
            case Graph:
                currentMode = ViewMode.Text;
                break;
            default:
                Log.w(TAG, "Unknown mode of history: " + currentMode.toString());
        }

        showStatScreen();
    }

    // Menu navigation ends
}
