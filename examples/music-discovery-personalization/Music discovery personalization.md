# Music Discovery Personalization

This example demonstrates how to build a personalized music discovery system using the Apple Music API. The script searches for trending rock artists, analyzes their top songs and latest releases, applies personalization logic based on user preferences, and automatically adds matching tracks to the user's personal library.

## Prerequisites

1. **Apple Music Setup**
   > Refer to the [Apple Music setup guide](https://central.ballerina.io/ballerinax/apple.music/latest#setup-guide) to obtain the necessary credentials.

2. For this example, create a `Config.toml` file with your credentials:

```toml
userToken = "<Your User Token>"
developerToken = "<Your Developer Token>"
storefront = "us"
```

## Run the Example

Execute the following command to run the example. The script will print its progress to the console.

```shell
bal run
```

The script will:
1. Search for trending rock artists
2. Analyze their top songs and latest releases
3. Apply personalization logic to match user preferences
4. Add recommended tracks to your Apple Music library
5. Display a comprehensive personalization summary