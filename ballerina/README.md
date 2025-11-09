## Overview

[Apple Music](https://www.apple.com/apple-music/) is Apple's music streaming service that provides access to millions of songs, curated playlists, and personalized recommendations, allowing users to discover, stream, and enjoy music across all their devices.

The `ballerinax/apple.music` package offers APIs to connect and interact with [Apple Music API](https://developer.apple.com/documentation/applemusicapi) endpoints, specifically based on a recent version of the API.
## Setup guide

To use the Apple Music connector, you must have access to the Apple Music API through an [Apple Developer account](`https://developer.apple.com/`) and obtain API credentials including a private key and key ID. If you do not have an Apple ID, you can sign up for one [here](`https://appleid.apple.com/account`).

### Step 1: Create an Apple Developer Account

1. Navigate to the [Apple Developer website](`https://developer.apple.com/`) and sign up for a developer account or log in if you already have one.

2. Ensure you have a paid Apple Developer Program membership ($99/year), as the Apple Music API access requires an active developer program enrollment.

### Step 2: Generate API Credentials

1. Log in to your Apple Developer account.

2. Navigate to Certificates, Identifiers & Profiles, then select Keys from the left sidebar.

3. Click the "+" button to create a new key, provide a name for your key, and check the "MusicKit" checkbox under Key Services.

4. Click Continue, then Register to generate your key. Download the private key file (.p8) and note the Key ID displayed.

5. Also note your Team ID, which can be found in the top-right corner of the Apple Developer portal or in your membership details.

> **Tip:** You must copy and store this private key file and credentials somewhere safe. The private key file can only be downloaded once for security reasons.
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

#### Add songs to library

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

1. [Music discovery recommendations](https://github.com/ballerina-platform/module-ballerinax-apple.music/tree/main/examples/music-discovery-recommendations) - Demonstrates how to discover and recommend music content using Ballerina connector for Apple Music.
2. [Music recommendation engine](https://github.com/ballerina-platform/module-ballerinax-apple.music/tree/main/examples/music-recommendation-engine) - Illustrates building a music recommendation system based on user preferences and listening history.