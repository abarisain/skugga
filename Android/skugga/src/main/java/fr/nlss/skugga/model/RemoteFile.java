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

package fr.nlss.skugga.model;

import com.google.gson.annotations.SerializedName;

import org.ocpsoft.prettytime.PrettyTime;

import java.util.Date;

import fr.nlss.skugga.SkuggaApplication;

public class RemoteFile
{
    private PrettyTime prettyTime = new PrettyTime();

    @SerializedName("name")
    public String url;

    @SerializedName("original")
    public String filename;

    @SerializedName("creation_time")
    public Date timestamp;

    @SerializedName("delete_key")
    public String deleteKey;

    public String getHumanReadableTimestamp()
    {
        return prettyTime.format(timestamp != null ? timestamp : new Date());
    }

    public String getExtension()
    {
        int i = filename.lastIndexOf('.');
        if (i > 0)
        {
            return filename.substring(i);
        }
        return "";
    }

    public String getFullUrl()
    {
        return getFullUrlForKey(url);
    }

    public static String getFullUrlForKey(String url)
    {
        return SkuggaApplication.getBaseURL() + "/" + url;
    }
}
