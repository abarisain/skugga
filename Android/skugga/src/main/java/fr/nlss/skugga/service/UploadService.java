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

package fr.nlss.skugga.service;

import android.app.IntentService;
import android.app.Notification;
import android.app.PendingIntent;
import android.content.Intent;
import android.content.Context;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.support.v4.app.NotificationCompat;
import android.support.v4.app.NotificationManagerCompat;

import java.util.Date;

import fr.nlss.skugga.CopyUrlBrodcastReceiver;
import fr.nlss.skugga.FilesActivity;
import fr.nlss.skugga.R;
import fr.nlss.skugga.SkuggaApplication;
import fr.nlss.skugga.client.FileUploadClient;
import fr.nlss.skugga.event.UploadFinishedEvent;
import fr.nlss.skugga.model.RemoteFile;

public class UploadService extends IntentService
{
    private static final String ACTION_UPLOAD = "fr.nlss.skugga.service.action.UPLOAD";

    private static final String EXTRA_IMAGE_URI = "fr.nlss.skugga.service.extra.IMAGE_URI";

    public static void startUploadAction(Context context, Uri uri)
    {
        Intent intent = new Intent(context, UploadService.class);
        intent.setAction(ACTION_UPLOAD);
        intent.putExtra(EXTRA_IMAGE_URI, uri);
        context.startService(intent);
    }

    public UploadService()
    {
        super("UploadService");
    }

    @Override
    protected void onHandleIntent(Intent intent)
    {
        if (intent != null)
        {
            final String action = intent.getAction();
            if (ACTION_UPLOAD.equals(action))
            {
                final Uri uri = intent.getParcelableExtra(EXTRA_IMAGE_URI);
                handleUploadAction(uri);
            }
        }
    }

    private void handleUploadAction(Uri uri)
    {
        final Context context = SkuggaApplication.getInstance();
        // Build a notification ID based on the date
        int notificationId = (int) (new Date().getTime() / 100000);

        showUploadingNotification(context, notificationId);

        String url = new FileUploadClient().uploadUri(context, uri);
        if (url != null)
        {
            url = RemoteFile.getFullUrlForKey(url);
        }

        // Make a final copy for the inner class
        final String fullURL = url;

        showResultNotification(context, notificationId, url);

        // Get the main thread
        final Handler mainHandler = new Handler(Looper.getMainLooper());
        mainHandler.post(new Runnable()
        {
            @Override
            public void run()
            {
                UploadFinishedEvent event;
                if (fullURL != null)
                {
                    event = new UploadFinishedEvent(fullURL);
                }
                else
                {
                    event = new UploadFinishedEvent(true);
                }

                SkuggaApplication.getBus().post(event);
            }
        });
    }

    private void showUploadingNotification(Context context, int notificationId)
    {
        final Intent intent = new Intent(context, FilesActivity.class);
        final PendingIntent pendingIntent = PendingIntent.getActivity(context, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT);

        NotificationCompat.Builder builder = new NotificationCompat.Builder(context);

        builder.setProgress(0, 0, true)
                .setSmallIcon(R.drawable.ic_notif_upload)
                .setContentTitle(context.getString(R.string.app_name))
                .setContentText(context.getString(R.string.uploading))
                .setOngoing(true)
                .setContentIntent(pendingIntent);

        Notification notification = builder.build();
        NotificationManagerCompat.from(context).notify(notificationId, notification);
    }

    private void showResultNotification(Context context, int notificationId, String url)
    {
        final Intent intent = new Intent(context, FilesActivity.class);
        final PendingIntent pendingIntent = PendingIntent.getActivity(context, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT);

        NotificationCompat.Builder builder = new NotificationCompat.Builder(context);

        if (url != null)
        {
            final PendingIntent openIntent = PendingIntent.getActivity(context, 0, new Intent(Intent.ACTION_VIEW, Uri.parse(url)), 0);

            Intent copyIntent = new Intent(CopyUrlBrodcastReceiver.ACTION_COPY_URL);
            copyIntent.putExtra(CopyUrlBrodcastReceiver.EXTRA_URL, url);
            PendingIntent copyPendingIntent = PendingIntent.getBroadcast(context, 0, copyIntent, 0);

            builder.setSmallIcon(R.drawable.ic_notif_upload_done)
                    .setDefaults(NotificationCompat.DEFAULT_ALL)
                    .setContentTitle(context.getString(R.string.app_name))
                    .setContentText(context.getString(R.string.notif_upload_success) + url)
                    .setOngoing(false)
                    .addAction(R.drawable.ic_notif_cta_open, context.getString(R.string.notif_cta_open), openIntent)
                    .addAction(R.drawable.ic_notif_cta_share, context.getString(R.string.notif_cta_copy), copyPendingIntent)
                    .setContentIntent(pendingIntent);

            if (SkuggaApplication.getInstance().useNotifHighPriority())
            {
                builder.setPriority(NotificationCompat.PRIORITY_HIGH);
            }
        }
        else
        {
            builder.setSmallIcon(R.drawable.ic_notif_upload_fail)
                    .setDefaults(NotificationCompat.DEFAULT_ALL)
                    .setContentTitle(context.getString(R.string.app_name))
                    .setContentText(context.getString(R.string.notif_upload_failed))
                    .setOngoing(false)
                    .setContentIntent(pendingIntent);

            if (SkuggaApplication.getInstance().useNotifHighPriority())
            {
                builder.setPriority(NotificationCompat.PRIORITY_HIGH);
            }
        }

        Notification notification = builder.build();

        final NotificationManagerCompat notificationManager = NotificationManagerCompat.from(context);
        notificationManager.cancel(notificationId);
        notificationManager.notify(notificationId, notification);
    }
}
