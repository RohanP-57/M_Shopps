import 'package:flutter/services.dart';
import 'package:csv/csv.dart';

class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._();
  
  LocationService._();

  Map<String, List<String>>? _countryStates;
  bool _isLoaded = false;
  Future<void> _loadData() async {
    if (_isLoaded) return;

    try {
      final String csvString = await rootBundle.loadString('assets/data/countries_states.csv');
      List<List<dynamic>> csvTable = const CsvToListConverter().convert(csvString);
      
      _countryStates = <String, List<String>>{};
      for (int i = 1; i < csvTable.length; i++) {
        final row = csvTable[i];
        if (row.length >= 2) {
          final country = row[0].toString().trim();
          final state = row[1].toString().trim();
          
          if (_countryStates!.containsKey(country)) {
            _countryStates![country]!.add(state);
          } else {
            _countryStates![country] = [state];
          }
        }
      }
      _countryStates!.forEach((country, states) {
        states.sort();
      });
      
      _isLoaded = true;
    } catch (e) {
      _countryStates = _getFallbackData();
      _isLoaded = true;
    }
  }
  Map<String, List<String>> _getFallbackData() {
    return {
      'India': ['Please reload the app'],
      'United States': ['Please reload the app'],
      'Canada': ['Please reload the app'],
    };
  }
  Future<List<String>> getCountries() async {
    await _loadData();
    final countries = _countryStates!.keys.toList();
    countries.sort();
    return countries;
  }
  Future<List<String>> getStatesForCountry(String country) async {
    await _loadData();
    return _countryStates![country] ?? [];
  }

  List<String> getCountriesSync() {
    if (!_isLoaded) {

      final fallback = _getFallbackData();
      final countries = fallback.keys.toList();
      countries.sort();
      return countries;
    }
    final countries = _countryStates!.keys.toList();
    countries.sort();
    return countries;
  }

  List<String> getStatesForCountrySync(String country) {
    if (!_isLoaded) {
      final fallback = _getFallbackData();
      return fallback[country] ?? [];
    }
    return _countryStates![country] ?? [];
  }
  Future<void> initialize() async {
    await _loadData();
  }
  bool get isLoaded => _isLoaded;
  void clearCache() {
    _countryStates = null;
    _isLoaded = false;
  }
}