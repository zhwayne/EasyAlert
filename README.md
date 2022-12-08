# EasyAlert

[![CI Status](https://img.shields.io/travis/zhwayne/EasyAlert.svg?style=flat)](https://travis-ci.org/zhwayne/EasyAlert)
[![Version](https://img.shields.io/cocoapods/v/EasyAlert.svg?style=flat)](https://cocoapods.org/pods/EasyAlert)
[![License](https://img.shields.io/cocoapods/l/EasyAlert.svg?style=flat)](https://cocoapods.org/pods/EasyAlert)
[![Platform](https://img.shields.io/cocoapods/p/EasyAlert.svg?style=flat)](https://cocoapods.org/pods/EasyAlert)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Usage

Example for `MessageAlert`:
```swift
let alert = MessageAlert(title: "Error", message: "\(error)")
let cancel = Action(title: "Cancel", style: .cancel)
let ok = Action(title: "OK", style: .default) { _ in
    if let url = result.videoURL {
        self?.showVideo(url: url)
    }
}
alert.addAction(cancel)
alert.addAction(ok)
alert.show(in: view)
```

## Installation

EasyAlert is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'EasyAlert', :git => 'git@github.com:zhwayne/EasyAlert.git', :branch => 'main'
```

## Author

张尉, mrzhwayne@163.com

## License

EasyAlert is available under the MIT license. See the LICENSE file for more info.
