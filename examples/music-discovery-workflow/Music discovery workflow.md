# Music Discovery Workflow

This example demonstrates how to analyze your Apple Music library to discover patterns, explore artist relationships, and build insights for personalized music recommendations using the Apple Music API.

## Prerequisites

1. **Apple Music Setup**
   > Refer the [Apple Music setup guide](https://central.ballerina.io/ballerinax/apple.music/latest#setup-guide) here.

2. For this example, create a `Config.toml` file with your credentials:

```toml
developerToken = "<Your Developer Token>"
userToken = "<Your User Token>"
```

## Run the Example

Execute the following command to run the example. The script will analyze your Apple Music library and print detailed insights to the console.

```shell
bal run
```

The workflow will:
1. Fetch all albums from your personal music library
2. Display detailed information about a selected album
3. Discover connected artists for building recommendations
4. Analyze your collection patterns by genres and artists