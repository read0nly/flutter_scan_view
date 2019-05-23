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
        /// 设置扫码区域
        let captureSizeTransform = CGAffineTransform.init(scaleX: 720 / self.scanView.bounds.width, y: 1280 / self.scanView.bounds.height)
        self.capture.scanRect = self.scanView.bounds.applying(captureSizeTransform)
//        print("self.capture.scanRect:\(self.capture.scanRect)")
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

    private func applyRectOdInterest() {
        var scaleVideo:CGFloat = 0.0
        var scaleVideoX:CGFloat = 0
        var scaleVideoY:CGFloat = 0

        var videoSizeX:CGFloat = 0
        var videoSizeY:CGFloat = 0
        var width:CGFloat = 0
        var height:CGFloat = 0
        var x:CGFloat = 0
        var y:CGFloat = 0

        if (self.capture.sessionPreset == AVCaptureSession.Preset.hd1920x1080.rawValue ) {
            videoSizeX = 1080
            videoSizeY = 1920
        } else {
            videoSizeX = 720
            videoSizeY = 1280
        }
        scaleVideoX = self.scanView.bounds.width / videoSizeX
        scaleVideoY = self.scanView.bounds.height / videoSizeY
        scaleVideo = max(scaleVideoX, scaleVideoY)

        width = self.capture.layer.frame.size.width / scaleVideo
        height = self.capture.layer.frame.size.height / scaleVideo
        if (scaleVideoX > scaleVideoY) {
            x = self.capture.layer.frame.origin.x / scaleVideo
            y = x * self.capture.layer.frame.origin.y / self.capture.layer.frame.origin.x
        } else {
            y = self.capture.layer.frame.origin.y / scaleVideo
            x = y * self.capture.layer.frame.origin.x / self.capture.layer.frame.origin.y
        }
        self.capture.scanRect = CGRect.init(x: x, y: y, width: width, height: height)
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
        self.capture.layer.removeFromSuperlayer()
        self.capture.delegate = nil
        self.capture = nil
        self.scanResult = nil
    }
}
