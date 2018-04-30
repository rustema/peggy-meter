package io.peggyjo.peggymeter;

import android.appwidget.AppWidgetManager;
import android.content.ComponentName;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.View;
import android.webkit.WebView;
import android.widget.Button;
import android.widget.Toast;

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
            displayWidgetDialogAndQuit();
        });

        ((Button) findViewById(R.id.OptOutButton)).setOnClickListener((x) -> {
            controller.getSettingAdapter().setProperty(OPT_IN_PROPERTY, false);
            displayWidgetDialogAndQuit();
        });
        ((WebView) findViewById(R.id.webView)).loadUrl("file:///android_asset/welcome.html");
    }

    private void goToHomeScreen() {
        Intent startMain = new Intent(Intent.ACTION_MAIN);
        startMain.addCategory(Intent.CATEGORY_HOME);
        startMain.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(startMain);
    }

    private void displayWidgetDialogAndQuit() {
        // Try to present pin widget request using the widget manager.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            AppWidgetManager appWidgetManager = this.getSystemService(AppWidgetManager.class);
            if (appWidgetManager.isRequestPinAppWidgetSupported()) {
                ComponentName widgetProvider = new ComponentName(this, MoodWidget.class);
                appWidgetManager.requestPinAppWidget(widgetProvider, null, null);
                finish();
                return;
            }
        }

        // Failure. Present the user with a simple dialog window.
        AlertDialog alertDialog = new AlertDialog.Builder(this).create();
        alertDialog.setTitle("Install widget to your home screen!");
        alertDialog.setMessage("This app includes a widget for your home screen. " +
                               "If you add the widget, you won't have to open " +
                               "the app to make entries (you still need to open " +
                               "the app to add notes).\n\n" +
                               "To add the widget\n" +
                               "1. Go to your home screeen.\n" +
                               "2. Go to the app and widget screen.\n" +
                               "3. Go to widgets.\n" +
                               "4. Select how you are feeling.");
        alertDialog.setButton(AlertDialog.BUTTON_POSITIVE, "Go to home screen",
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                        goToHomeScreen();
                        finish();
                    }
                });
        alertDialog.setButton(AlertDialog.BUTTON_NEGATIVE, "Skip",
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                        finish();
                    }
                });
        alertDialog.show();
    }
}
