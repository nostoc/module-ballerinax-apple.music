import ballerina/io;
import ballerinax/apple.music;

configurable string userToken = ?;
configurable string developerToken = ?;
configurable string storefront = "us";

public function main() returns error? {
    // Initialize Apple Music client
    music:Client appleMusicClient = check new({
        authorization: developerToken,
        musicUserToken: userToken
    });

    io:println("🎵 Starting Music Discovery and Personalization System");
    string separator = "";
    int separatorCount = 0;
    while separatorCount < 60 {
        separator = separator + "=";
        separatorCount = separatorCount + 1;
    }
    io:println(separator);

    // Step 1: Search for trending artists in a specific genre (rock)
    io:println("\n📊 Step 1: Searching for trending rock artists...");
    
    "activities"|"albums"|"apple-curators"|"artists"|"curators"|"music-videos"|"playlists"|"record-labels"|"songs"|"stations"[] searchTypes = ["artists"];
    
    music:SearchResponse searchResponse = check appleMusicClient->/catalog/[storefront]/search(
        term = "rock+artists+trending",
        types = searchTypes,
        'limit = 10
    );

    music:ArtistsResponse? artistsResponseOptional = searchResponse.results.artists;
    if artistsResponseOptional is music:ArtistsResponse {
        music:ArtistsResponse artistsResponse = artistsResponseOptional;
        io:println(string `Found ${artistsResponse.data.length()} trending rock artists`);
        
        // Step 2: Analyze top songs and latest releases for each artist
        io:println("\n🎵 Step 2: Analyzing top songs and latest releases...");
        
        string[] recommendedTrackIds = [];
        
        foreach music:Artists artist in artistsResponse.data {
            io:println(string `\nAnalyzing artist: ${artist.id}`);
            
            // Get top songs for the artist
            music:AlbumsResponse|error topSongsResult = appleMusicClient->/catalog/[storefront]/artists/[artist.id]/view/["top-songs"](
                'limit = 5
            );
            
            if topSongsResult is music:AlbumsResponse {
                io:println(string `  - Found ${topSongsResult.data.length()} top songs`);
                
                // Analyze songs for personalization (simulate preference matching)
                foreach music:Albums album in topSongsResult.data {
                    if isMatchingUserPreferences(album) {
                        recommendedTrackIds.push(album.id);
                        io:println(string `  - Added to recommendations: ${album.id}`);
                    }
                }
            }
            
            // Get latest releases for the artist
            music:AlbumsResponse|error latestReleaseResult = appleMusicClient->/catalog/[storefront]/artists/[artist.id]/view/["latest-release"](
                'limit = 3
            );
            
            if latestReleaseResult is music:AlbumsResponse {
                io:println(string `  - Found ${latestReleaseResult.data.length()} latest releases`);
                
                // Analyze latest releases for personalization
                foreach music:Albums album in latestReleaseResult.data {
                    if isMatchingUserPreferences(album) {
                        recommendedTrackIds.push(album.id);
                        io:println(string `  - Added latest release to recommendations: ${album.id}`);
                    }
                }
            }
            
            // Limit recommendations to avoid overwhelming the user
            if recommendedTrackIds.length() >= 15 {
                break;
            }
        }

        // Step 3: Add recommended tracks to user's personal library
        if recommendedTrackIds.length() > 0 {
            io:println(string `\n📚 Step 3: Adding ${recommendedTrackIds.length()} recommended tracks to your library...`);
            
            error? addToLibraryResult = appleMusicClient->/me/library.post(
                ids = recommendedTrackIds
            );
            
            if addToLibraryResult is () {
                io:println("✅ Successfully added recommended tracks to your library!");
            } else {
                io:println(string `❌ Error adding tracks to library: ${addToLibraryResult.message()}`);
            }
        } else {
            io:println("\n📚 No tracks matched your preferences for library addition.");
        }

        // Step 4: Display personalization summary
        io:println("\n📈 Personalization Summary:");
        string summarySeparator = "";
        int summaryCount = 0;
        while summaryCount < 40 {
            summarySeparator = summarySeparator + "=";
            summaryCount = summaryCount + 1;
        }
        io:println(summarySeparator);
        io:println(string `Total artists analyzed: ${artistsResponse.data.length()}`);
        io:println(string `Tracks recommended: ${recommendedTrackIds.length()}`);
        io:println("Recommendation criteria: Rock genre, recent releases, high popularity");
        io:println("Next steps: Monitor listening patterns for refined recommendations");
        
    } else {
        io:println("No artists found for the specified genre.");
    }
    
    io:println("\n🎵 Music Discovery and Personalization Complete!");
}

// Simulate user preference matching logic
function isMatchingUserPreferences(music:Albums album) returns boolean {
    // Simulate personalization logic based on user's musical preferences
    // In a real implementation, this would analyze:
    // - User's listening history
    // - Preferred genres from album.attributes.genreNames
    // - Release date preferences
    // - Artist similarity scores
    
    music:AlbumsAttributes? attributesOptional = album.attributes;
    if attributesOptional is music:AlbumsAttributes {
        music:AlbumsAttributes attributes = attributesOptional;
        
        // Check if album matches preferred genres (rock and related)
        string[] preferredGenres = ["Rock", "Alternative", "Indie Rock", "Classic Rock", "Hard Rock"];
        foreach string genre in attributes.genreNames {
            foreach string preferredGenre in preferredGenres {
                if genre.includes(preferredGenre) {
                    return true;
                }
            }
        }
        
        // Check for recent releases (simulate preference for newer content)
        string? releaseDateOptional = attributes.releaseDate;
        if releaseDateOptional is string {
            string releaseDate = releaseDateOptional;
            // Prefer releases from 2020 onwards (simplified logic)
            if releaseDate.startsWith("2024") || releaseDate.startsWith("2023") || releaseDate.startsWith("2022") {
                return true;
            }
        }
        
        // Prefer Apple Digital Master quality
        boolean? isMasteredOptional = attributes.isMasteredForItunes;
        if isMasteredOptional is boolean {
            if isMasteredOptional {
                return true;
            }
        }
    }
    
    // Default: include 30% of tracks to simulate partial preference matching
    return (album.id.length() % 10) < 3;
}