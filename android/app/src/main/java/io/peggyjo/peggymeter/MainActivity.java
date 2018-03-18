package io.peggyjo.peggymeter;

import android.os.Bundle;
import android.support.design.widget.NavigationView;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.MenuItem;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;

public class MainActivity extends AppCompatActivity implements NavigationView.OnNavigationItemSelectedListener {
    private static final String TAG = "PeggiMeter.Main";

    private DrawerLayout mDrawerLayout;

    private DataController dataController;

    public DataController getDataController() {
        return dataController;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        this.dataController = new DataController();
        showStatScreen();
        setContentView(R.layout.activity_main);
        installMenu();
    }

    @Override
    protected void onStart() {
        super.onStart();
    }


    private void showStatScreen() {
        HistoryGraphFragment historyGraphFragment = new HistoryGraphFragment();
        dataController.setGraph(historyGraphFragment);
        getSupportFragmentManager().beginTransaction()
                .add(R.id.MOOD_CONTROL_FRAGMENT_CONTAINER, new MoodControlFragment())
                .add(R.id.GRAPH_FRAGMENT_CONTAINER, historyGraphFragment)
                .commit();
    }

    private void installMenu() {
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        ActionBar actionbar = getSupportActionBar();
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

    // Menu navigation ends
}
