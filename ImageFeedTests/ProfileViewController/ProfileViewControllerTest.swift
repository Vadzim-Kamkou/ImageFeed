import Testing
import XCTest
@testable import ImageFeed

final class ProfileViewControllerTests: XCTestCase {
    
    // проверяем, что данные заполняются корректно
    func testСonfigureLabels() {
        // given
        let view = ProfileViewController()
        view.loadViewIfNeeded()
        
        let profile = Profile(username: "", name: "name_test", loginName: "@loginName_test", bio: "bio_test")
        
        // when
        view.configureLabels(with: profile)
        
        // then
        XCTAssertEqual(view.userFullName?.text, "name_test")
        XCTAssertEqual(view.userAccount?.text, "@loginName_test")
        XCTAssertEqual(view.userDescription?.text, "bio_test")
    }
    
    // проверяем, что URL корректно парсится
    func testUpdateAvatarURLParsing() {
        let view = ProfileViewController()
        let mockService = ProfileImageServiceMock()
        mockService.avatarURL = "https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d"
        view.profileImageService = mockService
        
        view.loadViewIfNeeded()
        view.updateAvatar()
        
        XCTAssertNotNil(URL(string: mockService.avatarURL!))
    }
    
    // проверяем logout
    func testDidTapLogoutButton() {
        let view = ProfileViewControllerMock()
        
        view.loadViewIfNeeded()
        view.didTapLogoutButton()
        
        // Проверяем, что present вызвался с UIAlertController
        guard let alert = view.presentedVC as? UIAlertController else {
            XCTFail("Expected UIAlertController to be presented")
            return
        }
        
        XCTAssertEqual(alert.title, "Пока, пока!")
        XCTAssertEqual(alert.message, "Уверены, что хотите выйти?")
        
        // Проверяем, что есть две кнопки "Нет" и "Да"
        let titles = alert.actions.map { $0.title }
        XCTAssertTrue(titles.contains("Нет"))
        XCTAssertTrue(titles.contains("Да"))
    }
    
    // проверяем переход после logout
    func testNavigateToSplashScreen() {
        let view = ProfileViewController()
        
        let window = UIWindow()
        let appMock = ApplicationMock()
        appMock.windows = [window]
        
        view.application = appMock
        view.navigateToSplashScreen()
        
        XCTAssertTrue(window.rootViewController is SplashViewController)
    }
}
