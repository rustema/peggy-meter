package io.peggyjo.peggymeter;


import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.TextView;

import java.util.Calendar;

/**
 * A simple {@link Fragment} subclass.
 */
public class MoodControlFragment extends Fragment implements View.OnClickListener {
    private final int[] buttonIds = {
            R.id.mood0, R.id.mood1, R.id.mood2,
            R.id.mood3, R.id.mood4, R.id.mood5,
            R.id.mood6, R.id.mood7, R.id.mood8, R.id.mood9};

    public MoodControlFragment() {
        // Required empty public constructor
    }


    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View v = inflater.inflate(R.layout.fragment_mood_control, container, false);

        //
        for (int buttonId : buttonIds) {
            Button b = v.findViewById(buttonId);
            b.setOnClickListener(this);
        }
        return v;
    }

    public void onClick(View view) {
        Button b = (Button)view;
        int mood = -1;
        for (int i = 0; i < buttonIds.length; i++) {
            if (buttonIds[i] == b.getId()) {
              mood = i;
              break;
            }
        }

        MainActivity mainActivity = (MainActivity)getActivity();
        TextView commentView = getView().findViewById(R.id.mood_comment);
        LogEntry entry = new LogEntry(Calendar.getInstance().getTime(), mood,
                commentView.getText().toString());
        commentView.setText("");
        InputMethodManager imm = (InputMethodManager)mainActivity.getSystemService(
                Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(commentView.getWindowToken(), 0);
        mainActivity.getDataController().addEntry(entry);

                // intentservice (separate background thread ) or async task
        //Log.d("MoodControlFragment -->", "" + b.getId());
    }
}
