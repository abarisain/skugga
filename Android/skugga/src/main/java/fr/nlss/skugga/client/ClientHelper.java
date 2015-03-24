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
import com.squareup.okhttp.OkHttpClient;

import java.security.cert.CertificateException;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.SSLSocketFactory;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

import fr.nlss.skugga.SkuggaApplication;
import retrofit.RestAdapter;
import retrofit.client.OkClient;
import retrofit.converter.GsonConverter;

public abstract class ClientHelper
{

    public static RestAdapter getRestAdapter()
    {
        final Gson gson = new GsonBuilder()
                .setDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
                .create();

        final RestAdapter.Builder builder = new RestAdapter.Builder()
                .setEndpoint(SkuggaApplication.getBaseURL())
                .setRequestInterceptor(new ClientRequestInterceptor())
                .setConverter(new GsonConverter(gson));

        if (SkuggaApplication.getInstance().useInsecureSSL())
        {
            builder.setClient(new OkClient(getUnsafeOkHttpClient()));
        }

        return builder.build();
    }

    public static FileListClient getFileListClient()
    {
        return getRestAdapter().create(FileListClient.class);
    }

    // Thanks StackOverflow! http://stackoverflow.com/questions/25509296/trusting-all-certificates-with-okhttp
    // Also, don't use this. Really.
    public static OkHttpClient getUnsafeOkHttpClient()
    {
        try
        {
            // Create a trust manager that does not validate certificate chains
            final TrustManager[] trustAllCerts = new TrustManager[]{
                    new X509TrustManager()
                    {
                        @Override
                        public void checkClientTrusted(java.security.cert.X509Certificate[] chain, String authType) throws CertificateException
                        {
                        }

                        @Override
                        public void checkServerTrusted(java.security.cert.X509Certificate[] chain, String authType) throws CertificateException
                        {
                        }

                        @Override
                        public java.security.cert.X509Certificate[] getAcceptedIssuers()
                        {
                            return null;
                        }
                    }
            };

            // Install the all-trusting trust manager
            final SSLContext sslContext = SSLContext.getInstance("SSL");
            sslContext.init(null, trustAllCerts, new java.security.SecureRandom());
            // Create an ssl socket factory with our all-trusting manager
            final SSLSocketFactory sslSocketFactory = sslContext.getSocketFactory();

            OkHttpClient okHttpClient = new OkHttpClient();
            okHttpClient.setSslSocketFactory(sslSocketFactory);
            okHttpClient.setHostnameVerifier(new HostnameVerifier()
            {
                @Override
                public boolean verify(String hostname, SSLSession session)
                {
                    return true;
                }
            });

            return okHttpClient;
        }
        catch (Exception e)
        {
            throw new RuntimeException(e);
        }
    }
}
