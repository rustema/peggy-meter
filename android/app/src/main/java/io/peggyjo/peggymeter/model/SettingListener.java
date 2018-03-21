package io.peggyjo.peggymeter.model;

import java.util.Map;

/**
 * Created by demetr on 3/20/18.
 */
public interface SettingListener {
    void onSettingUpdate(Map<String, Object> setting);
}
