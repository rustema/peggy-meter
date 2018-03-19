package io.peggyjo.peggymeter;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import android.widget.RemoteViews;

/**
 * Implementation of App Widget functionality.
 */
public class MoodWidget extends AppWidgetProvider {
    private static final String TAG = "PeggiMeter.Widget";

    static void updateAppWidget(Context context, AppWidgetManager appWidgetManager,
                                int appWidgetId) {

        // Construct the RemoteViews object
        RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.mood_widget);
        views.setOnClickPendingIntent(R.id.widget_mood0, createIntent(context, 0));
        views.setOnClickPendingIntent(R.id.widget_mood1, createIntent(context, 1));
        views.setOnClickPendingIntent(R.id.widget_mood2, createIntent(context, 2));
        views.setOnClickPendingIntent(R.id.widget_mood3, createIntent(context, 3));
        views.setOnClickPendingIntent(R.id.widget_mood4, createIntent(context, 4));

        // Instruct the widget manager to update the widget
        appWidgetManager.updateAppWidget(appWidgetId, views);
    }

    private static PendingIntent createIntent(Context context, int i) {
        Intent fillInIntent = new Intent(context, UpdateMoodActivity.class);
        fillInIntent.setAction("SET_MOOD_" + i);
        return PendingIntent.getActivity(context, 0, fillInIntent, 0);
    }

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        // There may be multiple widgets active, so update all of them
        for (int appWidgetId : appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId);
        }
    }

    @Override
    public void onDeleted(Context context, int[] appWidgetIds) {
    }

    @Override
    public void onEnabled(Context context) {
        // Enter relevant functionality for when the first widget is created
    }

    @Override
    public void onDisabled(Context context) {
        // Enter relevant functionality for when the last widget is disabled
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        super.onReceive(context, intent);
        Log.i(TAG, intent.getAction());
    }
}

