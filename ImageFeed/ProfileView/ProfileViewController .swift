import UIKit

final class  ProfileViewController: UIViewController {
    
    private var userFullName: UILabel?
    private var userAccount: UILabel?
    private var userDescription: UILabel?
    
    private var profileImageServiceObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        
        configProfile()
        
        guard let profile = ProfileService.shared.profile else {return}
        updateProfileDetails(profile: profile)
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
    
    private func updateAvatar() {
            guard
                let profileImageURL = ProfileImageService.shared.avatarURL,
                let url = URL(string: profileImageURL)
            else { return }
            // TODO [Sprint 11] Обновить аватар, используя Kingfisher
        }
    
    private func configProfile() {
        
        let profileImage = UIImage(named: "Userpick")
        let imageView = UIImageView(image: profileImage)
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
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
        buttonLogout.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonLogout)
        buttonLogout.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        buttonLogout.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
    }
    
    @IBAction func didTapLogoutButton() {
        
        userFullName?.text = "Name"
        userAccount?.text = ""
        userDescription?.text = ""
    }
}
