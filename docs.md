## Quick facts

App name: Automagic  
Programming language: Swift and SwiftUI  
Backend: provided JHipster  
Mail server: Inbucket with port 25 exposed using docker  
Tunneling: ngrok  
mockup: [https://www.figma.com/file/5qulfKMi0q19twlHDl4xfF/Untitled?type=design&node-id=0%3A1&mode=design&t=HKeym6SHn3RI94VA-1](https://www.figma.com/file/5qulfKMi0q19twlHDl4xfF/Untitled?type=design&node-id=0%3A1&mode=design&t=HKeym6SHn3RI94VA-1)

## Techniques
**Secure storage**: Keychain, uses hardware encryption to ensure safe credential storing.  
**Local storage**: Core Data (SQLite under the hood, contains cars, rentals, etc.)  
(Keychain stores sensitive credentials, login tokens, etc.)  
(Theme is stored in UserDefaults, user defaults is a key value store that is used to store small amounts of data)  
**Development Mail server**: Inbucket (catches all mail and makes it available to read)  
**Image fetching**: Google Search API (two requests per query, one for the search results, and another one for the image itself.)  
This is made available through the ImageFetcher class.  
To improve the results we only fetch transparent images.  
These urls are then sorted using our custom sorting hueristics.  
After they are sorted we fetch the first successful image and trim the transparent pixels such that they are all the same size. (and don't have different transparent border widths)  

**Dependency injection**: using Environment and Environment objects  
API controller is a service that handles all the api communication, it is available using an environment object.  
(@Environment is a value property, and @EnvironmentObject is a reference property.)  

**Splashscreen**: AI generated, loaded as a video. Transitions into the main content.  
**URI Schemes**: URI Schemes are defined to correctly handle the account creation and password reset.  
**Face ID / Biometric identification**: used as a replacement for the 2fa requirement  
**Routes**: An Apple Maps route to the selected car is shown on the map.

**Custom map library**: A custom map library is used to show the cars on the map.
- Official mapkit library does not have support for older IOS versions.
    - A third party library fixed this by backporting some of the features.
    - A fork of this third party library is used to merge a few pull requests that fix some bugs.

## Implementation choices
- Planned rentals only have a start date, the end date will be known once the rental is stopped.
    - It is not possible for the rental company to ensure that the customer returns the car within the correct period.
    - (Date picker allows only one date to be picked)
- All rentals are considered to be paid for in advance.
    - This is because the payment system is not implemented in the backend.
    - The payment system would be implemented using a third party library.

## backend notes
repo: mad-backend-generated  
### strange features  
- AM/reset-password/init requires authentication (/reset-password/init should be used instead).  
- account/activate is a GET endpoint but doesn't have a redirect URI.  
- Mockdata has longitude latitude switched.  
- Mockdata has a lot of duplicate values (price)
- Failing requests also return status code 200  
- ~~Car endpoint does not contain coordinates~~ Fixed in a later version of the backend  
### Swift implementation
- All requests are made using the APIController class.  
    - This class handles all the authentication and error handling.  
    - It also handles the parsing of the response.
    - For each possible response there is a model available in the apiResponses file.

### our changes
- Mockdata made more realistic  
    - coordinates generated using chatGPT and manual adjustment
    - Prices randomized
- Mail templates changed to include the URI-scheme's of our app  (automagic://resetpassword?key=...)

## Further implementation ideas  
I18n (internationalisation) translation strings. (would be possible but not a requirement)  
SwiftUI previews (allows for easier ui development, but requires configuring some mock data for each view)

## Swift crash course
Variable syntax:
```swift
let constant = "constant"
var variable = "variable"
```

Nullability is handled using optionals, optionals are a type that can either be nil or contain a value.
```swift
let optionalValue: String? = nil
print(optionalValue ?? "default value") // prints "default value" if optionalValue is nil
```

Try is used to handle errors, it can be used to call functions that throw errors.
```swift
do {
    try functionThatThrows()
} catch {
    print(error)
}

// or
try? functionThatThrows() // returns nil if function throws an error
// or
try! functionThatThrows() // crashes if function throws an error
```


Swift uses type inference, so you don't have to specify the type of a variable.
```swift
let constant: String = "constant"
var variable: String = "variable"
```

Ranges are used to iterate over a range of numbers.
```swift
for i in 0..<10 {
    print(i)
}
```

In swift you can use trailing closures to pass a function as a parameter.
```swift
func doSomething(callback: (String) -> Void) {
    callback("Hello")
}

doSomething { (string) in
    print(string)
}
```

SwiftUI is a declarative UI framework, it uses a tree of views to render the UI.
```swift
struct ContentView: View {
    var body: some View {
        Text("Hello, World!")
    }
}
```

All enum/class/struct definitions are internal by default (you can access them everywhere inside the same module)

SwiftUI uses a lot of modifiers to modify the behaviour of a view.
```swift
Text("Hello, World!")
    .foregroundColor(.red)
    .font(.title)
```

Some important modifiers:
```swift
.frame(width: 100, height: 100) // sets the size of the view
.padding(10) // adds padding to the view, can also be used without parameters to add some kind of magic padding 🤷‍♂️
.onAppear { // called when the view appears
    print("Hello, World!")
} // event handlers are also modifiers
```

Some important view types:
```swift
Text("Hello, World!") // displays text
Image("image") // displays an image
Button("Hello, World!") { // displays a button
    print("Hello, World!")
}
HStack { // displays views horizontally
    Text("Hello, World!")
    Text("Hello, World!")
}
VStack { // displays views vertically
    Text("Hello, World!")
    Text("Hello, World!")
}
```


Extensions are used to extend the functionality of a class.
```swift
extension String {
    func print() {
        Swift.print(self)
    }
}
```

If let is used to check for nil values, and only execute code if the value is not nil.
```swift
if let value = optionalValue {
     // value is type narrowed to the type, and will not be nil inside here
    print(value)
}
```

Guards are used to check for nil values, and return or throw something if nil value found.
```swift
guard let value = optionalValue else {
    return
}
```

keypaths are used to access properties of a class, they are used to access properties of a class without having to instantiate it.
```swift
struct Person {
    var name: String
}

let person = Person(name: "John")
let name = person[keyPath: \.name]
```

Computed properties are properties that are calculated when they are accessed.
```swift
struct Person {
    var name: String
    var fullName: String {
        return "Hello, \(name)"
    }
}
```

Defer is used to execute code when the current scope is exited. (can not contain async code)
```swift
defer {
    print("Hello, World!")
}
```

Swiftui State is used to store a value that can change over time.
Changes to a state variable will cause the view to be re-rendered.
```swift
@State var value: String = "Hello, World!"
@StateObject var object: Object = Object()
```

Swiftui ObservedObject is used to store a value that can change over time.
Changes to an observed object will cause the view to be re-rendered.
```swift
@ObservedObject var object: Object = Object()
```

EnvironmentObject is used for dependency injection, it is used to pass a value to all subviews.
```swift
@EnvironmentObject var object: Object

// somewhere else
ContentView()
    .environmentObject(object)

```


Some other syntax
``` swift
let players = getPlayers()

// Sort players, with best high scores first
let ranked = players.sorted(by: { player1, player2 in
    player1.highScore > player2.highScore
})

// Create an array with only the players’ names
let rankedNames = ranked.map { $0.name }
```
