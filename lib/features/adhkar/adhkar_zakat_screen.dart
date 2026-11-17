import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../config/miqati_theme.dart';
import '../../core/localization/app_localizations.dart';
import '../admin/admin_controller.dart';

class HisnBookItem {
  final String text;
  final int count;
  const HisnBookItem({required this.text, required this.count});
}

class HisnBookChapter {
  final int id;
  final String category;
  final List<HisnBookItem> items;
  const HisnBookChapter({required this.id, required this.category, required this.items});
}

class AdhkarAndZakatScreen extends StatefulWidget {
  final MiqatiAppController controller;
  const AdhkarAndZakatScreen({super.key, required this.controller});

  @override
  State<AdhkarAndZakatScreen> createState() => _AdhkarAndZakatScreenState();
}

class _AdhkarAndZakatScreenState extends State<AdhkarAndZakatScreen> {
  late PageController _hisnPageCtrl;
  int _currentChapterIdx = 0;
  int _highlightedItemIdx = -1;
  bool _loading = true;
  String _searchQuery = '';
  final Set<String> _bookmarkedKeys = <String>{};
  final Map<String, int> _itemCounters = <String, int>{};
  List<HisnBookChapter> _chapters = [];

  static const String _primarySourceUrl =
      'https://cdn.jsdelivr.net/gh/rn0x/Adhkar-json@main/adhkar.json';
  static const String _fallbackSourceUrl =
      'https://raw.githubusercontent.com/rn0x/Adhkar-json/main/adhkar.json';

  @override
  void initState() {
    super.initState();
    _currentChapterIdx = widget.controller.hisnSavedPage;
    _hisnPageCtrl = PageController(initialPage: _currentChapterIdx);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAuthenticHisnFromSource());
  }

  Future<void> _loadAuthenticHisnFromSource() async {
    final disk = widget.controller.audioService;
    final cached = await disk.loadDiskJson('hisn_adhkar_open_v8');
    if (cached != null && cached.length > 5000) {
      _parseAndSetChapters(cached);
      return;
    }
    for (final url in [_primarySourceUrl, _fallbackSourceUrl]) {
      try {
        final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 12));
        if (res.statusCode == 200 && res.body.length > 5000) {
          await disk.saveDiskJson('hisn_adhkar_open_v8', res.body);
          _parseAndSetChapters(res.body);
          return;
        }
      } catch (_) {}
    }
    if (mounted) setState(() => _loading = false);
  }

  void _parseAndSetChapters(String rawJson) {
    try {
      final list = jsonDecode(rawJson) as List<dynamic>;
      final parsed = <HisnBookChapter>[];
      for (final ch in list) {
        final arr = (ch['array'] as List<dynamic>?) ?? [];
        final items = arr
            .map((e) => HisnBookItem(
                  text: e['text']?.toString().trim() ?? '',
                  count: (e['count'] as num?)?.toInt() ?? 1,
                ))
            .where((x) => x.text.isNotEmpty)
            .toList();
        if (items.isNotEmpty) {
          parsed.add(HisnBookChapter(
            id: (ch['id'] as num?)?.toInt() ?? (parsed.length + 1),
            category: ch['category']?.toString().trim() ?? 'أذكار',
            items: items,
          ));
        }
      }
      if (mounted) {
        setState(() {
          _chapters = parsed;
          if (_currentChapterIdx >= _chapters.length) _currentChapterIdx = 0;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _hisnPageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = AppLocalizations.of(context).isAr;
    final pal = MiqatiPalette.of(widget.controller.isDarkMode);

    final filteredChapters = _searchQuery.trim().isEmpty
        ? _chapters
        : _chapters
            .where((c) =>
                c.category.contains(_searchQuery.trim()) ||
                c.items.any((it) => it.text.contains(_searchQuery.trim())))
            .toList();

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        // شريط المسبحة المحفوظة
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [pal.emerald.withOpacity(0.25), pal.cardBg]),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: pal.emerald.withOpacity(0.45)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isAr ? '📿 المسبحة الإلكترونية المحفوظة' : '📿 Persistent Tasbih Counter', style: TextStyle(fontWeight: FontWeight.bold, color: pal.textPrimary)),
                    Text(isAr ? 'العدد الإجمالي: ${widget.controller.tasbihCounter}' : 'Total Count: ${widget.controller.tasbihCounter}', style: TextStyle(color: pal.gold, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
              Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: pal.emerald, foregroundColor: Colors.white),
                    onPressed: () {
                      setState(() => widget.controller.tasbihCounter++);
                      widget.controller.saveHisnState(_currentChapterIdx, widget.controller.tasbihCounter);
                    },
                    child: Text(isAr ? '+ سبّح' : '+ Count'),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh, color: pal.textMuted),
                    onPressed: () {
                      setState(() => widget.controller.tasbihCounter = 0);
                      widget.controller.saveHisnState(_currentChapterIdx, 0);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // البحث في أبواب حصن المسلم
        TextField(
          style: TextStyle(color: pal.textPrimary),
          decoration: InputDecoration(
            hintText: isAr ? 'ابحث في أبواب وأذكار حصن المسلم...' : 'Search Hisn al-Muslim chapters...',
            hintStyle: TextStyle(color: pal.textMuted, fontSize: 13),
            prefixIcon: Icon(Icons.search, color: pal.emerald),
            filled: true,
            fillColor: pal.cardBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: pal.border)),
          ),
          onChanged: (v) => setState(() => _searchQuery = v),
        ),
        const SizedBox(height: 10),

        if (_loading)
          const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (filteredChapters.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: pal.cardBg, borderRadius: BorderRadius.circular(18), border: Border.all(color: pal.border)),
            child: Column(
              children: [
                Text(isAr ? 'تعذر جلب أذكار حصن المسلم من المصدر المفتوح. تأكد من الاتصال بالإنترنت في المرة الأولى.' : 'Could not fetch Hisn al-Muslim data. Check internet on first run.', textAlign: TextAlign.center, style: TextStyle(color: pal.textMuted)),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() => _loading = true);
                    _loadAuthenticHisnFromSource();
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(isAr ? 'إعادة المحاولة' : 'Retry'),
                ),
              ],
            ),
          )
        else ...[
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filteredChapters.length,
              itemBuilder: (_, i) {
                final ch = filteredChapters[i];
                final active = i == _currentChapterIdx;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(ch.category),
                    selected: active,
                    selectedColor: pal.gold,
                    labelStyle: TextStyle(color: active ? Colors.black : pal.textPrimary, fontWeight: FontWeight.bold, fontSize: 12),
                    onSelected: (_) {
                      _hisnPageCtrl.animateToPage(i, duration: const Duration(milliseconds: 260), curve: Curves.easeInOut);
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: pal.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: pal.gold.withOpacity(0.5), width: 1.5),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '📖 ${filteredChapters[_currentChapterIdx.clamp(0, filteredChapters.length - 1)].category}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: pal.gold),
                      ),
                    ),
                    Text('${_currentChapterIdx + 1} / ${filteredChapters.length}', style: TextStyle(color: pal.textMuted, fontSize: 12)),
                  ],
                ),
                const Divider(),
                SizedBox(
                  height: 430,
                  child: PageView.builder(
                    controller: _hisnPageCtrl,
                    reverse: isAr,
                    itemCount: filteredChapters.length,
                    onPageChanged: (idx) {
                      setState(() {
                        _currentChapterIdx = idx;
                        _highlightedItemIdx = -1;
                      });
                      widget.controller.saveHisnState(idx, widget.controller.tasbihCounter);
                    },
                    itemBuilder: (_, chIdx) {
                      final chapter = filteredChapters[chIdx];
                      return ListView.builder(
                        itemCount: chapter.items.length,
                        itemBuilder: (_, itemIdx) {
                          final item = chapter.items[itemIdx];
                          final key = '${chapter.id}_$itemIdx';
                          final count = _itemCounters[key] ?? 0;
                          final isHighlighted = _highlightedItemIdx == itemIdx;
                          final isBk = _bookmarkedKeys.contains(key);

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _highlightedItemIdx = itemIdx;
                                _itemCounters[key] = count + 1;
                              });
                              widget.controller.recordAdhkarCompleted();
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isHighlighted ? pal.emerald.withOpacity(0.2) : pal.cardAlt,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: isHighlighted ? pal.gold : pal.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(item.text, textDirection: TextDirection.rtl, style: TextStyle(fontSize: 16, height: 1.75, color: pal.textPrimary, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('التكرار: $count / ${item.count}', style: TextStyle(fontSize: 11, color: pal.gold, fontWeight: FontWeight.bold)),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.copy, size: 17),
                                            color: pal.emerald,
                                            onPressed: () {
                                              Clipboard.setData(ClipboardData(text: item.text));
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text(isAr ? 'تم نسخ الذكر' : 'Copied')),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(isBk ? Icons.bookmark : Icons.bookmark_border, size: 18),
                                            color: pal.gold,
                                            onPressed: () {
                                              setState(() {
                                                if (isBk) {
                                                  _bookmarkedKeys.remove(key);
                                                } else {
                                                  _bookmarkedKeys.add(key);
                                                }
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
