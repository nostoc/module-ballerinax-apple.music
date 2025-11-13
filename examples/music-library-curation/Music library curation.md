# Music Library Curation

This example demonstrates how to discover and curate music using the Apple Music API. The script searches for an artist, explores their discography, selects albums for a personal library, and checks for latest releases.

## Prerequisites

1. **Apple Music Setup**
   > Refer to the [Apple Music setup guide](https://central.ballerina.io/ballerinax/apple.music/latest) to obtain the required credentials.

2. For this example, create a `Config.toml` file with your credentials:

```toml
appleTeamId = "<Your Apple Team ID>"
appleKeyId = "<Your Apple Key ID>"
applePrivateKey = "<Your Apple Private Key>"
```

## Run the example

Execute the following command to run the example. The script will print its progress to the console.

```shell
bal run
```