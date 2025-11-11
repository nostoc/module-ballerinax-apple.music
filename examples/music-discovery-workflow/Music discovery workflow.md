# Music Discovery Workflow

This example demonstrates how to create a music discovery workflow using the Apple Music API to search for tracks, retrieve detailed song information, and explore artist catalogs.

## Prerequisites

1. **Apple Music Setup**
   > Refer to the [Apple Music setup guide](https://central.ballerina.io/ballerinax/apple.music) to obtain the necessary credentials and configure your developer account.

2. For this example, create a `Config.toml` file with your credentials:

```toml
bearerToken = "<Your Apple Music Bearer Token>"
```

## Run the example

Execute the following command to run the example. The script will demonstrate music discovery operations and print the results to the console.

```shell
bal run
```