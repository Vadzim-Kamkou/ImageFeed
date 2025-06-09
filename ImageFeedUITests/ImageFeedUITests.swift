import XCTest


class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication() // переменная приложения
    
    override func setUpWithError() throws {
        continueAfterFailure = false // настройка выполнения тестов, которая прекратит выполнения тестов, если в тесте что-то пошло не так
        app.launch() // запускаем приложение перед каждым тестом
    }
    
    func testFullUserFlow() throws {
        try testAuth()
        try testFeed()
        try testProfile()
    }
    
    private func testAuth() throws {
        // Нажать кнопку авторизации
        // У приложения мы получаем список кнопок на экране и получаем нужную кнопку по тексту на ней
        // Далее вызываем функцию tap() для нажатия на этот элемент
        app.buttons["Authenticate"].tap()
        
        // Подождать, пока экран авторизации открывается и загружается
        let webView = app.webViews["UnsplashWebView"]
//        let webView = app.webViews.element(boundBy: 0)
        XCTAssertTrue(webView.waitForExistence(timeout: 10))
        
        // Ввести данные в форму
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("vadzim.kamkou@gmail.com")
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        passwordTextField.typeText("VK20250401")
        //webView.swipeUp()
        
        // Нажать кнопку логина
        webView.buttons["Login"].tap()
        
        // Подождать, пока открывается экран ленты
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 10))
        
    }
    
    private func testFeed() throws {
        sleep(10)
        
        // Подождать, пока открывается и загружается экран ленты
        let tablesQuery = app.tables
        
        // Сделать жест «смахивания» вверх по экрану для его скролла
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        
        sleep(10)
        
        /*
        // Поставить лайк в ячейке верхней картинки
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        let likeButtonOff = cellToLike.buttons["NoActive"]
        if likeButtonOff.waitForExistence(timeout: 5) {
            likeButtonOff.tap()
            sleep(2)
            
            // Только если кнопка "Active" появилась после лайка — пробуем снять лайк
            let likeButtonOn = cellToLike.buttons["Active"]
            if likeButtonOn.waitForExistence(timeout: 5) {
                likeButtonOn.tap()
                sleep(2)
            } else {
                print("⚠️ Кнопка 'Active' не появилась — возможно, лайк не поставился")
            }
        } else {
            print("⚠️ Кнопка 'NoActive' не найдена — лайк не поставлен")
        }
        */
        
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        cellToLike.buttons["NoActive"].tap()
        sleep(10)
        // Отменить лайк в ячейке верхней картинки
        //cellToLike.buttons["Active"].tap()
        
        sleep(10)
        
        // Нажать на верхнюю ячейку
        cellToLike.tap()
        
        // Подождать, пока картинка открывается на весь экран
        sleep(10)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        // Увеличить картинку
        image.pinch(withScale: 3, velocity: 1)
        // Уменьшить картинку
        image.pinch(withScale: 0.5, velocity: -1)
        
        // Вернуться на экран ленты
        let navBackButtonWhiteButton = app.buttons["SingleViewBackButton"]
        navBackButtonWhiteButton.tap()
    }
    
    private func testProfile() throws {

        // Подождать, пока открывается и загружается экран ленты
        sleep(5)
        
        // Перейти на экран профиля
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        // Проверить, что на нём отображаются ваши персональные данные
        XCTAssertTrue(app.staticTexts["Vadzim Kamkou"].exists)
        XCTAssertTrue(app.staticTexts["@vadzimkamkou"].exists)
        
        // Нажать кнопку логаута
        app.buttons["logoutButton"].tap()
        
        // Проверить, что открылся экран авторизации
        let alert = app.alerts["Пока, пока!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        alert.scrollViews.otherElements.buttons["Да"].tap()
    }
}
