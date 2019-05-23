package nj.com.flutter_scan_view


import io.flutter.plugin.common.PluginRegistry.Registrar

class FlutterScanViewPlugin {
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val scanViewFactory = NJScanViewFactory(registrar.messenger());
            registrar.platformViewRegistry().registerViewFactory("plugins.flutter.io/njscanview", scanViewFactory);
        }
    }


}
