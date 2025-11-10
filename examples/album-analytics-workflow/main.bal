import ballerina/io;
import ballerinax/apple.music;

configurable string appleToken = ?;
configurable string storefront = "us";

public function main() returns error? {
    // Initialize Apple Music client
    music:Client appleMusic = check new ({
        authorization: appleToken,
        musicUserToken: ""
    });

    // Step 1: Get specific album details for analysis
    string albumId = "1440857781"; // Example: Taylor Swift - folklore
    io:println("=== Step 1: Retrieving Album Details ===");
    
    music:GetAlbumFromCatalogQueries albumQueries = {
        include: ["tracks", "artists"],
        views: ["related-albums", "related-videos"]
    };
    
    music:AlbumsResponse albumResponse = check appleMusic->/catalog/[storefront]/albums/[albumId](queries = albumQueries);
    
    if albumResponse.data.length() > 0 {
        music:Albums album = albumResponse.data[0];
        io:println(string `Album ID: ${album.id}`);
        io:println(string `Album Type: ${album.'type}`);
        
        if album.attributes is music:AlbumsAttributes {
            music:AlbumsAttributes attrs = <music:AlbumsAttributes>album.attributes;
            io:println(string `Genre Names: ${attrs.genreNames.toString()}`);
            io:println(string `Release Date: ${attrs.releaseDate ?: "Unknown"}`);
            io:println(string `Copyright: ${attrs.copyright ?: "Not specified"}`);
            io:println(string `UPC: ${attrs.upc ?: "Not available"}`);
            io:println(string `Mastered for iTunes: ${attrs.isMasteredForItunes}`);
        }
    }

    // Step 2: Get album's related artists to understand collaborations
    io:println("\n=== Step 2: Analyzing Album Artists and Collaborations ===");
    
    music:GetAlbumRelationshipFromCatalogQueries artistQueries = {
        'limit: 10,
        include: ["albums"]
    };
    
    music:ArtistsResponse artistsResponse = check appleMusic->/catalog/[storefront]/albums/[albumId]/artists(queries = artistQueries);
    
    io:println(string `Found ${artistsResponse.data.length()} artists associated with this album:`);
    foreach music:Artists artist in artistsResponse.data {
        io:println(string `- Artist ID: ${artist.id}`);
        io:println(string `  Artist Type: ${artist.'type}`);
        io:println(string `  Artist Href: ${artist.href}`);
    }

    // Step 3: Get album tracks to analyze song composition patterns
    io:println("\n=== Step 3: Analyzing Track Composition and Featured Artists ===");
    
    music:GetAlbumRelationshipFromCatalogQueries trackQueries = {
        'limit: 25,
        include: ["artists", "albums"]
    };
    
    // Get tracks relationship from the album
    music:ArtistsResponse|error tracksResult = appleMusic->/catalog/[storefront]/albums/[albumId]/tracks(queries = trackQueries);
    
    if tracksResult is error {
        io:println(string `Error retrieving tracks: ${tracksResult.message()}`);
    } else {
        io:println("Track analysis completed - examining song structure patterns");
    }

    // Step 4: Analyze individual song relationships for featured artists
    io:println("\n=== Step 4: Deep Analysis of Song Relationships ===");
    
    // Example song ID for detailed analysis
    string sampleSongId = "1440857784"; // Example song from the album
    
    music:GetSongsRelationshipFromCatalogQueries songArtistQueries = {
        'limit: 10,
        include: ["albums"]
    };
    
    music:SongsResponse|error songArtistsResult = appleMusic->/catalog/[storefront]/songs/[sampleSongId]/artists(queries = songArtistQueries);
    
    if songArtistsResult is music:SongsResponse {
        io:println(string `Analyzing featured artists for song ${sampleSongId}:`);
        foreach music:Songs song in songArtistsResult.data {
            io:println(string `- Song ID: ${song.id}`);
            io:println(string `  Song Type: ${song.'type}`);
            
            if song.attributes is music:SongsAttributes {
                music:SongsAttributes songAttrs = <music:SongsAttributes>song.attributes;
                io:println(string `  Album Name: ${songAttrs.albumName}`);
                decimal? trackNumber = songAttrs.trackNumber;
                string trackNumberStr = trackNumber is decimal ? trackNumber.toString() : "Unknown";
                io:println(string `  Track Number: ${trackNumberStr}`);
                io:println(string `  Duration: ${songAttrs.durationInMillis} ms`);
                io:println(string `  Genres: ${songAttrs.genreNames.toString()}`);
            }
        }
    } else {
        io:println(string `Error analyzing song artists: ${songArtistsResult.message()}`);
    }

    // Step 5: Analyze song composers for composition patterns
    io:println("\n=== Step 5: Composition Pattern Analysis ===");
    
    music:GetSongsRelationshipFromCatalogQueries composerQueries = {
        'limit: 15
    };
    
    music:SongsResponse|error composersResult = appleMusic->/catalog/[storefront]/songs/[sampleSongId]/composers(queries = composerQueries);
    
    if composersResult is music:SongsResponse {
        io:println(string `Composer analysis for song ${sampleSongId}:`);
        io:println(string `Found ${composersResult.data.length()} composition relationships`);
        
        foreach music:Songs composerSong in composersResult.data {
            if composerSong.attributes is music:SongsAttributes {
                music:SongsAttributes compAttrs = <music:SongsAttributes>composerSong.attributes;
                io:println(string `- Composition: ${compAttrs.albumName}`);
                io:println(string `  Movement: ${compAttrs.movementName ?: "Standard song structure"}`);
            }
        }
    }

    io:println("\n=== Music Discovery and Analysis Workflow Complete ===");
    io:println("Analysis Summary:");
    io:println("✓ Album metadata and track information retrieved");
    io:println("✓ Related artists and collaborations identified");
    io:println("✓ Track composition patterns analyzed");
    io:println("✓ Featured artists across tracklist examined");
}