package io.peggyjo.peggymeter;


import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.speech.SpeechRecognizer;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.TextView;

import java.util.Calendar;

import static android.Manifest.permission.RECORD_AUDIO;
import static android.support.v4.content.PermissionChecker.checkCallingOrSelfPermission;
/**
 * A simple {@link Fragment} subclass.
 */
public class MoodControlFragment extends Fragment implements View.OnClickListener {
    private final int[] buttonIds = {
            R.id.mood0, R.id.mood1, R.id.mood2,
            R.id.mood3, R.id.mood4};
    private SpeechRecognizer speechRecognizer;

    public MoodControlFragment() {
        // Required empty public constructor
    }


    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View v = inflater.inflate(R.layout.fragment_mood_control, container, false);
//        speechRecognizer = SpeechRecognizer.createSpeechRecognizer(getActivity());
//        speechRecognizer.setRecognitionListener(new MoodRecognitionListener(v,
//                (TextView) v.findViewById(R.id.mood_comment)));

        //
        for (int buttonId : buttonIds) {
            Button b = v.findViewById(buttonId);
            b.setOnClickListener(this);
        }
//        View micButton = v.findViewById(R.id.mic_button);
//        micButton.setOnClickListener(this);
        return v;
    }

    public void onClick(View view) {
//        if (view.getId() == R.id.mic_button) {
//            recordVoice();
//            return;
//        }
        Button b = (Button)view;
        int mood = -1;
        for (int i = 0; i < buttonIds.length; i++) {
            if (buttonIds[i] == b.getId()) {
                mood = i;
                break;
            }
        }

        if (mood == -1) {
            return;
        }

        MainActivity mainActivity = (MainActivity)getActivity();
        TextView commentView = getView().findViewById(R.id.mood_comment);
        LogEntry entry = new LogEntry(Calendar.getInstance().getTime(), mood,
                commentView.getText().toString());
        commentView.setText("");
        InputMethodManager imm = (InputMethodManager)mainActivity.getSystemService(
                Context.INPUT_METHOD_SERVICE);
        if (imm != null) {
            imm.hideSoftInputFromWindow(commentView.getWindowToken(), 0);
        }
        mainActivity.getDataController().addEntry(entry);

                // intentservice (separate background thread ) or async task
        //Log.d("MoodControlFragment -->", "" + b.getId());
    }

    private void requestRecordAudioPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            String requiredPermission = RECORD_AUDIO;

            // If the user previously denied this permission then show a message explaining why
            // this permission is needed
            if (checkCallingOrSelfPermission(getActivity(), requiredPermission) ==
                    PackageManager.PERMISSION_DENIED) {
                requestPermissions(new String[]{requiredPermission}, 101);
            }
        }
    }

    private void onRecordingActive(View fragment) {
        fragment.setEnabled(false);
        //fragment.findViewById(R.id.mic_button).setT
    }

    private void recordVoice() {
        requestRecordAudioPermission();
//        Intent intent = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);
//        speechRecognizer.startListening(intent);
    }

//    private class MoodRecognitionListener implements RecognitionListener {
//        private View fragmentView;
//        private TextView output;
//
//        MoodRecognitionListener(View fragmentView, TextView output) {
//            this.fragmentView = fragmentView;
//            this.output = output;
//        }
//
//        public void onReadyForSpeech(Bundle params)
//        {
//            Log.d(TAG, "onReadyForSpeech");
//        }
//        public void onBeginningOfSpeech()
//        {
//            Log.d(TAG, "onBeginningOfSpeech");
//        }
//        public void onRmsChanged(float rmsdB)
//        {
//            Log.d(TAG, "onRmsChanged");
//        }
//        public void onBufferReceived(byte[] buffer)
//        {
//            Log.d(TAG, "onBufferReceived");
//        }
//        public void onEndOfSpeech()
//        {
//            fragmentView.setEnabled(true);
//            Log.d(TAG, "onEndofSpeech");
//        }
//        public void onError(int error)
//        {
//            fragmentView.setEnabled(true);
//            Log.d(TAG,  "error " +  error);
//        }
//        public void onPartialResults(Bundle partialResults)
//        {
//            Log.d(TAG, "onPartialResults");
//        }
//        public void onEvent(int eventType, Bundle params)
//        {
//            Log.d(TAG, "onEvent " + eventType);
//        }
//        @Override
//        public void onResults(Bundle results) {
//            fragmentView.setEnabled(true);
//            List<String> words = results.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION);
//            if (words == null || words.isEmpty()) {
//                return;
//            }
//            // Only use the top recognition.
//            output.setText(words.get(0));
//        }
//    }
}
