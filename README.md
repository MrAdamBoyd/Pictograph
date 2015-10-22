# Pictograph
Pictograph is the best steganography app available for iOS. Easily send hidden messages to anyone you want. You can even encrypt the messages with a password.

[![CI Status](http://img.shields.io/travis/Adam Boyd/SwiftBus.svg?style=flat)](https://travis-ci.org/Adam Boyd/SwiftBus)
[![Version](https://img.shields.io/cocoapods/v/SwiftBus.svg?style=flat)](http://cocoapods.org/pods/SwiftBus)
[![License](https://img.shields.io/cocoapods/l/SwiftBus.svg?style=flat)](http://cocoapods.org/pods/SwiftBus)
[![Platform](https://img.shields.io/cocoapods/p/SwiftBus.svg?style=flat)](http://cocoapods.org/pods/SwiftBus)

## Contents
* [Steganography](#steganography)
* [Encryption](#encryption)
* [Requirements](#requirements)
* [NSAppTransportSecurity](#nsapptransportsecurity)
* [Author](#author)
* [Changelog](#changelog)
* [License](#license)

## Steganography

Steganography is the practice of hiding messages in plain sight. Pictograph changes the least significant bits in an to hide the message. And because each pixel is changed only a very small amount, the change is imperceptible to human eyes.

## Encryption

AES-256 encryption is used in Pictograph when encryption is enabled. This encryption is incredibly hard to break, so rest assured your message will be safe if you choose to encrypt it.

Pictograph uses the publicly available [RNCryptor](https://github.com/RNCryptor/RNCryptor) library for encryption and decryption.

## Author
My name is Adam Boyd.

Your best bet to contact me is on Twitter. [@MrAdamBoyd](https://twitter.com/MrAdamBoyd)

My website is [adamjboyd.com](http://www.adamjboyd.com).

## Changelog
1.0: Initial Release

## License

MIT
