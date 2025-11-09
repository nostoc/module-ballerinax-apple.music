import ballerina/io;
import ballerinax/apple.music;

configurable string developerToken = ?;
configurable string userToken = ?;

public function main() returns error? {
    music:ApiKeysConfig authConfig = {
        authorization: developerToken,
        musicUserToken: userToken
    };
    
    music:Client appleMusicClient = check new (authConfig);
    
    io:println("=== Music Library Analytics Dashboard ===\n");
    
    // Step 1: Fetch user's library albums
    io:println("1. Fetching your library albums...");
    music:GetAlbumsFromLibraryQueries libraryQuery = {
        'limit: 25,
        include: ["tracks", "artists"]
    };
    
    music:LibraryAlbumsResponse libraryResponse = check appleMusicClient->/me/library/albums(queries = libraryQuery);
    
    io:println("Found " + libraryResponse.data.length().toString() + " albums in your library:");
    
    // Step 2: Analyze library albums and extract insights
    map<int> artistAlbumCount = {};
    map<string[]> artistAlbums = {};
    int totalTracks = 0;
    map<int> genreCount = {};
    
    foreach music:LibraryAlbums album in libraryResponse.data {
        music:LibraryAlbumsAttributes? albumAttributes = album.attributes;
        if albumAttributes is music:LibraryAlbumsAttributes {
            music:LibraryAlbumsAttributes attrs = albumAttributes;
            
            io:println("  - " + attrs.name + " by " + attrs.artistName + " (" + attrs.trackCount.toString() + " tracks)");
            
            // Count albums per artist
            if artistAlbumCount.hasKey(attrs.artistName) {
                artistAlbumCount[attrs.artistName] = artistAlbumCount.get(attrs.artistName) + 1;
            } else {
                artistAlbumCount[attrs.artistName] = 1;
            }
            
            // Store album names per artist
            if artistAlbums.hasKey(attrs.artistName) {
                string[] existingAlbums = artistAlbums.get(attrs.artistName);
                existingAlbums.push(attrs.name);
                artistAlbums[attrs.artistName] = existingAlbums;
            } else {
                artistAlbums[attrs.artistName] = [attrs.name];
            }
            
            // Count total tracks
            totalTracks += <int>attrs.trackCount;
            
            // Count genres
            foreach string genre in attrs.genreNames {
                if genreCount.hasKey(genre) {
                    genreCount[genre] = genreCount.get(genre) + 1;
                } else {
                    genreCount[genre] = 1;
                }
            }
        }
    }
    
    // Step 3: Display analytics insights
    io:println("\n=== Library Analytics ===");
    io:println("Total Albums: " + libraryResponse.data.length().toString());
    io:println("Total Tracks: " + totalTracks.toString());
    io:println("Unique Artists: " + artistAlbumCount.keys().length().toString());
    
    // Top artists by album count
    io:println("\n=== Top Artists in Your Library ===");
    string[] artists = artistAlbumCount.keys();
    foreach string artist in artists {
        int count = artistAlbumCount.get(artist);
        if count >= 2 {
            io:println("  " + artist + ": " + count.toString() + " albums");
            string[] albums = artistAlbums.get(artist);
            foreach string albumName in albums {
                io:println("    - " + albumName);
            }
        }
    }
    
    // Genre distribution
    io:println("\n=== Genre Distribution ===");
    string[] genres = genreCount.keys();
    foreach string genre in genres {
        int count = genreCount.get(genre);
        if count >= 2 {
            io:println("  " + genre + ": " + count.toString() + " albums");
        }
    }
    
    // Collection completeness insights
    io:println("\n=== Collection Insights ===");
    foreach string artist in artists {
        int count = artistAlbumCount.get(artist);
        if count >= 3 {
            io:println("🎵 " + artist + " appears to be a favorite with " + count.toString() + " albums");
            io:println("   Consider exploring their full discography for more albums");
        } else if count == 2 {
            io:println("🎶 " + artist + " has " + count.toString() + " albums - might be worth discovering more");
        }
    }
    
    // Recommendations based on collection patterns
    io:println("\n=== Recommendations ===");
    string[] topGenres = genres.filter(genre => genreCount.get(genre) >= 3);
    if topGenres.length() > 0 {
        io:println("Your top genres are: " + string:'join(", ", ...topGenres));
        io:println("Consider exploring new artists in these genres");
    }
    
    string[] favoriteArtists = artists.filter(artist => artistAlbumCount.get(artist) >= 3);
    if favoriteArtists.length() > 0 {
        io:println("Your favorite artists: " + string:'join(", ", ...favoriteArtists));
        io:println("Check for new releases or deep cuts from these artists");
    }
    
    io:println("\n=== Dashboard Complete ===");
}