# Music Library Analysis

This example demonstrates how to analyze music library data using the Apple Music API. The script connects to Apple Music services to retrieve and process music library information.

## Prerequisites

1. **Apple Music Setup**
   > Refer the [Apple Music setup guide](https://central.ballerina.io/ballerinax/apple.music) here.

2. For this example, create a `Config.toml` file with your credentials:

```toml
# Apple Music API configuration
keyId = "<Your Key ID>"
teamId = "<Your Team ID>"
privateKey = "<Your Private Key>"
```

## Run the example

Execute the following command to run the example. The script will print its progress to the console.

```shell
bal run
```

The script will connect to the Apple Music API and analyze your music library data, displaying the results in the terminal.