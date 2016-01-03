package fr.nlss.skugga;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.View;

import com.squareup.otto.Subscribe;

import fr.nlss.skugga.event.UploadFinishedEvent;
import fr.nlss.skugga.service.UploadService;

public class PowerSaveUploadActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_power_save_upload);

        SkuggaApplication.getBus().register(this);

        Uri imageUri = getIntent().getParcelableExtra(Intent.EXTRA_STREAM);
        if (imageUri != null)
        {
            UploadService.startUploadAction(this, imageUri);
        }
        else
        {
            finish();
        }
    }

    @Override
    protected void onDestroy()
    {
        SkuggaApplication.getBus().unregister(this);
        super.onDestroy();
    }

    @Subscribe
    public void onUploadFinished(final UploadFinishedEvent e)
    {
        finish();
    }


}
