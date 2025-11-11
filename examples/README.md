# Examples

The `apple.music` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-apple.music/tree/main/examples), covering use cases like album details aggregation, and music discovery library.

1. [Album details aggregation](https://github.com/ballerina-platform/module-ballerinax-apple.music/tree/main/examples/album-details-aggregation) - Aggregate detailed information about albums from Apple Music.

2. [Music discovery library](https://github.com/ballerina-platform/module-ballerinax-apple.music/tree/main/examples/music-discovery-library) - Build a music discovery library using Apple Music's catalog and recommendation features.

## Prerequisites

1. Generate Apple Music credentials to authenticate the connector as described in the [Setup guide](https://central.ballerina.io/ballerinax/apple.music/latest#setup-guide).

2. For each example, create a `Config.toml` file the related configuration. Here's an example of how your `Config.toml` file should look:

    ```toml
    token = "<Access Token>"
    ```

## Running an Example

Execute the following commands to build an example from the source:

* To build an example:

    ```bash
    bal build
    ```

* To run an example:

    ```bash
    bal run
    ```