# Examples

The `apple.music` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-apple.music/tree/main/examples), covering use cases like music library analysis and music discovery workflow.

1. [Music library analysis](https://github.com/ballerina-platform/module-ballerinax-apple.music/tree/main/examples/music-library-analysis) - Analyze user's music library to provide insights on listening patterns and preferences.

2. [Music discovery workflow](https://github.com/ballerina-platform/module-ballerinax-apple.music/tree/main/examples/music-discovery-workflow) - Create a workflow to discover new music based on user preferences and listening history.

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