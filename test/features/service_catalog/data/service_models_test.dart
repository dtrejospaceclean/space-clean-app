import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/service_catalog/data/models/service_models.dart';
import 'package:sp_cln_app/features/service_catalog/domain/entities/service_item.dart';

void main() {
  test('reads a service with its category and unit', () {
    final service = ServiceItemModel.fromJson({
      'id': 's1',
      'name': 'Limpieza de oficinas',
      'categoryId': 'c1',
      'unitOfMeasureId': 'm1',
      'defaultPrice': '0.12',
      'isActive': true,
      'category': {'id': 'c1', 'name': 'Janitorial'},
      'unitOfMeasure': {
        'id': 'm1',
        'name': 'Square foot',
        'abbreviation': 'sq ft',
      },
    });

    expect(service.defaultPrice, '0.12');
    expect(service.category?.name, 'Janitorial');
    expect(service.unit.short, 'sq ft');
  });

  test('a unit without an abbreviation is shown by name', () {
    final unit = UnitOfMeasureModel.fromJson({
      'id': 'm2',
      'name': 'Visit',
      'abbreviation': null,
      'isActive': true,
      'serviceCount': 3,
    });

    expect(unit.short, 'Visit');
    expect(unit.serviceCount, 3);
  });

  test('sends ids, and the price as a number', () {
    final body = ServiceDraftModel.toJson(
      const ServiceDraft(
        name: ' Carpet shampoo ',
        unitOfMeasureId: 'm1',
        categoryId: 'c2',
        defaultPrice: '0.30',
      ),
    );

    expect(body, {
      'name': 'Carpet shampoo',
      'unitOfMeasureId': 'm1',
      'categoryId': 'c2',
      'defaultPrice': 0.3,
      'isActive': true,
    });
  });

  test('no category or price is sent as null to clear them', () {
    final body = ServiceDraftModel.toJson(
      const ServiceDraft(
        name: 'Window washing',
        unitOfMeasureId: 'm2',
        defaultPrice: '',
        isActive: false,
      ),
    );

    expect(body.containsKey('categoryId'), isTrue);
    expect(body['categoryId'], isNull);
    expect(body['defaultPrice'], isNull);
    expect(body['isActive'], isFalse);
  });

  test('lookups send only their own fields; empty detail clears it', () {
    const draft = LookupDraft(name: ' Hour ', detail: ' ', isActive: false);

    expect(UnitOfMeasureModel.toJson(draft), {
      'name': 'Hour',
      'abbreviation': null,
      'isActive': false,
    });
    expect(ServiceCategoryModel.toJson(draft), {
      'name': 'Hour',
      'description': null,
      'isActive': false,
    });
  });
}
