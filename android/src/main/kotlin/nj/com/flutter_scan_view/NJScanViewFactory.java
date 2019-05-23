package nj.com.flutter_scan_view;

import android.content.Context;

import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

@SuppressWarnings("unchecked")
public class NJScanViewFactory extends PlatformViewFactory {
    private final BinaryMessenger messenger;

    public  NJScanViewFactory(BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);
        this.messenger = messenger;
    }

    @Override
    public PlatformView create(Context context, int i, Object o) {
        Map<String, Object> params = (Map<String, Object>) o;
        return new NJScanView(context, messenger, i, params);
    }
}
