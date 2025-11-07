import ballerina/io;
import ballerinax/apple.music;

configurable string authorization = ?;
configurable string musicUserToken = ?;
configurable string storefront = "us";

public function main() returns error? {
    
    music:ApiKeysConfig config = {
        authorization: authorization,
        musicUserToken: musicUserToken
    };
    
    music:Client appleMusicClient = check new (config);
    
    io:println("=== Music Recommendation System ===");
    io:println("Step 1: Retrieving artists from user's library...");
    
    music:LibraryArtistsResponse libraryArtistsResponse = check appleMusicClient->/me/library/artists();
    
    if libraryArtistsResponse.data.length() == 0 {
        io:println("No artists found in user's library");
        return;
    }
    
    io:println(string`Found ${libraryArtistsResponse.data.length()} artists in library`);
    
    string[] recommendedAlbumIds = [];
    
    foreach music:LibraryArtists libraryArtist in libraryArtistsResponse.data {
        string artistName = libraryArtist.attributes?.name ?: "Unknown Artist";
        io:println(string`\nStep 2: Finding similar artists to ${artistName}...`);
        
        music:AlbumsResponse|error similarArtistsResult = appleMusicClient->/catalog/[storefront]/artists/[libraryArtist.id]/view/["similar-artists"]('limit = 5);
        
        if similarArtistsResult is error {
            io:println(string`Could not find similar artists for ${artistName}: ${similarArtistsResult.message()}`);
            continue;
        }
        
        music:AlbumsResponse similarArtistsResponse = similarArtistsResult;
        
        if similarArtistsResponse.data.length() == 0 {
            io:println(string`No similar artists found for ${artistName}`);
            continue;
        }
        
        io:println(string`Found ${similarArtistsResponse.data.length()} similar artists for ${artistName}`);
        
        foreach music:Albums similarArtist in similarArtistsResponse.data {
            string similarArtistName = similarArtist.attributes?.copyright ?: "Unknown Similar Artist";
            io:println(string`Step 3: Getting albums from similar artist: ${similarArtistName}`);
            
            music:AlbumsResponse|error albumsResult = appleMusicClient->/catalog/[storefront]/artists/[similarArtist.id]/view/["full-albums"]('limit = 3);
            
            if albumsResult is error {
                io:println(string`Could not get albums for ${similarArtistName}: ${albumsResult.message()}`);
                continue;
            }
            
            music:AlbumsResponse albumsResponse = albumsResult;
            
            foreach music:Albums album in albumsResponse.data {
                recommendedAlbumIds.push(album.id);
                string albumTitle = album.attributes?.copyright ?: "Unknown Album";
                string releaseDate = album.attributes?.releaseDate ?: "Unknown Date";
                io:println(string`  - Recommended Album: ${albumTitle} (Released: ${releaseDate})`);
            }
        }
        
        if libraryArtistsResponse.data.length() > 3 {
            break;
        }
    }
    
    io:println(string`\n=== Recommendation Summary ===`);
    io:println(string`Total recommended albums: ${recommendedAlbumIds.length()}`);
    
    if recommendedAlbumIds.length() > 0 {
        io:println("Step 4: Getting detailed information for first recommended album...");
        
        music:AlbumsResponse|error detailedAlbumResult = appleMusicClient->/catalog/[storefront]/albums/[recommendedAlbumIds[0]]();
        
        if detailedAlbumResult is music:AlbumsResponse {
            music:Albums detailedAlbum = detailedAlbumResult.data[0];
            string albumName = detailedAlbum.attributes?.copyright ?: "Unknown Album";
            string[] genreNames = detailedAlbum.attributes?.genreNames ?: [];
            string genres = genreNames.length() > 0 ? string:'join(", ", ...genreNames) : "Unknown Genre";
            
            io:println(string`Featured Recommendation: ${albumName}`);
            io:println(string`Genres: ${genres}`);
            io:println(string`Album ID: ${detailedAlbum.id}`);
        } else {
            io:println(string`Could not get detailed information: ${detailedAlbumResult.message()}`);
        }
    }
    
    io:println("\n=== Music recommendation system completed ===");
}