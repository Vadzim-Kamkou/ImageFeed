import UIKit
import Kingfisher

class  ProfileViewController: UIViewController {
    
    var application: ApplicationProtocol = UIApplication.shared
    var profileService: ProfileProviding = ProfileService.shared
    var profileImageService: ProfileImageProviding = ProfileImageService.shared
    var notificationCenter: NotificationCenterObserving = NotificationCenter.default
    
    var userFullName: UILabel?
    var userAccount: UILabel?
    var userDescription: UILabel?
    var userAvatarImageView: UIImageView?
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configProfile()
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
        
        if let profile = profileService.profile {
            configureLabels(with: profile)
        }
    }
    
    func configureLabels(with profile: Profile) {
         userFullName?.text = profile.name
         userAccount?.text = profile.loginName
         userDescription?.text = profile.bio
     }
    
    func updateAvatar() {
        guard
            let urlString = profileImageService.avatarURL,
            let url = URL(string: urlString)
        else { return }
        
        let processor = RoundCornerImageProcessor(cornerRadius: 70)
        userAvatarImageView?.kf.indicatorType = .activity
        userAvatarImageView?.kf.setImage(with: url, options: [.processor(processor),
                                                              .cacheOriginalImage,
                                                              .forceRefresh])
    }
    
    private func updateProfileDetails(profile: Profile) {
        guard let name:String = ProfileService.shared.profile?.name,
              let loginName:String = ProfileService.shared.profile?.loginName,
              let bio:String = ProfileService.shared.profile?.bio
        else {
            return print("UpdateProfileDetails Error")
        }
        
        userFullName?.text = name
        userAccount?.text = loginName
        userDescription?.text = bio
    }
      
    private func configProfile() {
    
        view.backgroundColor = UIColor.ypBlack
        
        let profileImage = UIImage(resource: .userpick)
        let imageView = UIImageView(image: profileImage)
        
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        self.userAvatarImageView = imageView
        
        let userFullName = UILabel()
        userFullName.text = "username"
        userFullName.textColor = .ypWhite
        userFullName.font = UIFont.boldSystemFont(ofSize: 23)
        userFullName.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userFullName)
        userFullName.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        userFullName.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10).isActive = true
        self.userFullName = userFullName
        
        let userAccount = UILabel()
        userAccount.text = "@loginName"
        userAccount.textColor = .ypGray
        userAccount.font = UIFont.systemFont(ofSize: 13)
        userAccount.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userAccount)
        userAccount.leadingAnchor.constraint(equalTo: userFullName.leadingAnchor).isActive = true
        userAccount.topAnchor.constraint(equalTo: userFullName.bottomAnchor, constant: 10).isActive = true
        self.userAccount = userAccount
        
        let userDescription = UILabel()
        userDescription.text = "bio"
        userDescription.textColor = .ypWhite
        userDescription.font = UIFont.systemFont(ofSize: 13)
        userDescription.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userDescription)
        userDescription.leadingAnchor.constraint(equalTo: userAccount.leadingAnchor).isActive = true
        userDescription.topAnchor.constraint(equalTo: userAccount.bottomAnchor, constant: 10).isActive = true
        self.userDescription = userDescription
        
        let exitImage = UIImage(resource: .exit).withRenderingMode(.alwaysOriginal)
        let buttonLogout = UIButton.systemButton(
            with: exitImage,
            target: self,
            action: #selector(self.didTapLogoutButton)
        )
        buttonLogout.accessibilityIdentifier = "logoutButton"
        buttonLogout.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonLogout)
        buttonLogout.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        buttonLogout.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
    }
    
    @IBAction func didTapLogoutButton() {
        
        let alertResult = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert)
        let action_skip = UIAlertAction(title: "Нет", style: .cancel )
        let action_logout = UIAlertAction(title: "Да", style: .default) { _ in
            ProfileLogoutService.shared.logout()
            self.navigateToSplashScreen()
        }
        alertResult.addAction(action_skip)
        alertResult.addAction(action_logout)
        self.present(alertResult, animated: true, completion: nil)
    }
    
    func navigateToSplashScreen() {
        let splashViewController = SplashViewController()
        guard let window = application.windows.first else {
            fatalError("splashViewController отсутствует для перехода")
        }
        window.rootViewController = splashViewController
        window.makeKeyAndVisible()
    }
}
