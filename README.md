# Podcast App (Work in progress)

Search, follow and listen to Podcasts

## Getting Started

This App uses the Podcastindex API under https://api.podcastindex.org/

API key:
You need an account to obtain your own API keys, which must be inserted in the apikey and apiSecret variables in the authorisation.dart file.

I use an .env file (included in gitignore) for hardcoded values and envied + envied_generator packages for obfuscation: https://pub.dev/packages/envied

My gitignore:

*.env

/lib/env/env.g.dart

## Current state
Done: Search for podcasts and view description and episodes, view episode descriptions and listen to episodes, open podcast urls in a webview.

## Todo
    - App name
    - UI design is not final    
    - Data persistence for followed podcasts and episode read status is not yet implemented: I will probably use an objectbox database.
    - Playlists and favourites
    - Player (skip to previous and skip to next episode: playlists must be implemented first)
    - Share on social media or as link
