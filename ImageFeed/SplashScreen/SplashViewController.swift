import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: Property
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    private var authVC = AuthViewController()
    private let storage = OAuth2TokenStorage()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private var logoSplashScreen: UIView?
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configSplashScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard  let token = storage.token else {
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {return}
            authViewController.delegate = self
                        
            let navigationVC = UINavigationController(rootViewController: authViewController)
            navigationVC.modalPresentationStyle = .fullScreen
            return self.present(navigationVC, animated: true)
        }
        print(">>> UNSPLASH USER TOKEN IN STORAGE")
        fetchProfile(token: token)
    }
    
    // MARK: Private Functions
    private func configSplashScreen() {
        self.view.backgroundColor = UIColor.ypBlack
        
        let logoImage = UIImage(named: "splash_screen_logo")
        let logoImageView = UIImageView(image: logoImage)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImageView)
        logoImageView.centerXAnchor.constraint(equalTo: super.view.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: super.view.centerYAnchor).isActive = true
        self.logoSplashScreen = logoImageView
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    } 
}

extension SplashViewController: AuthViewControllerDelegate {

    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        guard let token = storage.token else {
            return
        }
        fetchProfile(token: token)
    }
    
    private func fetchProfile(token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            guard let self = self else { return }

            switch result {
            case .success:
                self.switchToTabBarController()
            case .failure (let error):
                print("[\(self)]: fetchProfile - \(error)")
                break
            }
        }
        
        guard let username = ProfileService.shared.profile?.username else {return}
        profileImageService.fetchProfileImageURL(username: username) { result in
          
            switch result {
            case .success (_):
                print("profileImageURL Recieved")
            case .failure (let error):
                print("[\(self)]: fetchProfileImageURL - \(error)")
                break
            }
        }
    }
}
