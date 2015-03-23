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

import android.content.BroadcastReceiver;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.widget.Toast;

public class CopyUrlBrodcastReceiver extends BroadcastReceiver
{
    public static final String ACTION_COPY_URL = "fr.nlss.skugga.ACTION_COPY_URL";
    public static final String EXTRA_URL = "url";

    public CopyUrlBrodcastReceiver()
    {
    }

    @Override
    public void onReceive(Context context, Intent intent)
    {
        if (intent != null && ACTION_COPY_URL.equals(intent.getAction()))
        {
            ClipboardManager clipboard = (ClipboardManager) SkuggaApplication.getInstance()
                    .getSystemService(Context.CLIPBOARD_SERVICE);
            clipboard.setPrimaryClip(ClipData.newPlainText("Skugga File URL", intent.getStringExtra(EXTRA_URL)));
            Toast.makeText(context, context.getString(R.string.copy_toast), Toast.LENGTH_SHORT).show();
        }
    }
}
