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

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.PowerManager;

import fr.nlss.skugga.service.UploadService;


/**
 * Android requires that the share intent is sent to an activity, so use a transparent one
 * which finishes before it is even shown.
 */
public class DummyShareActivity extends Activity
{

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_dummy_share);

        // Get intent, action and MIME type
        Intent intent = getIntent();
        String action = intent.getAction();
        String type = intent.getType();

        if (Intent.ACTION_SEND.equals(action) && type != null && type.startsWith("image/")) {
            Uri imageUri = intent.getParcelableExtra(Intent.EXTRA_STREAM);
            if (imageUri != null)
            {
                boolean powerSavingMode = false;
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
                {
                    powerSavingMode = ((PowerManager)getSystemService(POWER_SERVICE)).isPowerSaveMode();
                }

                if (powerSavingMode)
                {
                    Intent i = new Intent(this, PowerSaveUploadActivity.class);
                    i.putExtra(Intent.EXTRA_STREAM, imageUri);
                    startActivity(i);
                }
                else
                {
                    UploadService.startUploadAction(this, imageUri);
                }
            }
        }

        finish();
    }
}
