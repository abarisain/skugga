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

package fr.nlss.skugga.fragment;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v4.app.Fragment;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.Toast;

import com.melnykov.fab.FloatingActionButton;
import com.squareup.otto.Subscribe;

import java.util.ArrayList;
import java.util.List;

import fr.nlss.skugga.FilesActivity;
import fr.nlss.skugga.R;
import fr.nlss.skugga.SkuggaApplication;
import fr.nlss.skugga.client.ClientHelper;
import fr.nlss.skugga.event.RefreshFileListEvent;
import fr.nlss.skugga.ui.list.FileListAdapter;
import fr.nlss.skugga.model.RemoteFile;
import retrofit.RetrofitError;

public class FileListFragment extends Fragment
{
    private ViewGroup rootView;
    private RecyclerView filesRecyclerView;
    private View toolbarBackgroundOverflowView;
    private SwipeRefreshLayout swipeRefreshView;

    private FileListAdapter adapter;
    private List<RemoteFile> files;

    public FileListFragment()
    {
        files = new ArrayList<>();
        adapter = new FileListAdapter(files);
    }

    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        SkuggaApplication.getBus().register(this);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState)
    {
        rootView = (FrameLayout) inflater.inflate(R.layout.fragment_files, container, false);

        swipeRefreshView = (SwipeRefreshLayout) rootView.findViewById(R.id.swipeRefreshView);
        swipeRefreshView.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener()
        {
            @Override
            public void onRefresh()
            {
                refreshFileList();
            }
        });

        filesRecyclerView = (RecyclerView) rootView.findViewById(R.id.filesRecyclerView);
        toolbarBackgroundOverflowView = rootView.findViewById(R.id.toolbarBackgroundOverflowView);

        filesRecyclerView.setLayoutManager(new GridLayoutManager(getActivity(), 2));
        filesRecyclerView.setAdapter(adapter);

        FloatingActionButton fab = (FloatingActionButton) rootView.findViewById(R.id.fab);
        fab.attachToRecyclerView(filesRecyclerView, null, new RecyclerView.OnScrollListener()
        {
            private float computedY = 0;

            @Override
            public void onScrolled(RecyclerView recyclerView, int dx, int dy)
            {
                computedY += dy;
                toolbarBackgroundOverflowView.setTranslationY(Math.max(-computedY, -toolbarBackgroundOverflowView.getHeight()));
            }
        });
        fab.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View view)
            {
                SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(SkuggaApplication.getInstance());
                boolean imageOnly = prefs.getBoolean("ui_restrict_image", true);

                Intent intent = new Intent();
                intent.setType(imageOnly ? "image/*" : "*/*");
                intent.setAction(Intent.ACTION_GET_CONTENT);
                getActivity().startActivityForResult(Intent.createChooser(intent, view.getContext().getString(R.string.select_file_to_upload)), FilesActivity.FILE_PICKER_REQUEST);
            }
        });

        return rootView;
    }

    @Override
    public void onStart()
    {
        super.onStart();
        refreshFileList();
    }

    @Override
    public void onDestroy()
    {
        SkuggaApplication.getBus().unregister(this);
        super.onDestroy();
    }

    @Subscribe
    public void refreshFileList(RefreshFileListEvent e)
    {
        refreshFileList();
    }

    private void refreshFileList()
    {
        final String baseURL = SkuggaApplication.getBaseURL();
        if (baseURL == null || baseURL.isEmpty())
        {
            return;
        }
        swipeRefreshView.setRefreshing(true);
        new RefreshFileListTask().execute();
    }

    private class RefreshFileListTask extends AsyncTask<Void, Void, List<RemoteFile>>
    {
        @Override
        protected List<RemoteFile> doInBackground(Void... voids)
        {
            try
            {
                return ClientHelper.getFileListClient().getFileList();
            }
            catch (RetrofitError e)
            {
                Log.e(this.getClass().getName(), "Network Error : " + e.getKind().toString());
                if (e.getCause() != null)
                {
                    e.getCause().printStackTrace();
                }
                return null;
            }
        }

        @Override
        protected void onPostExecute(List<RemoteFile> remoteFiles)
        {
            super.onPostExecute(remoteFiles);
            synchronized (files)
            {
                if (remoteFiles != null)
                {
                    files.clear();
                    files.addAll(remoteFiles);
                }
                else
                {
                    Toast.makeText(getActivity(), "Error while refreshing file list.", Toast.LENGTH_SHORT).show();
                }
            }
            if (rootView != null)
            {
                swipeRefreshView.setRefreshing(false);
                adapter.notifyDataSetChanged();
            }
        }
    }
}