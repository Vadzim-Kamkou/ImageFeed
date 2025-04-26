import UIKit

final class SplashViewController: UIViewController {
    
    private let showAuthenticationScreenSegueIdentifier = "showAuthenticationScreenSegueIdentifier"
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    private let storage = OAuth2TokenStorage()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard  let token = storage.token else {
          return performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
        print(">>> UNSPLASH USER TOKEN IN STORAGE")
        fetchProfile(token: token)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard 
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
                return
            }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
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
        //UIBlockingProgressHUD.show()

        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            guard let self = self else { return }

            switch result {
            case .success:
                
                self.switchToTabBarController()

            case .failure:
                // TODO [Sprint 11] Покажите ошибку получения профиля
                print("TODO fetchProfile")
                break
            }
        }
        
        guard let username = ProfileService.shared.profile?.username else {return}
        profileImageService.fetchProfileImageURL(username: username) { result in
          
         
            
            switch result {
            case .success (let profileImageURL):

                print("profileImageURL Recieved")

            case .failure:
             
                print("TODO profileImageService.fetchProfileImageURL")
                break
            }
            
        }
        
        
    }
    
 
    
}
