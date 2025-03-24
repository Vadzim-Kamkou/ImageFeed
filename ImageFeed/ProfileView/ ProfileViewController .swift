import UIKit

final class  ProfileViewController: UIViewController {
    
    private var userFullName: UILabel?
    private var userAccount: UILabel?
    private var userDescription: UILabel?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        configProfile()
    }
    
    @IBAction func didTapLogoutButton() {
        
        userFullName?.text = "Name"
        userAccount?.text = ""
        userDescription?.text = ""
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
        userFullName.text = "Екатерина Новикова"
        userFullName.textColor = .ypWhite
        userFullName.font = UIFont(name: "HelveticaNeue-Bold", size: 23)
        userFullName.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userFullName)
        userFullName.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        userFullName.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10).isActive = true
        self.userFullName = userFullName
       
        let userAccount = UILabel()
        userAccount.text = "@ekaterina_nov"
        userAccount.textColor = .ypGray
        userAccount.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userAccount)
        userAccount.leadingAnchor.constraint(equalTo: userFullName.leadingAnchor).isActive = true
        userAccount.topAnchor.constraint(equalTo: userFullName.bottomAnchor, constant: 10).isActive = true
        self.userAccount = userAccount
        
        let userDescription = UILabel()
        userDescription.text = "Hello, world!"
        userDescription.textColor = .ypWhite
        userDescription.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userDescription)
        userDescription.leadingAnchor.constraint(equalTo: userAccount.leadingAnchor).isActive = true
        userDescription.topAnchor.constraint(equalTo: userAccount.bottomAnchor, constant: 10).isActive = true
        self.userDescription = userDescription

        let buttonLogout = UIButton.systemButton(
            with: UIImage(systemName: "ipad.and.arrow.forward")!,
            target: self,
            action: #selector(self.didTapLogoutButton)
        )
        buttonLogout.tintColor = .red
        buttonLogout.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonLogout)
        buttonLogout.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        buttonLogout.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
    }
}
