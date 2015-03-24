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

import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.squareup.okhttp.MediaType;
import com.squareup.okhttp.MultipartBuilder;
import com.squareup.okhttp.OkHttpClient;
import com.squareup.okhttp.Request;
import com.squareup.okhttp.RequestBody;
import com.squareup.okhttp.Response;

import java.io.ByteArrayOutputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.util.Date;

import fr.nlss.skugga.CopyUrlBrodcastReceiver;
import fr.nlss.skugga.FilesActivity;
import fr.nlss.skugga.R;
import fr.nlss.skugga.SkuggaApplication;
import fr.nlss.skugga.event.UploadFinishedEvent;
import fr.nlss.skugga.model.RemoteFile;

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
        byte[] compressedBitmap = compressedBitmapOS.toByteArray();
        bitmap.recycle();
        return compressedBitmap;
    }

    public String uploadUri(Context context, Uri uri)
    {
        final byte[] imageData;
        try
        {
            imageData = uriToJpeg(context, uri);
        }
        catch (FileNotFoundException e)
        {
            e.printStackTrace();
            return null;
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

        Response response;
        try
        {
            OkHttpClient client;
            if (SkuggaApplication.getInstance().useInsecureSSL())
            {
                client = ClientHelper.getUnsafeOkHttpClient();
            }
            else
            {
                client = new OkHttpClient();
            }
            response = client.newCall(request).execute();

            if (response.isSuccessful())
            {
                final String body = response.body().string();
                return new Gson().fromJson(body, JsonObject.class).get("name").getAsString();
            }
        }
        catch (IOException | NullPointerException e)
        {
            e.printStackTrace();
        }

        return null;
    }
}
