# Music Library Discovery

This example demonstrates how to discover new music and manage your personal Apple Music library by fetching current library albums, discovering new albums, and adding them to your personal collection.

## Prerequisites

1. **Apple Music Setup**
   > Refer to the [Apple Music setup guide](https://central.ballerina.io/ballerinax/apple.music/latest#setup-guide) to obtain the necessary credentials.

2. For this example, create a `Config.toml` file with your credentials:

```toml
developerToken = "<Your Developer Token>"
userToken = "<Your User Token>"
storefront = "us"
```

## Run the example

Execute the following command to run the example. The script will print its progress to the console.

```shell
bal run
```

The script will:
1. Fetch your current library albums
2. Discover new albums to add (using example Beatles album IDs)
3. Add the new albums to your personal library
4. Verify the albums were successfully added by displaying your updated library