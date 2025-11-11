import ballerina/io;
import ballerinax/apple.music;

configurable string developerToken = ?;
configurable string musicUserToken = ?;
configurable string storefront = "us";

public function main() returns error? {
    music:Client appleMusic = check new ({
        authorization: developerToken,
        musicUserToken: musicUserToken
    });

    string searchTerm = "bohemian+rhapsody";
    io:println("🎵 Starting music discovery with search term: " + searchTerm);
    
    ("activities"|"albums"|"apple-curators"|"artists"|"curators"|"music-videos"|"playlists"|"record-labels"|"songs"|"stations")[] searchTypes = ["songs", "artists"];
    music:SearchResponse searchResponse = check appleMusic->/catalog/[storefront]/search(
        term = searchTerm,
        types = searchTypes,
        'limit = 10
    );
    
    io:println("✅ Search completed successfully");
    
    music:ArtistsResponse? artistsFromSearch = searchResponse.results.artists;
    
    if artistsFromSearch is () || artistsFromSearch.data.length() == 0 {
        io:println("❌ No artists found in search results");
        return;
    }
    
    io:println("🎤 Found " + artistsFromSearch.data.length().toString() + " artists from search");
    
    music:Artists firstArtist = artistsFromSearch.data[0];
    io:println("🔍 Exploring artist: " + firstArtist.id);
    
    ("appears-on-albums"|"compilation-albums"|"featured-albums"|"featured-playlists"|"full-albums"|"latest-release"|"live-albums"|"similar-artists"|"singles"|"top-music-videos"|"top-songs")[] artistViews = ["top-songs", "similar-artists", "full-albums"];
    string[] includeFields = ["albums"];
    music:ArtistsResponse artistDetails = check appleMusic->/catalog/[storefront]/artists/[firstArtist.id](
        views = artistViews,
        include = includeFields
    );
    
    io:println("✅ Retrieved detailed artist information");
    
    if artistDetails.data.length() > 0 {
        music:Artists detailedArtist = artistDetails.data[0];
        io:println("📊 Artist ID: " + detailedArtist.id);
        
        if detailedArtist.relationships is music:ArtistsRelationships {
            music:ArtistsRelationships relationships = <music:ArtistsRelationships>detailedArtist.relationships;
            
            if relationships.albums is music:AlbumsResponse {
                music:AlbumsResponse albums = <music:AlbumsResponse>relationships.albums;
                io:println("💽 Found " + albums.data.length().toString() + " albums for this artist");
                
                foreach music:Albums album in albums.data {
                    io:println("  - Album: " + album.id);
                }
            }
        }
    }
    
    if artistsFromSearch.data.length() > 1 {
        io:println("🌟 Exploring additional artists for diverse recommendations");
        
        int maxIndex = artistsFromSearch.data.length() > 3 ? 3 : artistsFromSearch.data.length();
        foreach int i in 1..<maxIndex {
            music:Artists additionalArtist = artistsFromSearch.data[i];
            io:println("🎭 Processing artist: " + additionalArtist.id);
            
            ("appears-on-albums"|"compilation-albums"|"featured-albums"|"featured-playlists"|"full-albums"|"latest-release"|"live-albums"|"similar-artists"|"singles"|"top-music-videos"|"top-songs")[] additionalViews = ["top-songs", "latest-release"];
            music:ArtistsResponse additionalDetails = check appleMusic->/catalog/[storefront]/artists/[additionalArtist.id](
                views = additionalViews
            );
            
            io:println("  ✅ Retrieved top songs and latest release info");
        }
    }
    
    io:println("🎉 Music discovery workflow completed! Personalized recommendations generated based on:");
    io:println("  - Original search results for: " + searchTerm);
    io:println("  - Artist relationships and albums");
    io:println("  - Top songs from multiple related artists");
    io:println("  - Similar artists and latest releases");
}