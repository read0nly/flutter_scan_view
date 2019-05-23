import Flutter
import UIKit
import ZXingObjC

public class SwiftFlutterScanViewPluginFactory: NSObject, FlutterPlatformViewFactory {

    var messenger:FlutterBinaryMessenger!

    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return SwiftFlutterScanViewController.init(withFrame: frame, viewIdentifier: viewId, arguments: args, binaryMessenger: messenger)
    }

    @objc public init(messenger: (NSObject & FlutterBinaryMessenger)?) {
        super.init()
        self.messenger = messenger
    }

    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

public class SwiftFlutterScanViewController :NSObject, FlutterPlatformView,ZXCaptureDelegate {

    fileprivate var viewId: Int64!;
    fileprivate var scanView:UIView!
    fileprivate var channel :FlutterMethodChannel!

    private var capture:ZXCapture!
    private var captureSizeTransform:CGAffineTransform!

    var scanResult: FlutterResult?

    //MARK: -  👉 Flutter
    public init(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, binaryMessenger: FlutterBinaryMessenger) {
        super.init()

        /// 保存viewid
        self.viewId = viewId

        /// 初始化channel
        let channelName:String = String.init(format: "plugins.flutter.io/njscanview_%lld", arguments: [viewId])
        self.channel = FlutterMethodChannel.init(name: channelName, binaryMessenger: binaryMessenger)
        self.channel.setMethodCallHandler {[weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void  in
            guard let self = self else { return }
            self.onMethodCall(call: call, result: result)
        }
        // 初始化view
        let params = args as? NSDictionary
        let width = params?["width"] as? CGFloat ?? 0
        let height = params?["height"] as? CGFloat ?? 0
        self.scanView = UIView(frame: CGRect.init(x: 0, y: 0, width: width, height: height))
        self.initScan()
        self.initNotification()
     }

    public func view() -> UIView {
        return self.scanView;
    }

    func onMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let method = call.method
        if method == "start" {
            self.startScan(result: result)
        } else if method == "stop" {
            self.stopScan()
        }
    }

    //MARK: -  👉 Scan
    func initScan() {
        self.capture = ZXCapture()
        self.capture.camera = capture.back()
        self.capture.focusMode = .continuousAutoFocus
        self.capture.sessionPreset = AVCaptureSession.Preset.hd1280x720.rawValue
        self.capture.layer.frame = self.scanView.bounds
        self.scanView.layer.addSublayer(self.capture.layer)

        /// 设置capture的旋转
        self.applyOrientation()
        /// 设置扫码是被区域
        self.applyRectOdInterest()
    }
    
    func initNotification() {
        if (!UIDevice.current.isGeneratingDeviceOrientationNotifications) {
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(handleDeviceOrientationChange), name:UIDevice.orientationDidChangeNotification , object: nil)
    }
    
    func startScan(result: @escaping FlutterResult) {
        self.scanResult = result
        self.capture.delegate = self
        self.capture.start()
    }
    func stopScan() {
        self.scanResult = nil
        self.capture.delegate = nil
        self.capture.stop()
    }
    //MARK: -  👉 ZXCaptureDelegate
    public func captureResult(_ capture: ZXCapture!, result: ZXResult!) {
        self.scanResult?(result.text)
        self.stopScan()
        print(result.text)

    }

    //MARK: -  👉 private
    @objc func handleDeviceOrientationChange(notification:Notification) {
        self.capture.layer.frame = self.scanView.bounds
        self.applyOrientation()
    }
    
    /// 设置摄像头画面的旋转方向
    private func applyOrientation() {
        let orientation = UIApplication.shared.statusBarOrientation
        var scanRectRotation:Float = 0
        var captureRotation:Float = 0
        switch orientation {
        case .portrait:
            captureRotation = 0
            scanRectRotation = 90
        case .landscapeLeft:
            captureRotation = 90
            scanRectRotation = 180
        case .landscapeRight:
            captureRotation = 270
            scanRectRotation = 0
        case .portraitUpsideDown:
            captureRotation = 180
            scanRectRotation = 270
        default:
            captureRotation = 0
            scanRectRotation = 90
        }

        let transform = CGAffineTransform(rotationAngle: CGFloat(Double(captureRotation) / 180 * Double.pi))
        capture.transform = transform
        capture.rotation = CGFloat(scanRectRotation)


    }
    /// 设置摄像头画面的扫码区域
    private func applyRectOdInterest() {
        var videoSizeX:CGFloat = 1280
        var videoSizeY:CGFloat = 720
        let orientation = UIApplication.shared.statusBarOrientation
        switch orientation {
        case .landscapeLeft,.landscapeRight:
         videoSizeX = 720
         videoSizeY = 1280
        default:break;
        }
    
        /// 设置扫码区域
        let captureSizeTransform = CGAffineTransform.init(scaleX: videoSizeX / self.scanView.bounds.width, y: videoSizeY / self.scanView.bounds.height)
        self.capture.scanRect = self.scanView.bounds.applying(captureSizeTransform)
        print("self.capture.scanRect:\(self.capture.scanRect)")
       
    }

    private func barCodeFormatToString(format:ZXBarcodeFormat) -> String {
        switch format {
        case kBarcodeFormatAztec:
            return "Aztec"

        case kBarcodeFormatCodabar:
            return "CODABAR"

        case kBarcodeFormatCode39:
            return "Code 39"

        case kBarcodeFormatCode93:
            return "Code 93"

        case kBarcodeFormatCode128:
            return "Code 128"

        case kBarcodeFormatDataMatrix:
            return "Data Matrix"

        case kBarcodeFormatEan8:
            return "EAN-8"

        case kBarcodeFormatEan13:
            return "EAN-13"

        case kBarcodeFormatITF:
            return "ITF"

        case kBarcodeFormatPDF417:
            return "PDF417"

        case kBarcodeFormatQRCode:
            return "QR Code"

        case kBarcodeFormatRSS14:
            return "RSS 14"

        case kBarcodeFormatRSSExpanded:
            return "RSS Expanded"

        case kBarcodeFormatUPCA:
            return "UPCA"

        case kBarcodeFormatUPCE:
            return "UPCE"

        case kBarcodeFormatUPCEANExtension:
            return "UPC/EAN extension"

        default:
            return "Unknown"
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        self.capture.layer.removeFromSuperlayer()
        self.capture.delegate = nil
        self.capture = nil
        self.scanResult = nil
    }
}
