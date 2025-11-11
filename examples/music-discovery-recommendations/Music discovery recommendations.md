# Music Discovery Recommendations

This example demonstrates how to build a personalized music discovery system using the Apple Music API. The script searches for music based on a query term, explores artist details and relationships, and generates recommendations by analyzing top songs, albums, and similar artists.

## Prerequisites

1. **Apple Music Setup**
   > Refer to the [Apple Music setup guide](https://central.ballerina.io/ballerinax/apple.music/latest#setup-guide) to obtain the necessary credentials.

2. For this example, create a `Config.toml` file with your credentials:

```toml
developerToken = "<Your Developer Token>"
musicUserToken = "<Your Music User Token>"
storefront = "us"
```

## Run the Example

Execute the following command to run the example. The script will print its progress to the console as it discovers music and generates recommendations.

```shell
bal run
```

The script will:
- Search for songs and artists based on the configured search term
- Retrieve detailed information about found artists
- Explore artist relationships, albums, and top songs
- Generate personalized recommendations from multiple related artists
- Display a comprehensive summary of the discovery process