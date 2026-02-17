import 'dart:async';
import 'package:flutter/material.dart';
import '../models/radio_device.dart';
import '../models/station.dart';
import '../services/radio_api.dart';
import '../widgets/now_playing_bar.dart';
import '../widgets/station_tile.dart';

class NowPlayingScreen extends StatefulWidget {
  final RadioDevice radio;

  const NowPlayingScreen({super.key, required this.radio});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  late final RadioApiService _api;
  Timer? _pollTimer;

  List<Station> _favorites = [];
  String _nowPlayingName = '';
  String _nowPlayingStatus = '';
  bool _loadingFavorites = true;
  bool _loadingNowPlaying = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _api = RadioApiService(widget.radio.host);
    _loadAll();
    _startPollTimer();
  }

  void _startPollTimer() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _pollNowPlaying());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadFavorites(), _pollNowPlaying()]);
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _loadingFavorites = true;
      _error = null;
    });
    try {
      final favorites = await _api.getAllFavorites();
      if (!mounted) return;
      setState(() {
        _favorites = favorites;
        _loadingFavorites = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not reach radio: $e';
        _loadingFavorites = false;
      });
    }
  }

  Future<void> _pollNowPlaying() async {
    try {
      final info = await _api.getNowPlaying();
      if (!mounted) return;
      setState(() {
        _nowPlayingName = info.name;
        _nowPlayingStatus = info.status;
        _loadingNowPlaying = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingNowPlaying = false);
    }
  }

  Future<void> _playStation(Station station) async {
    try {
      await _api.playStation(station.index);
      setState(() {
        _nowPlayingName = station.name;
        _nowPlayingStatus = 'Play state: playing';
      });
      // Reset the poll timer so it doesn't immediately overwrite
      // the optimistic update before the radio has switched
      _startPollTimer();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to play station: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.radio.name)),
      body: Column(
        children: [
          NowPlayingBar(
            stationName: _nowPlayingName,
            status: _nowPlayingStatus,
            loading: _loadingNowPlaying,
          ),
          Expanded(
            child: _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadFavorites,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _loadingFavorites
                    ? const Center(child: CircularProgressIndicator())
                    : _favorites.isEmpty
                        ? const Center(child: Text('No favorites found.'))
                        : RefreshIndicator(
                            onRefresh: _loadFavorites,
                            child: ListView.builder(
                              itemCount: _favorites.length,
                              itemBuilder: (ctx, i) {
                                final station = _favorites[i];
                                return StationTile(
                                  station: station,
                                  isPlaying: station.name == _nowPlayingName,
                                  onTap: () => _playStation(station),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
