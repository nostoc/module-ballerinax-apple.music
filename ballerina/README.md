## Overview

[Apple Music](https://music.apple.com/) is Apple's music streaming service that provides access to millions of songs, curated playlists, and personalized music recommendations across all Apple devices and platforms.

The `ballerinax/apple.music` package offers APIs to connect and interact with [Apple Music API](https://developer.apple.com/documentation/applemusicapi) endpoints, specifically based on [Apple Music API v1](https://developer.apple.com/documentation/applemusicapi).
## Setup guide

To use the Apple Music connector, you must have access to the Apple Music API through an [Apple Developer account](https://developer.apple.com/) and obtain API credentials including a developer token. If you do not have an Apple ID, you can create one [here](https://appleid.apple.com/account).

### Step 1: Create an Apple Developer Account

1. Navigate to the [Apple Developer website](https://developer.apple.com/) and sign in with your Apple ID or create one if you don't have an account.

2. Ensure you have an active Apple Developer Program membership ($99/year), as access to the Apple Music API requires enrollment in the Apple Developer Program.

### Step 2: Generate API Credentials

1. Log in to your Apple Developer account at [developer.apple.com](https://developer.apple.com/).

2. Navigate to Certificates, Identifiers & Profiles, then select Keys from the sidebar.

3. Click the "+" button to create a new key, provide a name for your key, and check the "MusicKit" checkbox under Key Services.

4. Click Continue, then Register to generate your private key. Download the .p8 file immediately as it can only be downloaded once.

5. Note your Key ID (displayed after creation) and your Team ID (found in the top-right corner of the developer portal).

> **Tip:** You must copy and store this key somewhere safe. It won't be visible again in your account settings for security reasons.
## Quickstart

To use the `apple.music` connector in your Ballerina application, update the `.bal` file as follows:

### Step 1: Import the module

```ballerina
import ballerinax/apple.music as appleMusic;
```

### Step 2: Instantiate a new connector

1. Create a `Config.toml` file and configure the obtained access tokens:

```toml
authorization = "<Your_Apple_Music_JWT_Token>"
musicUserToken = "<Your_Apple_Music_User_Token>"
```

2. Create an `appleMusic:ApiKeysConfig` and initialize the client:

```ballerina
configurable string authorization = ?;
configurable string musicUserToken = ?;

final appleMusic:Client appleMusicClient = check new({
    authorization,
    musicUserToken
});
```

### Step 3: Invoke the connector operation

Now, utilize the available connector operations.

#### Add a resource to library

```ballerina
public function main() returns error? {
    check appleMusicClient->/me/library.post({
        ids: ["songs:1234567890", "albums:0987654321"]
    });
}
```

### Step 4: Run the Ballerina application

```bash
bal run
```
## Examples

The `apple.music` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-apple.music/tree/main/examples), covering the following use cases:

1. [Music recommendation engine](https://github.com/ballerina-platform/module-ballerinax-apple.music/tree/main/examples/music-recommendation-engine) - Demonstrates how to build a music recommendation system using Ballerina connector for Apple Music.
2. [Album discovery curation](https://github.com/ballerina-platform/module-ballerinax-apple.music/tree/main/examples/album-discovery-curation) - Illustrates creating curated album discovery features and playlists.