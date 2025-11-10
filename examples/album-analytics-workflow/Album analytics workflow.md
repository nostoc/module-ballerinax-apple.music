# Album Analytics Workflow

This example demonstrates how to build an automated workflow for analyzing album performance using Apple Music data integration.

## Prerequisites

1. **Apple Music Setup**
   > Refer the [Apple Music setup guide](https://central.ballerina.io/ballerinax/apple.music) here.

2. For this example, create a `Config.toml` file with your credentials:

```toml
# Apple Music API configuration
developerToken = "<Your Apple Music Developer Token>"
teamId = "<Your Team ID>"
keyId = "<Your Key ID>"
privateKey = "<Your Private Key>"
```

## Run the example

Execute the following command to run the example. The script will print its progress to the console.

```shell
bal run
```

The workflow will:
- Connect to Apple Music API
- Retrieve album data and analytics
- Process and analyze the music data
- Display the results in the console