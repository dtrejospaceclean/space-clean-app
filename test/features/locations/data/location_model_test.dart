import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/locations/data/models/location_model.dart';
import 'package:sp_cln_app/features/locations/domain/entities/location.dart';

void main() {
  test('reads a location with its usage counts', () {
    final location = LocationModel.fromJson({
      'id': 'l1',
      'clientAccountId': 'c1',
      'name': 'Tower A – Floor 3',
      'address': '1980 Post Oak Blvd',
      'city': 'Houston',
      'state': 'TX',
      'zipCode': '77056',
      'accessCodes': 'Door 4521',
      'squareFootage': '12000',
      'floorCount': 1,
      'specialInstructions': null,
      'scopeOfWorkCount': 2,
      'jobCount': 14,
    });

    expect(location.cityLine, 'Houston, TX 77056');
    expect(location.squareFootage, '12000');
    expect(location.floorCount, 1);
    expect(location.isInUse, isTrue);
  });

  test('a location nothing uses can be deleted', () {
    final location = LocationModel.fromJson({
      'id': 'l1',
      'name': 'Annex',
      'address': '1 Main St',
      'city': 'Houston',
      'state': 'TX',
      'zipCode': '77002',
    });

    expect(location.isInUse, isFalse);
  });

  const draft = LocationDraft(
    name: ' Tower A ',
    address: '1980 Post Oak Blvd',
    city: 'Houston',
    state: 'TX',
    zipCode: '77056',
    squareFootage: '850.5',
    floorCount: ' ',
    accessCodes: '',
  );

  test('reads where the server placed it, or that it did not', () {
    final placed = LocationModel.fromJson({
      'id': 'l1',
      'name': 'Tower A',
      'latitude': 29.7499,
      'longitude': -95.4612,
      'geocodedAt': '2026-10-15T15:00:00.000Z',
    });
    expect(placed.latitude, 29.7499);
    expect(placed.longitude, -95.4612);
    expect(placed.geocodedAt, DateTime.utc(2026, 10, 15, 15).toLocal());
    expect(placed.hasCoordinates, isTrue);

    final unplaced = LocationModel.fromJson({
      'id': 'l2',
      'name': 'Annex',
      'latitude': null,
      'longitude': null,
      'geocodedAt': null,
    });
    expect(unplaced.hasCoordinates, isFalse);
    expect(unplaced.geocodedAt, isNull);
  });

  test('an address suggestion may leave city, state or ZIP unknown', () {
    final s = LocationModel.suggestionFromJson({
      'id': 's1',
      'name': '1980 Post Oak Boulevard',
      'description': 'Houston, Texas 77056',
      'address': '1980 Post Oak Boulevard',
      'city': 'Houston',
      'state': 'TX',
      'zipCode': null,
    });
    expect(s.address, '1980 Post Oak Boulevard');
    expect(s.city, 'Houston');
    expect(s.state, 'TX');
    expect(s.zipCode, isNull);
  });

  test('a new location sends numbers and only filled-in fields', () {
    expect(LocationDraftModel.toJson(draft, create: true), {
      'name': 'Tower A',
      'address': '1980 Post Oak Blvd',
      'city': 'Houston',
      'state': 'TX',
      'zipCode': '77056',
      'squareFootage': 850.5,
    });
  });

  test('an update clears the optional fields left empty', () {
    expect(LocationDraftModel.toJson(draft, create: false), {
      'name': 'Tower A',
      'address': '1980 Post Oak Blvd',
      'city': 'Houston',
      'state': 'TX',
      'zipCode': '77056',
      'accessCodes': null,
      'squareFootage': 850.5,
      'floorCount': null,
      'specialInstructions': null,
    });
  });
}
