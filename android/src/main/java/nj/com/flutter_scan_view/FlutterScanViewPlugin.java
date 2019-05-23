package nj.com.flutter_scan_view;

import io.flutter.plugin.common.PluginRegistry;

public class FlutterScanViewPlugin {
    public static void registerWith(PluginRegistry.Registrar registrar) {
        registrar.platformViewRegistry().registerViewFactory("plugins.flutter.io/njscanview", new NJScanViewFactory(registrar.messenger()));

    }
}
