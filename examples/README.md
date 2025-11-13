# Examples

The `apple.music` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-apple.music/tree/main/examples), covering use cases like music recommendation profiling, and music library curation.

1. [Music recommendation profiling](https://github.com/ballerina-platform/module-ballerinax-apple.music/tree/main/examples/music-recommendation-profiling) - Analyze user listening patterns and preferences to create personalized music recommendation profiles.

2. [Music library curation](https://github.com/ballerina-platform/module-ballerinax-apple.music/tree/main/examples/music-library-curation) - Organize and manage music collections by automatically curating playlists based on specific criteria.

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