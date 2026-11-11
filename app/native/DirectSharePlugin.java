package am.smarteye.pricemanager;

import android.content.ActivityNotFoundException;
import android.content.ClipData;
import android.content.Intent;
import android.net.Uri;
import androidx.core.content.FileProvider;
import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import java.io.File;
import java.util.List;

/** Sends a file straight to one app (Telegram / Viber / WhatsApp) without the system share sheet. */
@CapacitorPlugin(name = "DirectShare")
public class DirectSharePlugin extends Plugin {
    @PluginMethod
    public void share(PluginCall call) {
        String path = call.getString("path");
        String type = call.getString("type", "application/pdf");
        JSArray pkgs = call.getArray("packages");
        if (path == null || pkgs == null) { call.reject("path and packages are required"); return; }
        try {
            File f = new File(Uri.parse(path).getPath());
            Uri uri = FileProvider.getUriForFile(getContext(), getContext().getPackageName() + ".fileprovider", f);
            List<String> list = pkgs.toList();
            for (String p : list) {
                Intent i = new Intent(Intent.ACTION_SEND);
                i.setType(type);
                i.putExtra(Intent.EXTRA_STREAM, uri);
                i.setClipData(ClipData.newRawUri("", uri));
                i.setPackage(p);
                i.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
                try {
                    getActivity().startActivity(i);
                    JSObject r = new JSObject(); r.put("ok", true); r.put("pkg", p); call.resolve(r); return;
                } catch (ActivityNotFoundException e) { /* app not installed - try the next one */ }
            }
            JSObject r = new JSObject(); r.put("ok", false); call.resolve(r);
        } catch (Exception e) {
            call.reject(String.valueOf(e.getMessage()));
        }
    }
}
