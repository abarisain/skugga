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

package fr.nlss.skugga.ui.list;

import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.PopupMenu;
import android.widget.TextView;
import android.widget.Toast;

import com.squareup.picasso.Picasso;

import java.util.List;

import fr.nlss.skugga.R;
import fr.nlss.skugga.SkuggaApplication;
import fr.nlss.skugga.event.DeleteRemoteFileEvent;
import fr.nlss.skugga.event.OpenRemoteFileEvent;
import fr.nlss.skugga.model.RemoteFile;

public class FileListAdapter extends RecyclerView.Adapter<FileListAdapter.FileListCardViewHolder>
{

    private List<RemoteFile> data;

    public FileListAdapter(List<RemoteFile> files)
    {
        super();
        data = files;
    }

    @Override
    public FileListCardViewHolder onCreateViewHolder(ViewGroup parent, int viewType)
    {
        return new FileListCardViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.file_item, parent, false));
    }

    @Override
    public void onBindViewHolder(FileListCardViewHolder fileListCardViewHolder, int position)
    {
        RemoteFile file = data.get(position);
        fileListCardViewHolder.file = file;
        fileListCardViewHolder.title.setText(file.filename != null ? file.filename :
                fileListCardViewHolder.title.getContext().getString(R.string.no_filename));
        fileListCardViewHolder.subtitle.setText(file.getHumanReadableTimestamp());
        fileListCardViewHolder.extension.setText(file.getExtension().toUpperCase());


        int imageHeight = fileListCardViewHolder.thumbnail.getHeight();
        if (imageHeight == 0)
        {
            imageHeight = 256;
        }

        Picasso.with(fileListCardViewHolder.thumbnail.getContext())
                .load(file.getFullUrl() + "?w=0&h=" + imageHeight)
                .into(fileListCardViewHolder.thumbnail);
    }

    @Override
    public int getItemCount()
    {
        return data.size();
    }

    public static class FileListCardViewHolder extends RecyclerView.ViewHolder implements PopupMenu.OnMenuItemClickListener
    {

        public ImageView thumbnail;
        public TextView title;
        public TextView subtitle;
        public TextView extension;

        public RemoteFile file;

        public FileListCardViewHolder(final View v)
        {
            super(v);
            thumbnail = (ImageView) v.findViewById(R.id.thumbnailView);
            title = (TextView) v.findViewById(R.id.titleView);
            subtitle = (TextView) v.findViewById(R.id.subtitleView);
            extension = (TextView) v.findViewById(R.id.extensionTextView);

            v.setOnClickListener(new View.OnClickListener()
            {
                @Override
                public void onClick(View view)
                {
                    SkuggaApplication.getBus().post(new OpenRemoteFileEvent(file));
                }
            });

            v.setOnLongClickListener(new View.OnLongClickListener()
            {
                @Override
                public boolean onLongClick(View view)
                {
                    final PopupMenu popup = new PopupMenu(view.getContext(), view);
                    MenuInflater inflater = popup.getMenuInflater();
                    inflater.inflate(R.menu.file_popup, popup.getMenu());
                    popup.setOnMenuItemClickListener(FileListCardViewHolder.this);
                    popup.show();
                    return true;
                }
            });
        }

        @Override
        public boolean onMenuItemClick(MenuItem menuItem)
        {
            switch (menuItem.getItemId())
            {
                case R.id.action_open:
                    SkuggaApplication.getBus().post(new OpenRemoteFileEvent(file));
                    return true;
                case R.id.action_copy:
                    ClipboardManager clipboard = (ClipboardManager) SkuggaApplication.getInstance()
                            .getSystemService(Context.CLIPBOARD_SERVICE);
                    clipboard.setPrimaryClip(ClipData.newPlainText("Skugga File URL", file.getFullUrl()));
                    return true;
                case R.id.action_delete:
                    SkuggaApplication.getBus().post(new DeleteRemoteFileEvent(file));
                    return true;
            }
            return false;
        }
    }
}
