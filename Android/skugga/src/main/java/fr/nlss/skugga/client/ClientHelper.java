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

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import fr.nlss.skugga.SkuggaApplication;
import retrofit.RestAdapter;
import retrofit.converter.GsonConverter;

public abstract class ClientHelper
{

    public static RestAdapter getRestAdapter()
    {
        final Gson gson = new GsonBuilder()
                .setDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
                .create();

        return new RestAdapter.Builder()
                .setEndpoint(SkuggaApplication.getBaseURL())
                .setRequestInterceptor(new ClientRequestInterceptor())
                .setConverter(new GsonConverter(gson))
                .build();
    }

    public static FileListClient getFileListClient()
    {
        return getRestAdapter().create(FileListClient.class);
    }
}
