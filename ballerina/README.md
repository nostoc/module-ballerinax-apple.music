## Overview

[Apple Music](https://www.apple.com/apple-music/) is a music and video streaming service developed by Apple Inc., offering users access to millions of songs, curated playlists, and exclusive content across all their devices.

The `ballerinax/apple.music` package offers APIs to connect and interact with [Apple Music API](https://developer.apple.com/documentation/applemusicapi) endpoints, specifically based on [Apple Music API v1](https://developer.apple.com/documentation/applemusicapi).
## Setup guide

To use the Apple Music connector, you must have access to the Apple Music API through an [Apple Developer account](`https://developer.apple.com/`) and obtain an API access token. If you do not have an Apple ID, you can sign up for one [here](`https://appleid.apple.com/account`).

### Step 1: Create an Apple Developer Account

1. Navigate to the [Apple Developer website](`https://developer.apple.com/`) and sign up for a developer account or log in if you already have one.

2. Ensure you have an active Apple Developer Program membership ($99/year), as the Apple Music API requires enrollment in the Apple Developer Program.

### Step 2: Generate an API Access Token

1. Log in to your Apple Developer account.

2. Navigate to Certificates, Identifiers & Profiles, then select Keys from the sidebar.

3. Click the "+" button to create a new key, provide a name for your key, and check the "MusicKit" checkbox under Key Services.

4. Click Continue, then Register to generate your key. Download the .p8 file immediately as it can only be downloaded once.

5. Note your Key ID and Team ID, which you'll need along with the private key file to generate JWT tokens for API authentication.

> **Tip:** You must copy and store this key somewhere safe. It won't be visible again in your account settings for security reasons.
## Quickstart

To use the `apple.music` connector in your Ballerina application, update the `.bal` file as follows:

### Step 1: Import the module

```ballerina
import ballerinax/apple.music;
```

### Step 2: Instantiate a new connector

Create an `apple.music:ConnectionConfig` and initialize the client:

```ballerina
final music:Client appleMusicClient = check new("https://api.music.apple.com/v1");
```

### Step 3: Invoke the connector operation

Now, utilize the available connector operations.

#### Get multiple catalog albums

```ballerina
public function main() returns error? {
    music:AlbumsResponse response = check appleMusicClient->/catalog/["us"]/albums.get({
        ids: ["1440857781", "1440857782"]
    });
}
```

### Step 4: Run the Ballerina application

```bash
bal run
```
## Examples

The `apple.music` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-apple.music/tree/main/examples), covering the following use cases:

1. [Global album availability analysis](https://github.com/ballerina-platform/module-ballerinax-apple.music/tree/main/examples/global-album-availability-analysis) - Demonstrates how to analyze album availability across different global markets using the Apple Music API.