# Music Discovery Workflow

This example demonstrates how to build a personalized music discovery feature using Apple Music's API. The script analyzes a user's personal library to fetch their artists, albums, and track information, which can then be used to build recommendation engines and personalized playlists.

## Prerequisites

1. **Apple Music Setup**
   > Refer to the [Apple Music setup guide](https://central.ballerina.io/ballerinax/apple.music/latest#setup-guide) to obtain the required credentials.

2. For this example, create a `Config.toml` file with your credentials:

```toml
appleJWT = "<Your Apple JWT Token>"
appleUserToken = "<Your Apple User Token>"
```

## Run the Example

Execute the following command to run the example. The script will analyze your music library and print its progress to the console.

```shell
bal run
```

The script will:
- Fetch artists from your personal Apple Music library
- Analyze albums and tracks for each artist
- Display detailed information about your music collection
- Provide insights for building recommendation features