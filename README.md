# Pictograph
Pictograph is the best steganography app available for iOS and macOS. Easily send hidden messages to anyone you want. You can even encrypt the messages with a password.

Note: This project was compiled using Xcode 9. If you're still using Xcode 8, use this commit: 861deaa163d121af2b7058afe9d50f45b73dba96.

## Contents
* [Downloading](#downloading)
* [Steganography](#steganography)
* [Encryption](#encryption)
* [Author](#author)
* [Changelog](#changelog)
* [License](#license)

## Downloading

You can download Pictograph Mac [here](http://adamjboyd.com/Pictograph.zip). You can get Pictograph iOS on the App Store [here](https://itunes.apple.com/us/app/pictograph-hide-messages-in-plain-sight/id1051879856?ls=1&mt=8).

## Steganography

Steganography is the practice of hiding messages in plain sight. Pictograph works by changing the least significant bits in each pixel in a specific way so that a message can be hidden. Because Pictograph only changes the least significant bits in a pixel, the change is imperceptible to human eyes.

## Encryption

AES-256 encryption is used in Pictograph when encryption is enabled. This encryption is incredibly hard to break, so rest assured your message will be safe if you choose to encrypt it.

Pictograph uses the publicly available [RNCryptor](https://github.com/RNCryptor/RNCryptor) library for encryption and decryption.

## Author
My name is Adam Boyd.

Your best bet to contact me is on Twitter. [@MrAdamBoyd](https://twitter.com/MrAdamBoyd)

My website is [adamjboyd.com](http://www.adamjboyd.com).

## Changelog
1.0: Initial Release

1.1: iPad support

1.2: Night mode

1.3: Simplified UI

1.4: Ability to hide images

1.5: iOS 11 support/design changes

1.6: Ability to hide a message and an image at the same time

## License

MIT
