# Music Library Analysis

This example demonstrates how to analyze a user's Apple Music library by retrieving albums, examining their relationships, and fetching detailed catalog information for building comprehensive music profiles and recommendation algorithms.

## Prerequisites

1. **Apple Music Setup**
   > Refer the [Apple Music setup guide](https://central.ballerina.io/ballerinax/apple.music/latest) here.

2. For this example, create a `Config.toml` file with your credentials:

```toml
developerToken = "<Your Developer Token>"
userToken = "<Your User Token>"
```

## Run the Example

Execute the following command to run the example. The script will print its progress to the console.

```shell
bal run
```

The script will perform the following analysis steps:

1. **Fetch User Library Albums** - Retrieves up to 25 albums from your personal Apple Music library
2. **Analyze Album Relationships** - For each album, fetches associated artists, genres, and record label information
3. **Retrieve Catalog Details** - Gets comprehensive catalog information for sample albums including release dates, genres, and technical details

The output will show detailed information about your music library, including album names, artists, genres, and metadata that can be used for music recommendation systems.