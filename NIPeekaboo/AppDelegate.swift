/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A class that responds to application life cycle events.
*/

import UIKit
import NearbyInteraction

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("📡 [DEBUG] Inicializando sessão Nearby Interaction antes da verificação...")
        let tempSession = NISession() // ✅ Força inicialização

        var isSupported: Bool
        if #available(iOS 16.0, *) {
            isSupported = NISession.deviceCapabilities.supportsPreciseDistanceMeasurement
        } else {
            isSupported = NISession.isSupported
        }

        print("📡 [DEBUG] Nearby Interaction é suportado? \(isSupported)")

        window = UIWindow(frame: UIScreen.main.bounds)
        let vc: UIViewController

        if isSupported {
            print("✅ Dispositivo suportado, iniciando StartViewController...")
            vc = StartViewController()
        } else {
            print("❌ Dispositivo não suporta Nearby Interaction, carregando tela de erro.")
            vc = UnsupportedDeviceViewController()
        }

        window?.rootViewController = vc
        window?.makeKeyAndVisible()

        return true
    }
}

import UIKit

class UnsupportedDeviceViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let label = UILabel()
        label.text = "Seu dispositivo não suporta essa funcionalidade."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
}
