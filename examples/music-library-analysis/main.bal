import ballerina/io;
import ballerinax/apple.music;

configurable string developerToken = ?;
configurable string userToken = ?;

public function main() returns error? {
    
    music:Client appleMusic = check new ({
        authorization: developerToken,
        musicUserToken: userToken
    });

    io:println("=== Music Library Management System ===\n");

    io:println("Step 1: Fetching all songs from user's personal library...");
    music:LibrarySongsResponse libraryResponse = check appleMusic->/me/library/songs.get(
        headers = {"Music-User-Token": userToken},
        include = ["albums", "artists"]
    );

    io:println(string `Found ${libraryResponse.data.length()} songs in library`);
    
    map<int> genreCount = {};
    map<string[]> albumToSongs = {};
    int totalDuration = 0;
    
    foreach music:LibrarySongs song in libraryResponse.data {
        music:LibrarySongsAttributes? songAttributes = song.attributes;
        if songAttributes is music:LibrarySongsAttributes {
            
            foreach string genre in songAttributes.genreNames {
                if genreCount.hasKey(genre) {
                    genreCount[genre] = genreCount.get(genre) + 1;
                } else {
                    genreCount[genre] = 1;
                }
            }
            
            string? albumNameValue = songAttributes.albumName;
            if albumNameValue is string {
                if albumToSongs.hasKey(albumNameValue) {
                    string[] existingSongs = albumToSongs.get(albumNameValue);
                    existingSongs.push(song.id);
                    albumToSongs[albumNameValue] = existingSongs;
                } else {
                    albumToSongs[albumNameValue] = [song.id];
                }
            }
        }
    }

    io:println("\nMusic Taste Analysis:");
    io:println("Top Genres in Library:");
    foreach string genre in genreCount.keys() {
        io:println(string `  ${genre}: ${genreCount.get(genre)} songs`);
    }

    io:println(string `\nStep 2: Analyzing detailed information for first 3 songs...`);
    int songCount = 0;
    foreach music:LibrarySongs song in libraryResponse.data {
        if songCount >= 3 {
            break;
        }
        
        io:println(string `\nAnalyzing song: ${song.id}`);
        music:LibrarySongsResponse detailedSongResponse = check appleMusic->/me/library/songs/[song.id].get(
            headers = {"Music-User-Token": userToken},
            include = ["albums", "artists"]
        );
        
        if detailedSongResponse.data.length() > 0 {
            music:LibrarySongs detailedSong = detailedSongResponse.data[0];
            music:LibrarySongsAttributes? detailedAttributes = detailedSong.attributes;
            if detailedAttributes is music:LibrarySongsAttributes {
                io:println(string `  Album: ${detailedAttributes.albumName ?: "Unknown"}`);
                io:println(string `  Track Number: ${detailedAttributes.trackNumber ?: 0}`);
                io:println(string `  Disc Number: ${detailedAttributes.discNumber ?: 1}`);
                io:println(string `  Genres: ${string:'join(", ", ...detailedAttributes.genreNames)}`);
                io:println(string `  Has Lyrics: ${detailedAttributes.hasLyrics ?: false}`);
                
                music:LibrarySongsRelationships? songRelationships = detailedSong.relationships;
                if songRelationships is music:LibrarySongsRelationships {
                    music:AlbumsResponse? albumsRelation = songRelationships.albums;
                    if albumsRelation is music:AlbumsResponse {
                        io:println("  Connected to album relationships");
                    }
                    music:ArtistsResponse? artistsRelation = songRelationships.artists;
                    if artistsRelation is music:ArtistsResponse {
                        io:println("  Connected to artist relationships");
                    }
                }
            }
        }
        songCount += 1;
    }

    io:println(string `\nStep 3: Building recommendation patterns based on album collections...`);
    io:println("Album Collection Analysis:");
    foreach string albumName in albumToSongs.keys() {
        string[] songsInAlbum = albumToSongs.get(albumName);
        if songsInAlbum.length() > 1 {
            io:println(string `  "${albumName}": ${songsInAlbum.length()} songs in library`);
            io:println(string `    Recommendation: User enjoys complete album experiences`);
        }
    }

    map<string> recommendationPatterns = {};
    foreach music:LibrarySongs song in libraryResponse.data {
        music:LibrarySongsAttributes? songAttributes = song.attributes;
        if songAttributes is music:LibrarySongsAttributes {
            string? albumNameValue = songAttributes.albumName;
            if albumNameValue is string {
                string[] albumSongs = albumToSongs.get(albumNameValue);
                if albumSongs.length() >= 3 {
                    foreach string genre in songAttributes.genreNames {
                        string pattern = string `${genre} albums`;
                        recommendationPatterns[pattern] = string `User has ${albumSongs.length()} songs from "${albumNameValue}"`;
                    }
                }
            }
        }
    }

    io:println("\nRecommendation Patterns Identified:");
    foreach string pattern in recommendationPatterns.keys() {
        io:println(string `  ${pattern}: ${recommendationPatterns.get(pattern)}`);
    }

    io:println(string `\nLibrary Summary:`);
    io:println(string `- Total Songs: ${libraryResponse.data.length()}`);
    io:println(string `- Unique Albums: ${albumToSongs.keys().length()}`);
    io:println(string `- Genre Diversity: ${genreCount.keys().length()} different genres`);
    io:println(string `- Recommendation Patterns: ${recommendationPatterns.keys().length()} patterns identified`);
}