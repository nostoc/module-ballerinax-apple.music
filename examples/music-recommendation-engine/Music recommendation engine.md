# Music Recommendation Engine

This example demonstrates how to build a music recommendation engine using the Apple Music API to search for tracks, get recommendations, and retrieve detailed music information.

## Prerequisites

1. **Apple Music Setup**
   > Refer the [Apple Music setup guide](https://central.ballerina.io/ballerinax/apple.music) here.

2. For this example, create a `Config.toml` file with your credentials:

```toml
bearerToken = "<Your Apple Music Bearer Token>"
storefront = "us"
```

## Run the example

Execute the following command to run the example. The script will print its progress to the console.

```shell
bal run
```