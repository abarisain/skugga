/*
 * Copyright 2015 - The Skugga Project
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

package fr.nlss.skugga;

import android.app.Application;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.preference.PreferenceManager;

import com.squareup.otto.Bus;
import com.squareup.otto.Subscribe;

import fr.nlss.skugga.event.OpenRemoteFileEvent;

public class SkuggaApplication extends Application implements SharedPreferences.OnSharedPreferenceChangeListener
{

    private static SkuggaApplication instance;

    private static String prefBaseURL;
    private static String prefSecret;
    private static Bus eventBus;

    public static SkuggaApplication getInstance()
    {
        return instance;
    }

    @Override
    public void onCreate()
    {
        super.onCreate();
        instance = this;
        PreferenceManager.setDefaultValues(this, R.xml.pref_general, false);
        PreferenceManager.getDefaultSharedPreferences(this).registerOnSharedPreferenceChangeListener(this);
        refreshPreferences();
        eventBus = new Bus();
    }

    public static String getBaseURL()
    {
        return prefBaseURL;
    }

    public static String getSecret()
    {
        return prefSecret;
    }

    public static Bus getBus()
    {
        return eventBus;
    }

    @Override
    public void onSharedPreferenceChanged(SharedPreferences sharedPreferences, String s)
    {
        refreshPreferences();
    }

    private void refreshPreferences()
    {
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(this);
        prefBaseURL = prefs.getString("server_endpoint", "");
        prefSecret = prefs.getString("server_secret", null);
    }
}