import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/station.dart';

class NowPlayingInfo {
  final String name;
  final String status;

  NowPlayingInfo({required this.name, required this.status});
}

class FavListResult {
  final List<Station> stations;
  final int total;
  final int itemsPerPage;

  FavListResult({required this.stations, required this.total, required this.itemsPerPage});
}

class RadioApiService {
  final String host;

  RadioApiService(this.host);

  Uri _uri(String path) => Uri.parse('http://$host$path');

  Future<NowPlayingInfo> getNowPlaying() async {
    final response = await http.get(_uri('/php/playing.php')).timeout(const Duration(seconds: 5));
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return NowPlayingInfo(
      name: json['name'] as String? ?? '',
      status: json['chStatus'] as String? ?? '',
    );
  }

  Future<FavListResult> getFavPage(int page) async {
    final response = await http.get(_uri('/php/favList.php?PG=$page')).timeout(const Duration(seconds: 5));
    final body = response.body;

    final stations = <Station>[];
    final stationRegex = RegExp(r'myFavChannelList\.push\(\["([^"]*?)","([^"]*?)"');
    for (final match in stationRegex.allMatches(body)) {
      stations.add(Station(
        name: match.group(1)!,
        url: match.group(2)!,
        index: -1, // will be set by caller
      ));
    }

    int total = 0;
    int itemsPerPage = 10;
    // Use the last favListInfo line (which has the real total)
    final infoRegex = RegExp(r'favListInfo\s*=\s*\{.*?total:(\d+).*?itemsPerPage:(\d+)');
    final infoMatches = infoRegex.allMatches(body).toList();
    if (infoMatches.isNotEmpty) {
      final lastMatch = infoMatches.last;
      total = int.parse(lastMatch.group(1)!);
      itemsPerPage = int.parse(lastMatch.group(2)!);
    }

    return FavListResult(stations: stations, total: total, itemsPerPage: itemsPerPage);
  }

  Future<List<Station>> getAllFavorites() async {
    final firstPage = await getFavPage(0);
    final total = firstPage.total;
    final perPage = firstPage.itemsPerPage;
    if (total == 0 || perPage == 0) return [];

    final totalPages = (total / perPage).ceil();
    final allStations = <Station>[];

    // Add first page stations with correct indices
    for (int i = 0; i < firstPage.stations.length; i++) {
      final s = firstPage.stations[i];
      allStations.add(Station(name: s.name, url: s.url, index: i));
    }

    // Fetch remaining pages
    for (int page = 1; page < totalPages; page++) {
      final result = await getFavPage(page);
      for (int i = 0; i < result.stations.length; i++) {
        final s = result.stations[i];
        allStations.add(Station(name: s.name, url: s.url, index: page * perPage + i));
      }
    }

    return allStations;
  }

  Future<void> playStation(int index) async {
    await http.get(Uri.parse('http://$host/doApi.cgi?AI=16&CI=$index')).timeout(const Duration(seconds: 5));
  }
}
