import UIKit
import CleverTapSDK

class HomeViewController: UIViewController {
    
    // MARK: - UI Elements
    private let eventPageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Event Page", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let userPropertyPageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("User Property Page", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let appInboxButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("App Inbox", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "CleverTap Demo"
        
        setupLayout()
        setupActions()
    }
    
    // MARK: - Setup Methods
    private func setupLayout() {
        view.addSubview(eventPageButton)
        view.addSubview(userPropertyPageButton)
        view.addSubview(appInboxButton)
        
        NSLayoutConstraint.activate([
            eventPageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            eventPageButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
            eventPageButton.widthAnchor.constraint(equalToConstant: 220),
            eventPageButton.heightAnchor.constraint(equalToConstant: 50),
            
            userPropertyPageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userPropertyPageButton.topAnchor.constraint(equalTo: eventPageButton.bottomAnchor, constant: 30),
            userPropertyPageButton.widthAnchor.constraint(equalToConstant: 220),
            userPropertyPageButton.heightAnchor.constraint(equalToConstant: 50),
            
            appInboxButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appInboxButton.topAnchor.constraint(equalTo: userPropertyPageButton.bottomAnchor, constant: 30),
            appInboxButton.widthAnchor.constraint(equalToConstant: 220),
            appInboxButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupActions() {
        eventPageButton.addTarget(self, action: #selector(openEventPage), for: .touchUpInside)
        userPropertyPageButton.addTarget(self, action: #selector(openUserPropertyPage), for: .touchUpInside)
        appInboxButton.addTarget(self, action: #selector(openAppInbox), for: .touchUpInside)
    }
    
    // MARK: - Navigation Methods
    @objc private func openEventPage() {
        let vc = EventPageViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func openUserPropertyPage() {
        let vc = UserPropertyViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func openAppInbox() {
        guard let cleverTap = CleverTap.sharedInstance() else {
            print("CleverTap not initialized yet.")
            return
        }
        
        // Optional: customize inbox UI
        let style = CleverTapInboxStyleConfig()
        style.title = "App Inbox"
        style.navigationBarTintColor = .systemOrange
        style.navigationTintColor = .white
        style.tabUnSelectedTextColor = .systemGray
        style.tabSelectedTextColor = .white
        style.tabSelectedBgColor = .systemOrange
        
        // Get default inbox view controller
        if let inboxVC = cleverTap.newInboxViewController(with: style, andDelegate: self) {
            let nav = UINavigationController(rootViewController: inboxVC)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        } else {
            print("Inbox not ready yet. Try again in a moment.")
        }
    }
}

// MARK: - CleverTapInboxViewControllerDelegate
extension HomeViewController: CleverTapInboxViewControllerDelegate {
    func inboxMessageButtonTapped(withCustomExtras customExtras: [AnyHashable : Any]!) {
        print("App Inbox button tapped with extras: \(String(describing: customExtras))")
    }
}
