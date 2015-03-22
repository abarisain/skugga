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

package fr.nlss.skugga.client;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.AsyncTask;
import android.support.v4.app.NotificationCompat;
import android.support.v4.app.NotificationManagerCompat;

import com.squareup.okhttp.MediaType;
import com.squareup.okhttp.MultipartBuilder;
import com.squareup.okhttp.OkHttpClient;
import com.squareup.okhttp.Request;
import com.squareup.okhttp.RequestBody;
import com.squareup.okhttp.Response;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.util.Date;

import fr.nlss.skugga.FilesActivity;
import fr.nlss.skugga.R;
import fr.nlss.skugga.SkuggaApplication;
import fr.nlss.skugga.event.RefreshFileListEvent;

public class FileUploadClient
{
    private byte[] uriToJpeg(Context context, Uri uri) throws FileNotFoundException
    {
        ContentResolver resolver = context.getContentResolver();
        InputStream fis = resolver.openInputStream(uri);
        BitmapFactory.Options options = new BitmapFactory.Options();
        final Bitmap bitmap = BitmapFactory.decodeStream(fis, null, options);

        ByteArrayOutputStream compressedBitmapOS = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.JPEG, 100, compressedBitmapOS);
        return compressedBitmapOS.toByteArray();
    }

    public void uploadUri(Context context, Uri uri)
    {
        final byte[] imageData;
        try
        {
            imageData = uriToJpeg(context, uri);
        }
        catch (FileNotFoundException e)
        {
            e.printStackTrace();
            return;
        }
        RequestBody requestBody = new MultipartBuilder()
                .type(MultipartBuilder.FORM)
                .addFormDataPart("data", "android_upload.jpg", RequestBody.create(MediaType.parse("image/jpeg"), imageData))
                .build();

        Request.Builder builder = new Request.Builder();
        final String secret = SkuggaApplication.getSecret();
        if (secret != null && !secret.isEmpty())
        {
            builder.addHeader(ClientRequestInterceptor.SECRET_KEY_HEADER, secret);
        }
        Request request = builder.url(SkuggaApplication.getBaseURL() + "/1.0/send?name=android_upload.jpg")
            .post(requestBody)
            .build();

        Response response = null;
        try
        {
            response = new OkHttpClient().newCall(request).execute();
            /*if (response.isSuccessful())
            {
                SkuggaApplication.getBus().post(new RefreshFileListEvent());
            }*/
            if (!response.isSuccessful()) throw new IOException("Unexpected code " + response);
            System.out.println("ok");
            return;
        }
        catch (IOException e)
        {
            e.printStackTrace();
        }
    }

    // Async Task that shows a notification and fires a "UploadFinished" event
    public static class UploadUriTask extends AsyncTask<Uri, Void, Boolean>
    {
        private int notificationId;

        @Override
        protected void onPreExecute()
        {
            super.onPreExecute();
            final Context c = SkuggaApplication.getInstance();

            final Intent intent = new Intent(c, FilesActivity.class);
            final PendingIntent pendingIntent = PendingIntent.getActivity(c, 0, intent,
                            PendingIntent.FLAG_UPDATE_CURRENT);

            NotificationCompat.Builder builder = new NotificationCompat.Builder(c);

            builder.setProgress(0, 0, true)
                    .setSmallIcon(R.drawable.ic_content_add)
                    .setContentTitle(c.getString(R.string.app_name))
                    .setContentText(c.getString(R.string.uploading))
                    .setOngoing(true)
                    .setContentIntent(pendingIntent);

            Notification notification = builder.build();

            // Build a notification ID based on the date
            notificationId = (int) (new Date().getTime() / 100000);

            NotificationManagerCompat.from(c).notify(notificationId, notification);
        }

        @Override
        protected Boolean doInBackground(Uri... uris)
        {
            new FileUploadClient().uploadUri(SkuggaApplication.getInstance(), uris[0]);
            return true;
        }

        @Override
        protected void onPostExecute(Boolean result)
        {
            super.onPostExecute(result);
            final Context c = SkuggaApplication.getInstance();

            final Intent intent = new Intent(c, FilesActivity.class);
            final PendingIntent pendingIntent = PendingIntent.getActivity(c, 0, intent,
                    PendingIntent.FLAG_UPDATE_CURRENT);

            NotificationCompat.Builder builder = new NotificationCompat.Builder(c);

            builder.setSmallIcon(R.drawable.ic_content_add)
                    .setContentTitle(c.getString(R.string.app_name))
                    .setContentText("File uploaded:\n"+"https://c.arnaud.moe/qoskdoqdk")
                    .setOngoing(false)
                    .addAction(0, "Open", pendingIntent)
                    .addAction(0, "Copy", pendingIntent)
                    .setContentIntent(pendingIntent)
                    .setPriority(NotificationCompat.PRIORITY_HIGH);

            Notification notification = builder.build();

            NotificationManagerCompat.from(c).notify(notificationId, notification);
        }
    }
}
