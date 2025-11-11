# Music Artist Discovery

This example demonstrates how to build a music discovery service using the Apple Music API to search for songs, retrieve artist information, and find similar artists for personalized recommendations.

## Prerequisites

1. **Apple Music Setup**
   > Refer the [Apple Music setup guide](https://central.ballerina.io/ballerinax/apple.music/latest#setup-guide) here.

2. For this example, create a `Config.toml` file with your credentials:

```toml
developerToken = "<Your Developer Token>"
```

## Run the Example

Execute the following command to run the example. The script will print its progress to the console.

```bash
bal run
```

The application will:
1. Search for "bohemian rhapsody" in the Apple Music catalog
2. Retrieve artist information for a specific song
3. Find similar artists based on the primary artist
4. Display personalized music recommendations