package io.peggyjo.peggymeter;


import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.github.mikephil.charting.charts.LineChart;
import com.github.mikephil.charting.components.AxisBase;
import com.github.mikephil.charting.components.Legend;
import com.github.mikephil.charting.components.XAxis;
import com.github.mikephil.charting.components.YAxis;
import com.github.mikephil.charting.data.Entry;
import com.github.mikephil.charting.data.LineData;
import com.github.mikephil.charting.data.LineDataSet;
import com.github.mikephil.charting.formatter.IAxisValueFormatter;
import com.github.mikephil.charting.utils.ColorTemplate;
import com.github.mikephil.charting.utils.ViewPortHandler;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.TimeUnit;

import io.peggyjo.peggymeter.database.DataController;
import io.peggyjo.peggymeter.model.MoodListener;
import io.peggyjo.peggymeter.model.LogEntry;


/**
 * A simple {@link Fragment} subclass.
 */
public class HistoryGraphFragment extends Fragment implements MoodListener {

    private long offset;

    public HistoryGraphFragment() {
    }


    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        try {
            this.offset = DateFormat.getInstance().parse("1/1/18 4:5 PM, PDT").getTime();
        } catch (ParseException e) {
            e.printStackTrace();
        }
        MainActivity mainActivity = (MainActivity)getActivity();
        // Inflate the layout for this fragment
        View v = inflater.inflate(R.layout.fragment_history_graph, container, false);
        DataController dataController = mainActivity.getDataController();
        dataController.getMoodAdapter().addListener(this);
        drawGraph(v, dataController.getMoodAdapter().getLogs());
        return v;
    }

    private void drawGraph(View v, List<LogEntry> log) {
        if (v == null) {
            return; // No active graphs.
        }
        LineChart mHistoryGraph = v.findViewById(R.id.history_graph);
        mHistoryGraph.invalidate();
        mHistoryGraph.fitScreen();
        // Add data.
        setData(log, mHistoryGraph);

        mHistoryGraph.setTouchEnabled(true);
        mHistoryGraph.setDragDecelerationFrictionCoef(0.9f);

        // Enable scaling and dragging.
        mHistoryGraph.setDragXEnabled(true);
        mHistoryGraph.setDragYEnabled(false);
        mHistoryGraph.setScaleXEnabled(true);
        mHistoryGraph.setScaleYEnabled(false);
        mHistoryGraph.setDrawGridBackground(false);
        mHistoryGraph.setHighlightPerDragEnabled(true);

        // Set an alternative background color.
        mHistoryGraph.setBackgroundColor(Color.WHITE);

        // Get the legend (only possible after setting data).
        Legend l = mHistoryGraph.getLegend();
        l.setEnabled(false);

        XAxis xAxis = mHistoryGraph.getXAxis();
        xAxis.setPosition(XAxis.XAxisPosition.TOP_INSIDE);
        //xAxis.setTypeface(mTfLight);
        mHistoryGraph.getDescription().setText("");
        xAxis.setTextSize(9f);
        xAxis.setTextColor(Color.WHITE);
        xAxis.setDrawAxisLine(false);
        xAxis.setDrawGridLines(true);
        xAxis.setTextColor(Color.rgb(255, 192, 56));
        xAxis.setCenterAxisLabels(true);
        xAxis.setGranularity(60f); // one minute
        xAxis.setValueFormatter(new IAxisValueFormatter() {

            private SimpleDateFormat mFormat = new SimpleDateFormat("MMM dd, h a", Locale.US);

            @Override
            public String getFormattedValue(float value, AxisBase axis) {

                long millis = TimeUnit.SECONDS.toMillis((long) value) + offset;
                return mFormat.format(new Date(millis));
            }
        });

        YAxis leftAxis = mHistoryGraph.getAxisLeft();
        leftAxis.setPosition(YAxis.YAxisLabelPosition.INSIDE_CHART);
        leftAxis.setDrawLabels(false);
        //leftAxis.setTypeface(mTfLight);
        leftAxis.setTextColor(ColorTemplate.getHoloBlue());
        leftAxis.setDrawGridLines(true);
        leftAxis.setGranularityEnabled(true);
        leftAxis.setAxisMinimum(0f);
        leftAxis.setAxisMaximum(4f);
        leftAxis.setYOffset(-9f);
        leftAxis.setTextColor(Color.rgb(255, 192, 56));

        YAxis rightAxis = mHistoryGraph.getAxisRight();
        rightAxis.setEnabled(false);
    }

    private void setData(List<LogEntry> entries, LineChart mHistoryGraph) {
        if (entries.isEmpty()) {
          //mHistoryGraph.clearValues();
          return;
        }
        ArrayList<Entry> values = new ArrayList<Entry>();

        for (LogEntry entry : entries) {
                values.add(new Entry(TimeUnit.MILLISECONDS.toSeconds(
                        entry.getTime().getTime() - offset), entry.getMood_level()));
        }

        // Create a dataset and give it a type.
        LineDataSet set1 = new LineDataSet(values, "DataSet 1");
        set1.setAxisDependency(YAxis.AxisDependency.LEFT);
        set1.setColor(ColorTemplate.getHoloBlue());
        set1.setValueTextColor(ColorTemplate.getHoloBlue());
        set1.setLineWidth(1.5f);
        set1.setDrawCircles(true);
        set1.setDrawValues(true);
        set1.setFillAlpha(65);
        set1.setFillColor(ColorTemplate.getHoloBlue());
        set1.setHighLightColor(Color.rgb(244, 117, 117));
        set1.setDrawCircleHole(false);
        set1.setValueFormatter(new SmileyValueFormatter());

        // Create a data object with the datasets.
        LineData data = new LineData(set1);
        data.setValueTextColor(Color.WHITE);
        data.setValueTextSize(9f);

        // Set data.
        mHistoryGraph.setData(data);
    }

    @Override
    public void refresh(List<LogEntry> entries) {
        this.drawGraph(this.getView(), entries);
    }

    private class SmileyValueFormatter implements com.github.mikephil.charting.formatter.IValueFormatter {
        @Override
        public String getFormattedValue(float value, Entry entry, int dataSetIndex, ViewPortHandler viewPortHandler) {
            String[] smileys = {
                    getResources().getString(R.string.smile0),
                    getResources().getString(R.string.smile1),
                    getResources().getString(R.string.smile2),
                    getResources().getString(R.string.smile3),
                    getResources().getString(R.string.smile4)};

            return smileys[(int)value];
        }
    }
}
