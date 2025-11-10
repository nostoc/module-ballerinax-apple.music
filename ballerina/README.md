## Overview

[Apple Music](https://www.apple.com/apple-music/) is Apple's music streaming service that provides access to over 100 million songs, curated playlists, and personalized recommendations, allowing users to discover, stream, and enjoy music across all their devices.

The `ballerinax/apple.music` package offers APIs to connect and interact with [Apple Music API](https://developer.apple.com/documentation/applemusicapi) endpoints, specifically based on a recent version of the API.
## Setup guide

To use the Apple Music connector, you must have access to the Apple Music API through an [Apple Developer account](`https://developer.apple.com/`) and obtain an API access token. If you do not have an Apple ID, you can sign up for one [here](`https://appleid.apple.com/account`).

### Step 1: Create an Apple Developer Account

1. Navigate to the [Apple Developer website](`https://developer.apple.com/`) and sign up for an account or log in if you already have one.

2. Ensure you have an active Apple Developer Program membership ($99/year), as the Apple Music API requires enrollment in the Apple Developer Program.

### Step 2: Generate an API Access Token

1. Log in to your Apple Developer account.

2. Navigate to Certificates, Identifiers & Profiles, then select Keys from the sidebar.

3. Click the "+" button to create a new key, provide a name for your key, and check the "MusicKit" checkbox under Key Services.

4. Click Continue, then Register to generate your key. Download the .p8 private key file and note your Key ID and Team ID, as you'll need these to generate JWT tokens for API authentication.

> **Tip:** You must copy and store this key somewhere safe. It won't be visible again in your account settings for security reasons.
## Quickstart

To use the `apple.music` connector in your Ballerina application, update the `.bal` file as follows:

### Step 1: Import the module

```ballerina
import ballerinax/apple.music as appleMusic;
```

### Step 2: Instantiate a new connector

1. Create a `Config.toml` file and configure the obtained access token:

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
        ids: ["songs:123456789", "albums:987654321"]
    });
}
```

### Step 4: Run the Ballerina application

```bash
bal run
```
## Examples

The `Apple Music` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-apple.music/tree/main/examples), covering the following use cases:

1. [Music library analysis](https://github.com/ballerina-platform/module-ballerinax-apple.music/tree/main/examples/music-library-analysis) - Demonstrates how to analyze music library data using Ballerina connector for Apple Music.
2. [Music discovery workflow](https://github.com/ballerina-platform/module-ballerinax-apple.music/tree/main/examples/music-discovery-workflow) - Illustrates implementing automated music discovery and recommendation workflows.