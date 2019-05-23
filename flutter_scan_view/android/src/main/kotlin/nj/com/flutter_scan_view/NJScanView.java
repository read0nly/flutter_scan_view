package nj.com.flutter_scan_view;

import android.content.Context;
import android.view.View;

import com.google.zxing.ResultPoint;
import com.journeyapps.barcodescanner.BarcodeCallback;
import com.journeyapps.barcodescanner.BarcodeResult;
import com.journeyapps.barcodescanner.DecoratedBarcodeView;

import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

@SuppressWarnings("unchecked")
public class NJScanView implements PlatformView, MethodChannel.MethodCallHandler {
    private final MethodChannel methodChannel;
    private DecoratedBarcodeView scannerView;
    private MethodChannel.Result callback;
    
    NJScanView(Context context, BinaryMessenger messenger, int id, Map<String, Object> params) {

        scannerView = new DecoratedBarcodeView(context);
        methodChannel = new MethodChannel(messenger, "plugins.flutter.io/njscanview_" + id);
        methodChannel.setMethodCallHandler(this);
        /// 绑定
        scannerView.decodeContinuous(new BarcodeCallback() {
            @Override
            public void barcodeResult(BarcodeResult result) {
                scannerView.pause();
                if (callback != null) {
                    callback.success(result.getText());
                }
            }

            @Override
            public void possibleResultPoints(List<ResultPoint> resultPoints) {
            }
        });
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        switch (methodCall.method) {
            case "start":
                start(methodCall, result);
                break;
            case "stop":
                stop(methodCall, result);
                break;
            default:
                result.notImplemented();
        }
    }

    @Override
    public View getView() {

        return scannerView;
    }

    @Override
    public void dispose() {
        scannerView.pause();
        scannerView.invalidate();
        scannerView = null;
        methodChannel.setMethodCallHandler(null);
    }


    private void start(MethodCall methodCall, MethodChannel.Result result) {
        this.callback = result;
        scannerView.resume();
    }

    private void stop(MethodCall methodCall, MethodChannel.Result result) {
        scannerView.pause();
    }
}
