/// Whether every word of [query] appears somewhere in [fields], so
/// "office nego" narrows down. Case and accents don't matter, so
/// "negociacion" finds "Negociación". An empty query matches everything.
///
/// For lists the API can't search but already loaded whole: the search
/// runs on the phone, as you type.
bool matchesSearch(String query, Iterable<String?> fields) {
  final words = foldForSearch(query)
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty);
  if (words.isEmpty) return true;
  final haystack = foldForSearch(fields.whereType<String>().join(' '));
  return words.every(haystack.contains);
}

const _accents = {
  'á': 'a',
  'é': 'e',
  'í': 'i',
  'ó': 'o',
  'ú': 'u',
  'ü': 'u',
  'ñ': 'n',
};

/// [text] lowercased, without Spanish accents.
String foldForSearch(String text) =>
    text.toLowerCase().split('').map((c) => _accents[c] ?? c).join();
