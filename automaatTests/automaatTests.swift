import XCTest
@testable import automaat

final class automaatTests: XCTestCase {
    private var persistanceCtx = PersistenceController.preview.container.viewContext
    private var api: APIController!
    
    override func setUpWithError() throws {
        api = APIControllerMock(persistanceCtx: persistanceCtx)
    }

    func testLogin() async throws {
        var loginStatus = await api.loggedIn
        XCTAssert(!loginStatus)
        try! await api.login(username: "test", password: "test")
        loginStatus = await api.loggedIn
        XCTAssert(loginStatus)
    }
    
    func testCars() async throws {
        try! await api.refreshData()
    
        var cars = await api.cars
        let origCarCount = cars.count
        
        let car1 = Car(context: persistanceCtx)
        car1.brand = "Honda"
        car1.model = "Civic"
        car1.licenseplate = "1-ABC-123"
        car1.price = 100
        car1.latitude = 52.1
        car1.longitude = 4.1
        car1.options = "RGB"
        car1.backendId = 5
        car1.fuel = "Diesel"
        try! persistanceCtx.save()
        
        try! await api.refreshData()
        
        cars = await api.cars
        XCTAssert(cars.count == origCarCount + 1)
    }
    
    func testRental() async throws {
        let car1 = Car(context: persistanceCtx)
        car1.brand = "Honda"
        car1.model = "Civic"
        car1.licenseplate = "1-ABC-123"
        car1.price = 100
        car1.latitude = 52.1
        car1.longitude = 4.1
        car1.options = "RGB"
        car1.backendId = 5
        car1.fuel = "Diesel"
        try! persistanceCtx.save()
        
        try! await api.refreshData()
        let car = (await api.cars).first
        
        try await api.rentCar(car: car!, date: .now)
        let rental = (await api.rentals).first(where: {
            $0.car == car1.backendId
        })
        XCTAssert(rental != nil)
    }


    func testRefreshDataPerformance() async throws {
        self.measure {
            let exp = expectation(description: "Finished")
            Task {
                try await api.refreshData()
                exp.fulfill()
            }
            wait(for: [exp], timeout: 200.0)
        }
    }

}
