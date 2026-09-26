import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/service_catalog/data/models/service_models.dart';
import 'package:sp_cln_app/features/service_catalog/domain/entities/service_item.dart';

void main() {
  test('reads a service, keeping the price as a decimal string', () {
    final service = ServiceItemModel.fromJson({
      'id': 's1',
      'name': 'Limpieza de oficinas',
      'category': 'Janitorial',
      'unitOfMeasure': 'sq ft',
      'defaultPrice': '0.12',
      'isActive': true,
    });

    expect(service.defaultPrice, '0.12');
    expect(service.category, 'Janitorial');
    expect(service.isActive, isTrue);
  });

  test('sends only the fields the API defines, price as a number', () {
    final body = ServiceDraftModel.toJson(
      const ServiceDraft(
        name: ' Carpet shampoo ',
        unitOfMeasure: 'sq ft',
        category: 'Floors',
        defaultPrice: '0.30',
      ),
    );

    expect(body, {
      'name': 'Carpet shampoo',
      'unitOfMeasure': 'sq ft',
      'category': 'Floors',
      'defaultPrice': 0.3,
      'isActive': true,
    });
  });

  test('emptied optional fields are sent as null to clear them', () {
    final body = ServiceDraftModel.toJson(
      const ServiceDraft(
        name: 'Window washing',
        unitOfMeasure: 'visit',
        category: ' ',
        defaultPrice: '',
        isActive: false,
      ),
    );

    expect(body['category'], isNull);
    expect(body['defaultPrice'], isNull);
    expect(body['isActive'], isFalse);
  });
}
