# Hashcash

Proof-of-work algorithm implemented in pure Swift based on CryptoKit.
Both SHA-256 and SHA-1 are supported.

Supports minting new stamps (generating proof) and validating stamps. 

Read more about the idea and applications of this algorithm on [Wikipedia](https://en.wikipedia.org/wiki/Hashcash)


## Usage

Generate new stamp:
```swift
let hashcash = Hashcash()
let stamp = hashcash.mint(resource: "resources to encode")
print(stamp.encodedValue)  // -> String
```


Validate stamp from different source:
```swift
let encodedStamp = "1:20:210324:hello::gemqijJM/8VRm6ij:1C2EB1"
let stamp = try! Stamp(encodedValue: encodedStamp)
hashcash.check(stamp: stamp)  // -> Bool
```

The `Hashcash` object contains among other things information about how hard the challenge should be and the hash algorithm to use. Increase `bits` to make the challenge harder (default: 20). Each increment by one, doubles the difficulty and therefore the time it takes:
```swift
let harderHashcash = Hashcash(bits: 22)  // 4x as hard as default
```

**Note:** UTC date time is used when creating and validating stamps
