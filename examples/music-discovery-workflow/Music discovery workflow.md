# Music Discovery Workflow

This example demonstrates how to automate music discovery and library management using the Apple Music API. The workflow searches for a favorite artist, explores their top songs and latest releases, and automatically adds discovered tracks to your personal music library.

## Prerequisites

1. **Apple Music Setup**
   > Refer to the [Apple Music setup guide](https://central.ballerina.io/ballerinax/apple.music/latest#setup-guide) to obtain the required credentials.

2. For this example, create a `Config.toml` file with your credentials:

```toml
accessToken = "<Your Access Token>"
keyId = "<Your Key ID>"
teamId = "<Your Team ID>"
privateKey = "<Your Private Key>"
```

## Run the example

Execute the following command to run the example. The script will print its progress to the console as it searches for music, explores artist content, and manages your library.

```shell
bal run
```