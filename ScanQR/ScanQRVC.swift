//
//  ScanQRVC.swift
//  ScanQR
//
//  Created by DD on 2022/3/16.
//

import UIKit
import AVFoundation

public enum QRCodeScannerError: Int {
    case SimulatorError
    
    case CamaraAuthorityError
    
    case OtherError
}

class ScanQRVC: UIViewController {
    private var inPut: AVCaptureDeviceInput?
    
    public var isDrawQRCodeRect = false
    
    private let outPut: AVCaptureMetadataOutput = {
        let outPut = AVCaptureMetadataOutput()
        outPut.connection(with: .metadata)
        return outPut
    }()
    private let session: AVCaptureSession = {
        let session = AVCaptureSession()
        if session.canSetSessionPreset(.high) {
            session.sessionPreset = .high
        }
        return session
    }()
    
    private let preLayer = AVCaptureVideoPreviewLayer()
    private var scanSuccess:Bool = false
    private var isRunning = false
    
    public var centerWidth: CGFloat = 250
    public var centerHeight: CGFloat = 250
    
    public var delayTime: Double = 0.3
    public var centerPosition: CGPoint?
    public var maskColor = UIColor(white: 0, alpha: 0.5)
    public var drawRectColor = UIColor.red
    
    public var drawRectLineWith: CGFloat = 2
    private var deleteTempLayers = [CAShapeLayer]()
    private var bluePoint: UIButton = {
        let imageView = UIButton()
        imageView.backgroundColor = UIColor.blue
        imageView.layer.cornerRadius = 25
        imageView.frame.size = CGSize(width: 50, height: 50)
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let device = AVCaptureDevice.default(for: .video) else {
            return
        }
        do {
            inPut = try AVCaptureDeviceInput(device: device)
        } catch {
            //            delegate?.scanQRCodeFaild(scanner: self, error: .OtherError)
        }
        outPut.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        preLayer.session = session
        preLayer.videoGravity = .resizeAspectFill
        beginScanQRCode()
    }
    
    public func beginScanQRCode() {
        if isRunning {
            return
        }
        isRunning = true
        
        if !checkCameraAuth() {
            scanQRCodeFaild(scanner: self, error: .CamaraAuthorityError)
        }
        
        guard let input = inPut else {
            return
        }
        
        if session.canAddInput(input) && session.canAddOutput(outPut) {
            session.addInput(input)
            session.addOutput(outPut)
            outPut.metadataObjectTypes = [.qr, .code128, .code39, .code93, .code39Mod43, .ean8, .ean13, .upce, .pdf417, .aztec]
            
        } else {
            scanQRCodeFaild(scanner: self, error: .OtherError)
            return
        }
        
        view.backgroundColor = UIColor.white
        
        let flag = view.layer.sublayers?.contains(preLayer)
        if flag == false || flag == nil {
            preLayer.frame = view.bounds
            view.layer.insertSublayer(preLayer, at: 0)
        }

        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        var centerPath = UIBezierPath(rect: CGRect(x: (view.frame.size.width - centerWidth) / 2, y: (view.frame.size.height - centerHeight) / 2, width: centerWidth, height: centerHeight))
        if let centerPosition = centerPosition {
            centerPath = UIBezierPath(rect: CGRect(x: centerPosition.x - centerWidth / 2, y: centerPosition.y - centerHeight / 2, width: centerWidth, height: centerHeight))
        }
        path.append(centerPath.reversing())
        let rectLayer = CAShapeLayer()
        rectLayer.path = path.cgPath
        rectLayer.fillColor = maskColor.cgColor
        view.layer.addSublayer(rectLayer)
        
//        let previewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
//                previewLayer.videoGravity = .resizeAspectFill
//                previewLayer.frame = view.bounds
//                view.layer.insertSublayer(previewLayer, at: 0)
//
//        let rect = CGRect(x: scanImageView.frame.minY / kScreenHeight, y: scanImageView.frame.minX / kScreenWidth, width: scanImageView.frame.height / kScreenHeight, height: scanImageView.frame.width / kScreenWidth)
//        outPut.rectOfInterest = rect
        
        let centor = view.center
        setInterestRect(originRect: CGRect(x: centor.x - centerWidth / 2.0, y: centor.y - centerHeight / 2.0, width: centerWidth, height: centerHeight))
        
        session.startRunning()
    }
    
    public func stopScan() {
        if !isRunning {
            return
        }
        isRunning = false
        session.stopRunning()
        if let input = inPut {
            session.removeInput(input)
        }
        session.removeOutput(outPut)
        //        removeShapLayer()
        navigationController?.popViewController(animated: false)
    }
    
    private func checkCameraAuth() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        return status == .authorized
    }
    
    func scanQRCodeFaild(scanner: ScanQRVC, error: QRCodeScannerError) {
        
    }
    
    
    func scanQRCodeSuccess(scanner: ScanQRVC, resultStrs: [String]) {
        let splitStr = resultStrs[0].split(separator: "&")
        var id = 0
        var name = ""
        var sex = true
        for str in splitStr {
            let kv = str.split(separator: "=")
            let key = kv[0]
            let value = kv[1]
            if (key == "id") {
                id = Int(value) ?? 0
            } else if (key == "name") {
                name = String(value)
            } else if key == "sex" {
                sex = value == "1"
            }
        }
        let user = User(id: id, name: name, sex: sex, isCheckin: false)
        saveUser(user)
        dismiss(animated: true, completion: nil)
    }
    
    public func setInterestRect(originRect: CGRect) {
        
        let screenBounds = UIScreen.main.bounds
        let x = originRect.origin.x / screenBounds.size.width
        let y = originRect.origin.y / screenBounds.size.height
        let width = originRect.size.width / screenBounds.size.width
        let height = originRect.size.height / screenBounds.size.height
        outPut.rectOfInterest = CGRect(x: x, y: y, width: width, height: height)
    }
    
    private func addShapeLayers(transformObj: AVMetadataMachineReadableCodeObject) {
        // 绘制边框
        let layer = CAShapeLayer()
        layer.strokeColor = drawRectColor.cgColor
        layer.lineWidth = drawRectLineWith
        layer.fillColor = UIColor.clear.cgColor
        
        // 创建一个贝塞尔曲线
        let path = UIBezierPath()
        var index = 0
        
        for pointDic in transformObj.__corners {
            let dict = pointDic as CFDictionary
            let point = CGPoint(dictionaryRepresentation: dict) ?? CGPoint.zero
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
            index += 1
        }
        path.close()
        layer.path = path.cgPath
        preLayer.addSublayer(layer)
        deleteTempLayers.append(layer)
    }
    
    private func addBluePoint(transformObj: AVMetadataMachineReadableCodeObject) {
        var Xs = [CGFloat]()
        var Ys = [CGFloat]()
        for pointDic in transformObj.__corners {
            let dict = pointDic as CFDictionary
            let point = CGPoint(dictionaryRepresentation: dict) ?? CGPoint.zero
            Xs.append(point.x)
            Ys.append(point.y)
        }
        let cenX = ((Xs.max() ?? 0) + (Xs.min() ?? 0)) / 2.0
        let cenY = ((Ys.max() ?? 0) + (Ys.min() ?? 0)) / 2.0
        
        
        bluePoint.center = CGPoint(x: cenX, y: cenY)
        if bluePoint.superview == nil {
            view.addSubview(bluePoint)
        }
    }
    
    /// 移除二维码边框图层
    private func removeShapLayer() {
        for layer in deleteTempLayers {
            layer.removeFromSuperlayer()
        }
        deleteTempLayers.removeAll()
    }
    
    private func clearAllLayer() {
        for layer in view.layer.sublayers ?? [] {
            layer.removeFromSuperlayer()
        }
    }
}

extension ScanQRVC: AVCaptureMetadataOutputObjectsDelegate {
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        session.stopRunning()
        
        var resultStrs = [String]()
        
        for obj in metadataObjects {
            guard let codeObj = obj as? AVMetadataMachineReadableCodeObject else {
                return
            }
            
            resultStrs.append(codeObj.stringValue ?? "")
        }
        
        guard !scanSuccess else {
            return
        }
        
        scanSuccess = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) {
            self.scanQRCodeSuccess(scanner: self, resultStrs: resultStrs)
            self.scanSuccess = false
        }
    }
}
