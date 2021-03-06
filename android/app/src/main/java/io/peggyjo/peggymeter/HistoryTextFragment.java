package io.peggyjo.peggymeter;

import android.support.v4.app.Fragment;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListView;

import java.util.List;

import io.peggyjo.peggymeter.database.DataController;
import io.peggyjo.peggymeter.model.MoodListener;
import io.peggyjo.peggymeter.model.LogEntry;

import static com.google.common.collect.Lists.reverse;

/**
 * Created by vyakunin on 3/18/18.
 */

public class HistoryTextFragment extends Fragment implements MoodListener {
    public HistoryTextFragment() {
    }

    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        MainActivity mainActivity = (MainActivity)getActivity();
        DataController dataController = mainActivity.getDataController();
        dataController.addMoodListener(this);
        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment_history_text, container, false);
        renderLog(view, dataController.getMoodAdapter().getLogs());
        return view;
    }

    private void renderLog(View view, List<LogEntry> logs) {
        ListView table = view.findViewById(R.id.LOG_ENTRIES_CONTAINER);
        String[] smileys = new String[]{
                getResources().getString(R.string.smile0),
                getResources().getString(R.string.smile1),
                getResources().getString(R.string.smile2),
                getResources().getString(R.string.smile3),
                getResources().getString(R.string.smile4)};
        table.setAdapter(new TableRowAdapter(getContext(), R.layout.listview_item_row,
                         reverse(logs), smileys));
    }

    @Override
    public void refresh(List<LogEntry> entries) {
        renderLog(getView(), entries);
    }
}
