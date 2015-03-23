/*
 *    Copyright 2015 - The Skugga Project
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

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Toast;

import com.squareup.otto.Subscribe;

import fr.nlss.skugga.client.ClientHelper;
import fr.nlss.skugga.client.FileUploadClient;
import fr.nlss.skugga.event.DeleteRemoteFileEvent;
import fr.nlss.skugga.event.OpenRemoteFileEvent;
import fr.nlss.skugga.event.RefreshFileListEvent;
import fr.nlss.skugga.fragment.NavigationDrawerFragment;
import fr.nlss.skugga.model.RemoteFile;
import retrofit.RetrofitError;


public class FilesActivity extends ActionBarActivity
        implements NavigationDrawerFragment.NavigationDrawerCallbacks
{

    public static final int FILE_PICKER_REQUEST = 1;

    /**
     * Fragment managing the behaviors, interactions and presentation of the navigation drawer.
     */
    private NavigationDrawerFragment mNavigationDrawerFragment;

    /**
     * Used to store the last screen title. For use in {@link #restoreActionBar()}.
     */
    private CharSequence mTitle;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_files);

        mNavigationDrawerFragment = (NavigationDrawerFragment)
                getSupportFragmentManager().findFragmentById(R.id.navigation_drawer);
        mTitle = getTitle();

        // Set up the drawer.
        mNavigationDrawerFragment.setUp(
                R.id.navigation_drawer,
                (DrawerLayout) findViewById(R.id.drawer_layout));

        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        DrawerLayout drawerLayout = (DrawerLayout) findViewById(R.id.drawer_layout);
        drawerLayout.setStatusBarBackgroundColor(getResources().getColor(R.color.defaults_primary));


        SkuggaApplication.getBus().register(this);
    }

    @Override
    protected void onStart()
    {
        super.onStart();
        final String baseURL = SkuggaApplication.getBaseURL();
        if (baseURL == null || baseURL.isEmpty())
        {
            Toast.makeText(this, "Please configure a endpoint.", Toast.LENGTH_LONG).show();
            startActivity(new Intent(this, SettingsActivity.class));
        }
    }

    @Override
    protected void onDestroy()
    {
        SkuggaApplication.getBus().unregister(this);
        super.onDestroy();
    }

    @Override
    public void onNavigationDrawerItemSelected(int position)
    {
    }

    public void restoreActionBar()
    {
        ActionBar actionBar = getSupportActionBar();
        actionBar.setDisplayShowTitleEnabled(true);
        //actionBar.setDisplayHomeAsUpEnabled(true);
        actionBar.setTitle(mTitle);
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu)
    {
        if (!mNavigationDrawerFragment.isDrawerOpen())
        {
            // Only show items in the action bar relevant to this screen
            // if the drawer is not showing. Otherwise, let the drawer
            // decide what to show in the action bar.
            getMenuInflater().inflate(R.menu.files, menu);
            restoreActionBar();
            return true;
        }
        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item)
    {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings)
        {
            startActivity(new Intent(this, SettingsActivity.class));
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data)
    {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == FILE_PICKER_REQUEST && resultCode == RESULT_OK)
        {
            final Uri selectedFile = data.getData();
            new FileUploadClient.UploadUriTask().executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, selectedFile);
        }
    }

    @Subscribe
    public void openRemoteFile(OpenRemoteFileEvent event)
    {
        final Intent i = new Intent(Intent.ACTION_VIEW);
        i.setData(Uri.parse(event.file.getFullUrl()));
        startActivity(i);
    }

    @Subscribe
    public void deleteRemoteFile(final DeleteRemoteFileEvent event)
    {
        new AlertDialog.Builder(this)
                .setTitle("Delete " + event.file.filename + " ?")
                .setMessage("This action cannot be undone")
                .setPositiveButton(getString(R.string.delete), new DialogInterface.OnClickListener()
                {
                    @Override
                    public void onClick(DialogInterface dialog, int which)
                    {
                        new DeleteFileTask().execute(event.file);
                    }
                })
                .setNegativeButton(getString(R.string.cancel), null)
                .show();
    }

    private class DeleteFileTask extends AsyncTask<RemoteFile, Void, String>
    {
        @Override
        protected String doInBackground(RemoteFile... files)
        {
            try
            {
                ClientHelper.getFileListClient().delete(files[0].url, files[0].deleteKey);
                return "ok";
            }
            catch (RetrofitError e)
            {
                if (e.getKind() == RetrofitError.Kind.CONVERSION)
                {
                    // The response can't really be parsed, so ignore this error
                    return "ok";
                }

                Log.e(this.getClass().getName(), "Network Error : " + e.getKind().toString());
                if (e.getCause() != null)
                {
                    e.getCause().printStackTrace();
                }
                return null;
            }
        }

        @Override
        protected void onPostExecute(String result)
        {
            super.onPostExecute(result);
            if (result == null)
            {
                Toast.makeText(FilesActivity.this, "Error while deleting the file", Toast.LENGTH_SHORT).show();
            } else
            {
                SkuggaApplication.getBus().post(new RefreshFileListEvent());
            }
        }
    }
}
