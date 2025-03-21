# Podcast App (Work in progress)

Search, follow and listen to Podcasts

## Specs

- Architecture pattern:
    - presentation: UI view
    - application: state management (view controller)
    - domain: business logic, data entities
    - infrastructure: data sources, data models
- State Management: Bloc
- Dependency injection: GetIt
- Internationalization: Intl
- Data persistence: ObjectBox

## Getting Started

This App uses the Podcastindex API under https://api.podcastindex.org/

API key:
You need an account to obtain your own API keys, which must be inserted in the apikey and apiSecret variables in the authorisation.dart file.

I use an .env file (included in gitignore) for hardcoded values and envied + envied_generator packages for obfuscation: https://pub.dev/packages/envied
This file exists in my project root folder. 

My gitignore:

*.env

/lib/env/env.g.dart

Run "dart run build_runner build --delete-conflicting-outputs" to generate the .env.g.dart file.
Run it also to generate the objectbox.g.dart and the objectbox-model.json files!

## Current state
Done: Search for podcasts and view description and episodes, view episode descriptions and listen to episodes, open podcast urls in a webview.

## Todo
    - App name
    - UI design is not final
    - Playlists and favourites
    - Player (skip to previous and skip to next episode: playlists must be implemented first)
    - Share on social media or as link
    - Unit tests
    - Perform actions on episodes for subscribed podcaast and save to database
    - ...
