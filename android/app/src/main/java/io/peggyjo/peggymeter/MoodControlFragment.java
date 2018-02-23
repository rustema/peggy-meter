package io.peggyjo.peggymeter;


import android.os.Bundle;
import android.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.Toast;


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
        for (int i = 0; i < buttonIds.length; ++i) {
            Button b = v.findViewById(buttonIds[i]);
            b.setOnClickListener(this);
        }
        return v;
    }

    public void onClick(View view) {
        Button b = (Button)view;
        //Log.d("MoodControlFragment -->", "" + b.getId());
        Toast.makeText(getActivity(), "clicked " + b.getId(), Toast.LENGTH_LONG).show();
        //toast(ge)
    }
}
