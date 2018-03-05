package io.peggyjo.peggymeter;


import android.graphics.Color;
import android.os.Bundle;
import android.app.Fragment;
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

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Random;
import java.util.concurrent.TimeUnit;


/**
 * A simple {@link Fragment} subclass.
 */
public class HistoryGraphFragment extends Fragment {

    private LineChart mHistoryGraph;
    private Random mRnd = new Random();

    public HistoryGraphFragment() {
        MainActivity mainActivity = (MainActivity)getActivity();
//        mainActivity.getDataController().setGraph(this);
    }


    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View v = inflater.inflate(R.layout.fragment_history_graph, container, false);

        mHistoryGraph = (LineChart)v.findViewById(R.id.history_graph);
        mHistoryGraph.setTouchEnabled(true);
        mHistoryGraph.setDragDecelerationFrictionCoef(0.9f);

        // Enable scaling and dragging.
        mHistoryGraph.setDragEnabled(true);
        mHistoryGraph.setScaleEnabled(true);
        mHistoryGraph.setDrawGridBackground(false);
        mHistoryGraph.setHighlightPerDragEnabled(true);

        // Set an alternative background color.
        mHistoryGraph.setBackgroundColor(Color.WHITE);
        mHistoryGraph.setViewPortOffsets(0f, 0f, 0f, 0f);

        // Add data.
        setData(100, 30);
        mHistoryGraph.invalidate();

        // Get the legend (only possible after setting data).
        Legend l = mHistoryGraph.getLegend();
        l.setEnabled(false);

        XAxis xAxis = mHistoryGraph.getXAxis();
        xAxis.setPosition(XAxis.XAxisPosition.TOP_INSIDE);
        //xAxis.setTypeface(mTfLight);
        xAxis.setTextSize(10f);
        xAxis.setTextColor(Color.WHITE);
        xAxis.setDrawAxisLine(false);
        xAxis.setDrawGridLines(true);
        xAxis.setTextColor(Color.rgb(255, 192, 56));
        xAxis.setCenterAxisLabels(true);
        xAxis.setGranularity(1f); // one hour
        xAxis.setValueFormatter(new IAxisValueFormatter() {

            private SimpleDateFormat mFormat = new SimpleDateFormat("dd MMM HH:mm");

            @Override
            public String getFormattedValue(float value, AxisBase axis) {

                long millis = TimeUnit.HOURS.toMillis((long) value);
                return mFormat.format(new Date(millis));
            }
        });

        YAxis leftAxis = mHistoryGraph.getAxisLeft();
        leftAxis.setPosition(YAxis.YAxisLabelPosition.INSIDE_CHART);
        //leftAxis.setTypeface(mTfLight);
        leftAxis.setTextColor(ColorTemplate.getHoloBlue());
        leftAxis.setDrawGridLines(true);
        leftAxis.setGranularityEnabled(true);
        leftAxis.setAxisMinimum(0f);
        leftAxis.setAxisMaximum(70f);
        leftAxis.setYOffset(-9f);
        leftAxis.setTextColor(Color.rgb(255, 192, 56));

        YAxis rightAxis = mHistoryGraph.getAxisRight();
        rightAxis.setEnabled(false);
        return v;
    }

    private void setData(int count, float range) {
        // now in hours
        long now = TimeUnit.MILLISECONDS.toHours(System.currentTimeMillis());

        ArrayList<Entry> values = new ArrayList<Entry>();

        float from = now;

        // count = hours
        float to = now + count;

        // increment by 1 hour
        for (float x = from; x < to; x++) {

            float y = mRnd.nextInt() % 50;
            values.add(new Entry(x, y)); // add one entry per hour
        }

        // Create a dataset and give it a type.
        LineDataSet set1 = new LineDataSet(values, "DataSet 1");
        set1.setAxisDependency(YAxis.AxisDependency.LEFT);
        set1.setColor(ColorTemplate.getHoloBlue());
        set1.setValueTextColor(ColorTemplate.getHoloBlue());
        set1.setLineWidth(1.5f);
        set1.setDrawCircles(false);
        set1.setDrawValues(false);
        set1.setFillAlpha(65);
        set1.setFillColor(ColorTemplate.getHoloBlue());
        set1.setHighLightColor(Color.rgb(244, 117, 117));
        set1.setDrawCircleHole(false);

        // Create a data object with the datasets.
        LineData data = new LineData(set1);
        data.setValueTextColor(Color.WHITE);
        data.setValueTextSize(9f);

        // Set data.
        mHistoryGraph.setData(data);
    }

    public void refresh(List<LogEntry> entries) {
        //mHistoryGraph.
    }
}
