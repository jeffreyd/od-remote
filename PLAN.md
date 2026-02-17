# OD Remote — Flutter App Plan

## Overview

A Flutter Android app for controlling Ocean Digital streaming radios. The app connects to radios on the local network and allows browsing favorites and controlling playback.

## Screens

### 1. Radio Selector / Configuration Screen

- List of saved radios, each with a user-given name and host (IP or hostname)
- Add, edit, and delete radios
- Tapping a radio navigates to the Now Playing screen for that radio
- Radios are persisted locally (shared_preferences or similar)

### 2. Now Playing / Favorites Screen

This is the main screen once a radio is selected. It has two sections:

**Now Playing Bar (top or bottom)**
- Displays the currently playing station name
- Auto-refreshes on a short interval (e.g. every 5 seconds) via `GET http://<host>/php/playing.php`
- Shows playback status from the `chStatus` field

**Favorites List (main body)**
- Fetches all pages from `GET http://<host>/php/favList.php?PG=0`, `PG=1`, etc. using `total` and `itemsPerPage` from `favListInfo` to determine page count
- Displays station names in a scrollable list
- Tapping a station sends `GET http://<host>/doApi.cgi/AI=16&CI=<index>` to start playback, where `<index>` is the station's position in the overall favorites list (page * itemsPerPage + position on page)
- Pull-to-refresh to reload the favorites list
- Highlights the currently playing station if it matches by name

## Data / State

- **Radio model**: `{id, name, host}` — persisted with `shared_preferences` as JSON
- **Favorites parsing**: regex to extract station entries from the JS response. Each `myFavChannelList.push(["<name>","<url>", ...])` yields a name and URL. The station's index in the favorites list is its ordinal position across all pages.
- **favListInfo parsing**: regex to extract `total` and `itemsPerPage` from the last `favListInfo = {...}` line in the response to drive pagination

## Key Dependencies

- `http` — for making requests to the radio API
- `shared_preferences` — for persisting radio configurations
- `provider` or `riverpod` — for state management (provider is simpler and sufficient here)

## Parsing Strategy

The `/php/favList.php` response is executable JS, not JSON. Parse it with regexes:

```
// Extract station entries
RegExp(r'myFavChannelList\.push\(\["([^"]*?)","([^"]*?)"')

// Extract total count and items per page from the final favListInfo line
RegExp(r'favListInfo\s*=\s*\{.*?total:(\d+).*?itemsPerPage:(\d+)')
```

## Project Structure

```
lib/
  main.dart              — app entry point, MaterialApp, routing
  models/
    radio_device.dart    — Radio data model (name, host)
    station.dart         — Station data model (name, url, index)
  services/
    radio_api.dart       — HTTP calls + response parsing for all 3 endpoints
    radio_storage.dart   — CRUD for saved radios via shared_preferences
  screens/
    radio_list_screen.dart    — Radio selector / config screen
    now_playing_screen.dart   — Favorites list + now playing bar
  widgets/
    station_tile.dart         — List tile for a favorite station
    now_playing_bar.dart      — Current station display widget
```

## Build Order

1. Scaffold the Flutter project and add dependencies
2. Implement models (`RadioDevice`, `Station`)
3. Implement `RadioApiService` — HTTP calls and regex parsing
4. Implement `RadioStorageService` — persist radios to shared_preferences
5. Build the Radio List screen (add/edit/delete radios)
6. Build the Now Playing screen (favorites list + now playing bar + play action)
7. Wire up navigation between screens
8. Polish: error handling for unreachable radios, loading states, pull-to-refresh
