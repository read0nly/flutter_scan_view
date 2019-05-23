#import "FlutterScanViewPlugin.h"
#import <flutter_scan_view/flutter_scan_view-Swift.h>

@implementation FlutterScanViewPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
   SwiftFlutterScanViewPluginFactory * scanFactory = [[SwiftFlutterScanViewPluginFactory alloc] initWithMessenger:registrar.messenger];
     [registrar registerViewFactory:scanFactory withId:@"plugins.flutter.io/njscanview"];

}
@end
