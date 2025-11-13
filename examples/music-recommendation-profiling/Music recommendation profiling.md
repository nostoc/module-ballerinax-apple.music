# Music Recommendation Profiling

This example demonstrates how to build a comprehensive music taste profile by analyzing a user's Apple Music library. The script retrieves songs from the user's library and analyzes their genres, artists, and albums to create detailed listening preferences that can be used for music recommendations.

## Prerequisites

1. **Apple Music Setup**
   > Refer the [Apple Music setup guide](https://central.ballerina.io/ballerinax/apple.music/latest#setup-guide) here.

2. For this example, create a `Config.toml` file with your credentials:

```toml
developerToken = "<Your Developer Token>"
musicUserToken = "<Your Music User Token>"
```

## Run the Example

Execute the following command to run the example. The script will print its progress to the console.

```shell
bal run
```

The script will:
1. Fetch songs from your Apple Music library
2. Analyze each song's genres, artists, and albums
3. Build a comprehensive taste profile with statistics
4. Display your music preferences and listening patterns