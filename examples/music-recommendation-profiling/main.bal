import ballerina/io;
import ballerinax/apple.music;

configurable string developerToken = ?;
configurable string musicUserToken = ?;

type TasteProfile record {
    map<int> genreCounts;
    map<int> artistCounts;
    map<int> albumCounts;
    int totalSongs;
};

public function main() returns error? {
    music:Client appleMusic = check new ({
        authorization: developerToken,
        musicUserToken: musicUserToken
    });

    io:println("Starting Music Discovery Recommendation Engine...");
    io:println("========================================");

    // Step 1: Retrieve all songs from user's library
    io:println("\n1. Fetching songs from user's library...");
    
    music:LibrarySongsResponse librarySongs = check appleMusic->/me/library/songs(
        headers = {"Music-User-Token": musicUserToken},
        'limit = 25
    );

    io:println(string `Found ${librarySongs.data.length()} songs in library`);
    
    // Step 2: Initialize taste profile
    TasteProfile tasteProfile = {
        genreCounts: {},
        artistCounts: {},
        albumCounts: {},
        totalSongs: librarySongs.data.length()
    };

    // Step 3: Analyze each song to build comprehensive taste profile
    io:println("\n2. Building taste profile from song analysis...");
    
    foreach music:LibrarySongs song in librarySongs.data {
        io:println(string `Analyzing: ${song.attributes?.albumName ?: "Unknown Album"}`);
        
        // Analyze genres from song attributes
        string[]? genreNames = song.attributes?.genreNames;
        if genreNames is string[] {
            foreach string genre in genreNames {
                if tasteProfile.genreCounts.hasKey(genre) {
                    tasteProfile.genreCounts[genre] = tasteProfile.genreCounts.get(genre) + 1;
                } else {
                    tasteProfile.genreCounts[genre] = 1;
                }
            }
        }

        // Fetch detailed relationship data for artists
        music:LibrarySongsResponse artistsResponse = check appleMusic->/me/library/songs/[song.id]/artists(
            headers = {"Music-User-Token": musicUserToken},
            'limit = 10
        );
        
        foreach music:LibrarySongs artistData in artistsResponse.data {
            if artistData.attributes is music:LibrarySongsAttributes {
                string artistKey = artistData.id;
                if tasteProfile.artistCounts.hasKey(artistKey) {
                    tasteProfile.artistCounts[artistKey] = tasteProfile.artistCounts.get(artistKey) + 1;
                } else {
                    tasteProfile.artistCounts[artistKey] = 1;
                }
            }
        }

        // Fetch detailed relationship data for albums
        music:LibrarySongsResponse albumsResponse = check appleMusic->/me/library/songs/[song.id]/albums(
            headers = {"Music-User-Token": musicUserToken},
            'limit = 5
        );
        
        foreach music:LibrarySongs albumData in albumsResponse.data {
            if albumData.attributes is music:LibrarySongsAttributes {
                string albumKey = albumData.attributes?.albumName ?: albumData.id;
                if tasteProfile.albumCounts.hasKey(albumKey) {
                    tasteProfile.albumCounts[albumKey] = tasteProfile.albumCounts.get(albumKey) + 1;
                } else {
                    tasteProfile.albumCounts[albumKey] = 1;
                }
            }
        }

        // Fetch genre relationships for deeper analysis
        music:LibrarySongsResponse genresResponse = check appleMusic->/me/library/songs/[song.id]/genres(
            headers = {"Music-User-Token": musicUserToken},
            'limit = 10
        );
        
        foreach music:LibrarySongs genreData in genresResponse.data {
            string[]? detailedGenreNames = genreData.attributes?.genreNames;
            if detailedGenreNames is string[] {
                foreach string detailedGenre in detailedGenreNames {
                    if tasteProfile.genreCounts.hasKey(detailedGenre) {
                        tasteProfile.genreCounts[detailedGenre] = tasteProfile.genreCounts.get(detailedGenre) + 1;
                    } else {
                        tasteProfile.genreCounts[detailedGenre] = 1;
                    }
                }
            }
        }
    }

    // Step 4: Display comprehensive taste profile results
    io:println("\n3. Music Taste Profile Analysis Complete!");
    io:println("========================================");
    
    io:println(string `Total Songs Analyzed: ${tasteProfile.totalSongs}`);
    
    io:println("\nTop Genres:");
    string[] genreKeys = tasteProfile.genreCounts.keys();
    foreach string genre in genreKeys {
        int count = tasteProfile.genreCounts.get(genre);
        decimal percentage = <decimal>count / <decimal>tasteProfile.totalSongs * 100;
        string percentageString = percentage.toString();
        io:println(string `  ${genre}: ${count} songs (${percentageString}%)`);
    }
    
    io:println(string `\nUnique Artists: ${tasteProfile.artistCounts.length()}`);
    io:println(string `Unique Albums: ${tasteProfile.albumCounts.length()}`);
    io:println(string `Genre Diversity: ${tasteProfile.genreCounts.length()} different genres`);
    
    io:println("\n4. Recommendation Engine Ready!");
    io:println("This taste profile can now be used to:");
    io:println("- Find similar artists and songs");
    io:println("- Create personalized playlists");
    io:println("- Suggest new music based on genre preferences");
    io:println("- Identify music discovery opportunities");
}