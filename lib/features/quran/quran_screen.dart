import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/app_branding_and_sounds.dart';
import '../../config/miqati_theme.dart';
import '../../core/localization/app_localizations.dart';
import '../admin/admin_controller.dart';
import 'quran_open_source_service.dart';

class QuranScreen extends StatefulWidget {
  final MiqatiAppController controller;
  final VoidCallback onSecretCodeEntered;
  const QuranScreen({
    super.key,
    required this.controller,
    required this.onSecretCodeEntered,
  });

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final QuranOpenSourceService _service = QuranOpenSourceService();
  late PageController _bookPageController;

  int _selectedSurah = 1;
  int _currentMushafPage = 1;
  bool _isBookPageFlipMode = false;
  String _readingLangMode = 'ar';
  bool _isCreamPaper = false;
  double _fontSize = 23.0;
  String _searchQuery = '';
  int _selectedAyahNumber = 1;
  int? _activePlayingAyah;
  bool _isAutoAdvancingAudio = false;
  bool _loadingSurah = false;
  String _pageSurahHeader = 'سورة الفاتحة';
  QuranReciterOption _selectedReciter = QuranOpenSourceService.reciters.first;
  List<QuranVerseItem> _verses = QuranOpenSourceService.offlineCache[1]!;
  final Set<int> _fetchingPages = <int>{};

  @override
  void initState() {
    super.initState();
    _selectedSurah = widget.controller.lastReadSurah.clamp(1, 114);
    _currentMushafPage = widget.controller.currentMushafPage.clamp(1, 604);
    _selectedAyahNumber = widget.controller.lastReadAyah.clamp(1, 286);
    _bookPageController = PageController(initialPage: _currentMushafPage - 1);

    widget.controller.audioService.onQuranStreamCompleted = () {
      if (!mounted) return;
      if (_isAutoAdvancingAudio && _activePlayingAyah != null) {
        final idx = _verses.indexWhere((v) => v.ayahNumber == _activePlayingAyah);
        if (idx >= 0 && idx + 1 < _verses.length) {
          _playSingleAyah(_verses[idx + 1], continueChain: true);
          return;
        }
      }
      setState(() {
        _activePlayingAyah = null;
        _isAutoAdvancingAudio = false;
      });
    };

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _service.ensureFullQuranOfflineCached(widget.controller.audioService);
      if (mounted) {
        _loadSurah(_selectedSurah, initialAyah: _selectedAyahNumber);
      }
    });
  }

  @override
  void dispose() {
    _bookPageController.dispose();
    super.dispose();
  }

  Future<void> _loadSurah(int num, {int initialAyah = 1}) async {
    setState(() {
      _loadingSurah = true;
      _isBookPageFlipMode = false;
    });
    final res = await _service.getSurahVerses(num, tafsirSlug: widget.controller.selectedTafsirSlug, disk: widget.controller.audioService);
    if (mounted) {
      setState(() {
        _selectedSurah = num;
        _verses = res;
        _selectedAyahNumber = initialAyah.clamp(1, res.isNotEmpty ? res.length : 1);
        if (res.isNotEmpty) _currentMushafPage = res.first.pageNumber;
        _loadingSurah = false;
      });
      widget.controller.recordQuranRead(surah: num, ayah: _selectedAyahNumber, page: _currentMushafPage);
    }
  }

  Future<void> _ensurePageLoaded(int pageNum) async {
    final target = pageNum.clamp(1, 604);
    if (_service.getCachedMushafPage(target) != null || _fetchingPages.contains(target)) {
      final cached = _service.getCachedMushafPage(target);
      if (cached != null && target == _currentMushafPage && mounted) {
        setState(() {
          _pageSurahHeader = cached.$1;
          _selectedSurah = cached.$2;
          _verses = cached.$3;
        });
      }
      return;
    }
    _fetchingPages.add(target);
    final res = await _service.getMushafPage(target, tafsirSlug: widget.controller.selectedTafsirSlug, disk: widget.controller.audioService);
    _fetchingPages.remove(target);
    if (mounted && target == _currentMushafPage) {
      setState(() {
        _pageSurahHeader = res.$1;
        _selectedSurah = res.$2;
        _verses = res.$3;
        if (_verses.isNotEmpty) _selectedAyahNumber = _verses.first.ayahNumber;
      });
      widget.controller.recordQuranRead(surah: _selectedSurah, ayah: _selectedAyahNumber, page: target);
    }
    // Preload next & previous page silently for instant book turning
    if (target + 1 <= 604 && _service.getCachedMushafPage(target + 1) == null) {
      _service.getMushafPage(target + 1, tafsirSlug: widget.controller.selectedTafsirSlug, disk: widget.controller.audioService);
    }
  }

  void _openBookPage(int pageNum, {bool jumpController = true}) {
    final target = pageNum.clamp(1, 604);
    setState(() {
      _isBookPageFlipMode = true;
      _currentMushafPage = target;
    });
    if (jumpController && _bookPageController.hasClients) {
      _bookPageController.jumpToPage(target - 1);
    }
    _ensurePageLoaded(target);
  }

  Future<void> _playSingleAyah(QuranVerseItem v, {bool continueChain = false}) async {
    setState(() {
      _selectedAyahNumber = v.ayahNumber;
      _activePlayingAyah = v.ayahNumber;
      _isAutoAdvancingAudio = continueChain;
    });
    widget.controller.recordAyahListened();
    final sName = v.surahNameAr.isNotEmpty ? v.surahNameAr : QuranOpenSourceService.all114SurahNamesAr[v.surahNumber - 1];
    final primaryOk = await widget.controller.audioService.playQuranAudioUrl(
      _selectedReciter.ayahAudioUrl(v.surahNumber, v.ayahNumber, globalAyah: v.globalAyahNumber),
      '$sName • آية ${v.ayahNumber}',
    );
    if (!primaryOk) {
      await widget.controller.audioService.playQuranAudioUrl(
        _selectedReciter.ayahFallbackUrl(v.surahNumber, v.ayahNumber),
        '$sName • آية ${v.ayahNumber}',
      );
    }
  }

  Future<void> _playFullSurah() async {
    setState(() {
      _isAutoAdvancingAudio = false;
      _activePlayingAyah = null;
    });
    widget.controller.recordAyahListened();
    await widget.controller.audioService.playQuranAudioUrl(
      _selectedReciter.surahAudioUrl(_selectedSurah),
      'سورة ${QuranOpenSourceService.all114SurahNamesAr[_selectedSurah - 1]} كاملة',
    );
  }

  void _showBookmarksSheet(MiqatiPalette pal) {
    final isAr = AppLocalizations.of(context).isAr;
    showModalBottomSheet(
      context: context,
      backgroundColor: pal.cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        final bks = widget.controller.bookmarks;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      isAr
                          ? '🔖 العلامات والصفحة المحفوظة (ص ${widget.controller.savedMushafPage})'
                          : '🔖 Bookmarks & Saved Page (p.${widget.controller.savedMushafPage})',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: pal.gold),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: pal.emerald, foregroundColor: Colors.white),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _openBookPage(widget.controller.savedMushafPage);
                    },
                    child: Text(isAr ? 'فتح ص ${widget.controller.savedMushafPage}' : 'Open p.${widget.controller.savedMushafPage}'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (bks.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(isAr ? 'لا توجد علامات محفوظة.' : 'No bookmarks yet.', style: TextStyle(color: pal.textMuted)),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: bks.length,
                    itemBuilder: (_, i) {
                      final b = bks[i];
                      return ListTile(
                        leading: Icon(Icons.bookmark, color: pal.gold),
                        title: Text('${b.surahName} • ${isAr ? "آية" : "Ayah"} ${b.ayahNumber}', style: TextStyle(color: pal.textPrimary, fontWeight: FontWeight.bold)),
                        subtitle: Text(b.previewText, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: pal.textMuted)),
                        onTap: () {
                          Navigator.of(ctx).pop();
                          _loadSurah(b.surahNumber, initialAyah: b.ayahNumber);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMushafRichText(List<QuranVerseItem> verses, Color mushafTextColor, MiqatiPalette pal) {
    return RichText(
      textAlign: TextAlign.justify,
      textDirection: TextDirection.rtl,
      text: TextSpan(
        style: TextStyle(
          fontSize: _fontSize,
          height: 2.05,
          color: mushafTextColor,
          fontFamily: 'serif',
        ),
        children: verses.map((v) {
          final isPlayingThis = _activePlayingAyah == v.ayahNumber && widget.controller.audioService.isPlayingQuran;
          final isSel = v.ayahNumber == _selectedAyahNumber;
          final isBk = widget.controller.isBookmarked(v.surahNumber, v.ayahNumber);
          final marker = isBk ? ' 🔖' : '';
          return TextSpan(
            text: '${v.uthmani} ﴿${v.ayahNumber}﴾$marker ',
            style: TextStyle(
              backgroundColor: isPlayingThis
                  ? pal.emerald.withOpacity(0.32)
                  : (isSel ? pal.gold.withOpacity(0.24) : (isBk ? pal.gold.withOpacity(0.12) : null)),
              color: isPlayingThis ? pal.gold : (isSel ? pal.emerald : mushafTextColor),
              fontWeight: (isPlayingThis || isSel || isBk) ? FontWeight.bold : FontWeight.normal,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                setState(() => _selectedAyahNumber = v.ayahNumber);
                if (widget.controller.audioService.isPlayingQuran) {
                  _playSingleAyah(v, continueChain: _isAutoAdvancingAudio);
                }
              },
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isAr = t.isAr;
    final pal = MiqatiPalette.of(widget.controller.isDarkMode);
    final isFullScreen = widget.controller.isFullScreenMushaf;
    final surahAr = QuranOpenSourceService.all114SurahNamesAr[_selectedSurah - 1];
    final surahEn = QuranOpenSourceService.all114SurahNamesEn[_selectedSurah - 1];

    final matchingSurahNums = QuranOpenSourceService.searchMatchingSurahs(_searchQuery);
    final normQ = QuranOpenSourceService.normalizeArabic(_searchQuery).toLowerCase();
    final filteredVerses = normQ.isEmpty
        ? _verses
        : _verses.where((v) {
            return QuranOpenSourceService.normalizeArabic(v.uthmani).contains(normQ) ||
                QuranOpenSourceService.normalizeArabic(v.tafsirAr).contains(normQ) ||
                v.translationEn.toLowerCase().contains(normQ);
          }).toList();

    final displayVerses = filteredVerses.isNotEmpty ? filteredVerses : _verses;
    final selectedVerseObj = displayVerses.firstWhere(
      (v) => v.ayahNumber == _selectedAyahNumber,
      orElse: () => displayVerses.first,
    );
    final isCurrentVerseBookmarked = widget.controller.isBookmarked(selectedVerseObj.surahNumber, selectedVerseObj.ayahNumber);

    final mushafBg = _isCreamPaper
        ? const Color(0xFFFDF6E3)
        : (pal.isDark ? const Color(0xFF071A16) : Colors.white);
    final mushafTextColor = _isCreamPaper
        ? const Color(0xFF1E293B)
        : (pal.isDark ? Colors.white : const Color(0xFF0F172A));

    return ListView(
      padding: EdgeInsets.all(isFullScreen ? 6 : 12),
      children: [
        if (!isFullScreen) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: pal.cardBg, borderRadius: BorderRadius.circular(18), border: Border.all(color: pal.border)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  style: TextStyle(color: pal.textPrimary),
                  decoration: InputDecoration(
                    hintText: isAr ? 'ابحث باسم السورة أو كلمة من الآية...' : 'Search Surah or Ayah keyword...',
                    hintStyle: TextStyle(color: pal.textMuted, fontSize: 13),
                    prefixIcon: Icon(Icons.search, color: pal.emerald),
                    filled: true,
                    fillColor: pal.cardAlt,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  onChanged: (val) {
                    if (val.trim() == AppBrandingAndSounds.secretSearchTriggerCode) {
                      widget.onSecretCodeEntered();
                      return;
                    }
                    setState(() => _searchQuery = val);
                  },
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(isAr ? '📜 عرض السورة' : '📜 Surah Mode'),
                      selected: !_isBookPageFlipMode,
                      onSelected: (_) => _loadSurah(_selectedSurah),
                    ),
                    ChoiceChip(
                      label: Text(isAr ? '📖 وضعية الكتاب (604 ص)' : '📖 Book Flip (604 p)'),
                      selected: _isBookPageFlipMode,
                      onSelected: (_) => _openBookPage(_currentMushafPage),
                    ),
                    ActionChip(
                      avatar: Icon(Icons.bookmark, size: 16, color: pal.gold),
                      label: Text(isAr ? 'المحفوظة (${widget.controller.savedMushafPage})' : 'Saved (${widget.controller.savedMushafPage})'),
                      onPressed: () => _showBookmarksSheet(pal),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (!_isBookPageFlipMode)
                  SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: matchingSurahNums.length,
                      itemBuilder: (_, idx) {
                        final num = matchingSurahNums[idx];
                        final active = num == _selectedSurah;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text('$num. ${isAr ? QuranOpenSourceService.all114SurahNamesAr[num - 1] : QuranOpenSourceService.all114SurahNamesEn[num - 1]}'),
                            selected: active,
                            selectedColor: pal.emerald,
                            labelStyle: TextStyle(color: active ? Colors.white : pal.textPrimary, fontSize: 12),
                            onSelected: (_) => _loadSurah(num),
                          ),
                        );
                      },
                    ),
                  )
                else
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        color: pal.gold,
                        onPressed: _currentMushafPage > 1 ? () => _bookPageController.previousPage(duration: const Duration(milliseconds: 260), curve: Curves.easeOut) : null,
                      ),
                      Text(
                        isAr ? 'صفحة $_currentMushafPage / 604' : 'Page $_currentMushafPage / 604',
                        style: TextStyle(color: pal.gold, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        color: pal.gold,
                        onPressed: _currentMushafPage < 604 ? () => _bookPageController.nextPage(duration: const Duration(milliseconds: 260), curve: Curves.easeOut) : null,
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: pal.gold, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                        onPressed: () {
                          widget.controller.saveCurrentMushafPage(_currentMushafPage);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(isAr ? '✅ تم حفظ الصفحة $_currentMushafPage' : '✅ Saved page $_currentMushafPage')),
                          );
                        },
                        icon: const Icon(Icons.save, size: 15),
                        label: Text(isAr ? 'حفظ الصفحة' : 'Save Page', style: const TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: pal.cardAlt, borderRadius: BorderRadius.circular(14)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButton<QuranReciterOption>(
                        value: _selectedReciter,
                        isExpanded: true,
                        dropdownColor: pal.cardBg,
                        underline: const SizedBox.shrink(),
                        items: QuranOpenSourceService.reciters
                            .map((r) => DropdownMenuItem(
                                  value: r,
                                  child: Text('🎙️ ${r.nameAr}', overflow: TextOverflow.ellipsis, style: TextStyle(color: pal.textPrimary, fontSize: 12)),
                                ))
                            .toList(),
                        onChanged: (r) {
                          if (r != null) setState(() => _selectedReciter = r);
                        },
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.controller.audioService.isPlayingQuran ? pal.danger : pal.emerald,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            onPressed: () {
                              if (widget.controller.audioService.isPlayingQuran) {
                                _isAutoAdvancingAudio = false;
                                _activePlayingAyah = null;
                                widget.controller.audioService.stopQuranAudio();
                              } else {
                                _playSingleAyah(selectedVerseObj, continueChain: true);
                              }
                            },
                            icon: Icon(widget.controller.audioService.isPlayingQuran ? Icons.stop : Icons.play_arrow, size: 18),
                            label: Text(
                              widget.controller.audioService.isPlayingQuran
                                  ? (isAr ? 'إيقاف التلاوة' : 'Stop Audio')
                                  : (isAr ? 'تلاوة وتأشير الآيات' : 'Recite & Highlight'),
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: _playFullSurah,
                            icon: Icon(Icons.library_music, size: 16, color: pal.gold),
                            label: Text(isAr ? 'السورة كاملة' : 'Full Surah', style: TextStyle(fontSize: 11, color: pal.gold)),
                          ),
                        ],
                      ),
                      const Divider(height: 12),
                      Row(
                        children: [
                          Text(isAr ? '📚 التفسير:' : '📚 Tafsir:', style: TextStyle(color: pal.gold, fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButton<String>(
                              value: widget.controller.selectedTafsirSlug,
                              isExpanded: true,
                              dropdownColor: pal.cardBg,
                              underline: const SizedBox.shrink(),
                              items: AppBrandingAndSounds.sunniTafsirs
                                  .map((tf) => DropdownMenuItem(
                                        value: tf.slug,
                                        child: Text(isAr ? tf.nameAr : tf.nameEn, overflow: TextOverflow.ellipsis, style: TextStyle(color: pal.textPrimary, fontSize: 12)),
                                      ))
                                  .toList(),
                              onChanged: (slug) {
                                if (slug != null) {
                                  widget.controller.setSelectedTafsir(slug);
                                  if (_isBookPageFlipMode) {
                                    _ensurePageLoaded(_currentMushafPage);
                                  } else {
                                    _loadSurah(_selectedSurah, initialAyah: _selectedAyahNumber);
                                  }
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],

        // بطاقة المصحف المتصل أو وضعية الكتاب الحقيقية بالتمرير دون تدمير الـ PageView
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: mushafBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: pal.gold.withOpacity(0.55), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    _isBookPageFlipMode
                        ? '$_pageSurahHeader • ${isAr ? "صفحة" : "p."} $_currentMushafPage'
                        : '${isAr ? "سورة $surahAr" : surahEn}',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: pal.gold),
                  ),
                  Wrap(
                    spacing: 4,
                    children: [
                      ChoiceChip(label: const Text('عربي', style: TextStyle(fontSize: 11)), selected: _readingLangMode == 'ar', onSelected: (_) => setState(() => _readingLangMode = 'ar')),
                      ChoiceChip(
      label: const Text('EN', style: TextStyle(fontSize: 11)),
      selected: _readingLangMode == 'en',
      onSelected: (_) async {
        setState(() => _readingLangMode = 'en');
        await _service.ensureEnglishSahihCached(widget.controller.audioService);
        if (mounted) {
          if (_isBookPageFlipMode) {
            _ensurePageLoaded(_currentMushafPage);
          } else {
            _loadSurah(_selectedSurah, initialAyah: _selectedAyahNumber);
          }
        }
      },
    ),
                      IconButton(icon: Icon(Icons.text_decrease, size: 18, color: pal.gold), onPressed: () => setState(() => _fontSize = (_fontSize - 2).clamp(16.0, 36.0))),
                      IconButton(icon: Icon(Icons.text_increase, size: 18, color: pal.gold), onPressed: () => setState(() => _fontSize = (_fontSize + 2).clamp(16.0, 36.0))),
                      IconButton(
                        icon: Icon(_isCreamPaper ? Icons.dark_mode : Icons.menu_book, size: 18, color: pal.gold),
                        onPressed: () => setState(() => _isCreamPaper = !_isCreamPaper),
                      ),
                      IconButton(
                        icon: Icon(isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen, size: 22, color: pal.emerald),
                        onPressed: () => widget.controller.setFullScreenMushaf(!isFullScreen),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),
              if (_isBookPageFlipMode)
                SizedBox(
                  height: isFullScreen ? 470 : 380,
                  child: PageView.builder(
                    controller: _bookPageController,
                    reverse: true,
                    itemCount: 604,
                    onPageChanged: (idx) {
                      final pNum = idx + 1;
                      setState(() => _currentMushafPage = pNum);
                      _ensurePageLoaded(pNum);
                    },
                    itemBuilder: (_, idx) {
                      final pageNum = idx + 1;
                      final cached = _service.getCachedMushafPage(pageNum);
                      if (cached == null) {
                        _ensurePageLoaded(pageNum);
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 8),
                              Text(isAr ? 'جاري تحميل صفحة $pageNum...' : 'Loading page $pageNum...', style: TextStyle(color: pal.textMuted, fontSize: 12)),
                            ],
                          ),
                        );
                      }
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: _readingLangMode == 'en'
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: cached.$3.map((v) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: InkWell(
                                    onTap: () => setState(() => _selectedAyahNumber = v.ayahNumber),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Text('${v.uthmani} ﴿${v.ayahNumber}﴾', textDirection: TextDirection.rtl, style: TextStyle(fontSize: _fontSize - 3, color: mushafTextColor)),
                                        if (v.translationEn.isNotEmpty)
                                          Text('(${v.ayahNumber}) ${v.translationEn}', textDirection: TextDirection.ltr, style: TextStyle(fontSize: 13, color: pal.gold)),
                                      ],
                                    ),
                                  ),
                                )).toList(),
                              )
                            : _buildMushafRichText(cached.$3, mushafTextColor, pal),
                      );
                    },
                  ),
                )
              else if (_loadingSurah)
                const Padding(padding: EdgeInsets.all(28), child: Center(child: CircularProgressIndicator()))
              else if (_readingLangMode == 'ar')
                _buildMushafRichText(displayVerses, mushafTextColor, pal)
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: displayVerses.map((v) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: InkWell(
                      onTap: () => setState(() => _selectedAyahNumber = v.ayahNumber),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('${v.uthmani} ﴿${v.ayahNumber}﴾', textDirection: TextDirection.rtl, style: TextStyle(fontSize: _fontSize - 2, color: mushafTextColor)),
                          if (v.translationEn.isNotEmpty)
                            Text('(${v.ayahNumber}) ${v.translationEn}', textDirection: TextDirection.ltr, style: TextStyle(fontSize: 13, color: pal.textMuted)),
                        ],
                      ),
                    ),
                  )).toList(),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: pal.cardBg, borderRadius: BorderRadius.circular(18), border: Border.all(color: pal.border)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    isAr
                        ? '📖 تفسير الآية ${selectedVerseObj.ayahNumber} • ${selectedVerseObj.surahNameAr}'
                        : '📖 Ayah ${selectedVerseObj.ayahNumber} Tafsir',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: pal.gold),
                  ),
                  Wrap(
                    spacing: 4,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: pal.emerald, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                        onPressed: () => _playSingleAyah(selectedVerseObj, continueChain: false),
                        icon: const Icon(Icons.volume_up, size: 16),
                        label: Text(isAr ? 'سماع الآية' : 'Play Ayah', style: const TextStyle(fontSize: 11)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        color: pal.emerald,
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: '${selectedVerseObj.uthmani} ﴿${selectedVerseObj.ayahNumber}﴾'));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isAr ? 'تم نسخ الآية' : 'Ayah copied')));
                        },
                      ),
                      IconButton(
                        icon: Icon(isCurrentVerseBookmarked ? Icons.bookmark : Icons.bookmark_border, size: 20),
                        color: pal.gold,
                        onPressed: () {
                          widget.controller.toggleBookmark(
                            QuranBookmarkItem(
                              surahNumber: selectedVerseObj.surahNumber,
                              surahName: selectedVerseObj.surahNameAr.isNotEmpty ? selectedVerseObj.surahNameAr : 'سورة $surahAr',
                              ayahNumber: selectedVerseObj.ayahNumber,
                              mushafPage: _currentMushafPage,
                              previewText: selectedVerseObj.uthmani,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(selectedVerseObj.tafsirAr, style: TextStyle(fontSize: 13, height: 1.65, color: pal.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }
}
