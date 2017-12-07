# URLRouter

## CocoaPods

```
use_frameworks!
pod 'YFURLRouter'
```

## Usage

### 1. DefaultURLMatcher

默认的匹配规则:
>matching rules:

1.scheme://user/Tommy  ->  scheme://user/<name>
* match succeeds
* parameters: ["name": "Tommy"]

2.scheme://user/Tommy/22  ->  scheme://user/<name>/<age>
* match succeeds
* parameters: ["name": "Tommy", "age": "22"]

3.scheme://user/Tommy?age=22&sex=boy  ->  scheme://user/<name>
* match succeeds
* parameters: ["name": "Tommy", "age": "22", "sex": "boy"]

4.scheme://user/Tommy?age=22&sex=boy  ->  scheme://user/<name>?<age,sex>
* match succeeds
* parameters: ["name": "Tommy", "age": "22", "sex": "boy"]

5.scheme://user/Tommy  ->  scheme://user/<name>?<age,sex>
* match fails

#### Example:
#### (1)
```swift
let registerURL = "URLRouter://user/<name>"
let openURL     = "URLRouter://user/Tommy?age=22"
URLRouter.shared.register(registerURL) { [weak self] (url, parameters, context) in
    self?.log(registerURL, url, parameters, context)
}

URLRouter.shared.open(openURL, context: nil)
/*
url: URLRouter://user/Tommy?age=22
parameters: ["name": "Tommy", "age": "22"]
context: nil
*/
```

#### (2)
```swift
let registerURL = "URLRouter://user/<name>/<path>"
let openURL     = "URLRouter://user/Tommy/lalala/22"
URLRouter.shared.register(registerURL) { [weak self] in self?.log(registerURL, $0, $1, $2) }
URLRouter.shared.open(openURL, context: nil)

/*
url: URLRouter://user/Tommy/lalala/22
parameters: ["name": "Tommy", "path": "lalala/22"]
context: nil
*/
```
#### (3)
```swift
let registerURL = "URLRouter://user/<name>?<age,sex>"
let openURL     = "URLRouter://user/Tommy?age=22&sex=boy"
URLRouter.shared.register(registerURL) { [weak self] in self?.log(registerURL, $0, $1, $2) }
URLRouter.shared.open(openURL, context: nil)
/*
url: URLRouter://user/Tommy?age=22&sex=boy
parameters: ["name": "Tommy", "age": "22", "sex": "boy"]
context: nil
*/
```

### 2.RegexURLMatcher
通过正则表达式匹配 URL
>URLMatcher with regular expression

1.scheme://user/Tommy?age=22&sex=boy  ->  scheme://user/\\w+\\?age=\\d+&sex=\\w+
* match succeeds
* parameters: ["age": "22", "sex": "boy"]

2.scheme://user/123  ->  scheme://user/\\w+
* match fails

通过以下代码改变匹配规则
>How to use RegexURLMatcher:
```swift
URLRouter.shared.urlMatcher = .regex
```

#### example

```swift
let registerURL = "URLRouter://user/\\w+\\?age=\\d+&sex=\\w+"
let openURL     = "URLRouter://user/Tommy?age=22&sex=boy"
URLRouter.shared.register(registerURL) { [weak self] in self?.log(registerURL, $0, $1, $2) }

// ⚠️⚠️⚠️⚠️⚠️⚠️
URLRouter.shared.urlMatcher = .regex
URLRouter.shared.open(openURL, context: nil)
/*
url: URLRouter://user/Tommy?age=22&sex=boy
parameters: ["age": "22", "sex": "boy"]
context: nil
*/
```

### 3.Route With Context

路由的时候带上自定义内容

```swift
let registerURL = "URLRouter://user/<name>"
let openURL     = "URLRouter://user/Tommy"
URLRouter.shared.register(registerURL) { [weak self] (url, parameters, context) in
    self?.log(registerURL, url, parameters, context)
}
URLRouter.shared.open(openURL, context: Person(name: "Xixi"))
/*
url: URLRouter://user/Tommy
parameters: ["name": "Tommy"]
context: Person(name: "Xixi")
*/
```
### 4.Route Object

URL 绑定 Object，路由时返回一个 Object

```swift
let registerURL = "URLRouter://object/user/<name>"
let openURL     = "URLRouter://object/user/Tommy"
URLRouter.shared.registerObject(registerURL) { [weak self] in
    self?.log(registerURL, $0, $1, $2)
    return Person(name: $1["name"]!)
}
let user: Person? = URLRouter.shared.object(for: openURL)
/*
url: URLRouter://object/user/Tommy
parameters: ["name": "Tommy"]
context: nil
user: Person(name: "Tommy")
*/
```

### 5.Push ViewController

#### (1) 直接在 Handle 中实现
>#### (1) implementation with URLHandle
```swift
let registerURL = "URLRouter://pushViewController"
let openURL     = "URLRouter://pushViewController?backgroudColor=red"
URLRouter.shared.register(registerURL) { [weak self] in
    self?.log(registerURL, $0, $1, $2)
    let vc = UIViewController()
    if $1["backgroudColor"] == "red" {
        vc.view.backgroundColor = .red
    }
    self?.navigationController?.pushViewController(vc, animated: true)
}

URLRouter.shared.open(openURL, context: nil)
/*
url: URLRouter://pushViewController?backgroudColor=red
parameters: ["backgroudColor": "red"]
context: nil
*/
```
#### (2) 路由得到 ViewController 再 push
>#### (2) implementation with Object
```swift
let registerURL = "URLRouter://viewControler"
let openURL     = "URLRouter://viewControler?backgroudColor=blue"
URLRouter.shared.registerObject(registerURL) { [weak self] in
    self?.log(registerURL, $0, $1, $2)
    let vc = UIViewController()
    if $1["backgroudColor"] == "blue" {
        vc.view.backgroundColor = .blue
        }
    return vc
}

if let viewController: UIViewController = URLRouter.shared.object(for: openURL) {
    navigationController?.pushViewController(viewController, animated: true)
}
```

### 6.CustomURLMatcher

使用自定义的匹配规则匹配 URL 进行路由。只要让 class 实现 URLMatcherType 协议，并通过 ```URLRouter.shared.urlMatcher = .custom(...)``` 设置它。

>Using a custom matching rule.Your custom URLMatcher should implement URLMatcherType protocol and using ```URLRouter.shared.urlMatcher = .custom(...)``` set it.

```swift
class CustomURLMatcher: URLMatcherType {
    func match(_ url: URLType, from registeredURLs: [URLType]) -> URLMatchResult {
        // do something
        
        //return .success(registeredURL: registeredURL, parameters: [:])
        return .fail
    }
}
```

```swift
let registerURL = "A://"
let openURL     = "A://user/Tommy"
URLRouter.shared.register(registerURL) { [weak self] in
    self?.log(registerURL, $0, $1, $2)
}

// ⚠️⚠️⚠️⚠️⚠️⚠️
URLRouter.shared.urlMatcher = .custom(CustomURLMatcher())
URLRouter.shared.open(openURL)
```
