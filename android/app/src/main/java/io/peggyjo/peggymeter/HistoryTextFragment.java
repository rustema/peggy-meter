package io.peggyjo.peggymeter;

import android.support.v4.app.Fragment;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TableLayout;
import android.widget.TableRow;
import android.widget.TextView;

import org.w3c.dom.Text;

import java.text.SimpleDateFormat;
import java.util.Collections;
import java.util.List;
import java.util.Locale;

import static com.google.common.collect.Lists.reverse;

/**
 * Created by vyakunin on 3/18/18.
 */

public class HistoryTextFragment extends Fragment implements HistoryView {
    public HistoryTextFragment() {
    }

    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        MainActivity mainActivity = (MainActivity)getActivity();
        DataController dataController = mainActivity.getDataController();
        dataController.setHistoryView(this);
        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment_history_text, container, false);
        renderLog(view, dataController.getLogs());
        return view;
    }

    private void renderLog(View view, List<LogEntry> logs) {
        ListView table = view.findViewById(R.id.LOG_ENTRIES_CONTAINER);
        table.setAdapter(new TableRowAdapter(getContext(), R.layout.listview_item_row, reverse(logs)));
    }

    @Override
    public void refresh(List<LogEntry> entries) {
        renderLog(getView(), entries);
    }
}
