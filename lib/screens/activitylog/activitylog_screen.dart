import 'package:flutter/material.dart';
import 'package:aerodry_app/constants/app_state.dart';

// ─── Style helper (TOP-LEVEL) ────────────────────────────────────
class _LogItemStyle {
  final Color lineColor;
  final Color tagBgColor;
  final Color tagTextColor;
  final Color titleColor;
  final Color iconBgColor;
  final String imagePath;
  final double iconPadding;

  _LogItemStyle({
    required this.lineColor,
    required this.tagBgColor,
    required this.tagTextColor,
    required this.titleColor,
    required this.iconBgColor,
    required this.imagePath,
    this.iconPadding = 8,
  });
}

// ─── ActivityLogScreen ─────────────────────────────────────────────
class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  // ─── Search ───────────────────────────────────────────────────────────
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  // ─── Filter ───────────────────────────────────────────────────────────
  // null = all
  String? _selectedFilter;
  final List<String> _filterOptions = ['All', 'Motion', 'Weather', 'Manual'];

  // ─── Date range ───────────────────────────────────────────────────────
  DateTimeRange? _dateRange;

  // ─── Pagination ───────────────────────────────────────────────────────
  static const int _pageSize = 7;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    ActivityLogState.entries.addListener(_onEntriesChanged);
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.toLowerCase();
        _currentPage = 0;
      });
    });
  }

  @override
  void dispose() {
    ActivityLogState.entries.removeListener(_onEntriesChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onEntriesChanged() {
    if (mounted) setState(() => _currentPage = 0);
  }

  // ─── Derive filtered list ─────────────────────────────────────────────
  List<ActivityLogEntry> get _filtered {
    final all = ActivityLogState.entries.value;
    return all.where((e) {
      // filter by type
      if (_selectedFilter != null && _selectedFilter != 'All') {
        if (e.tag.toLowerCase() != _selectedFilter!.toLowerCase()) return false;
      }
      // filter by search
      if (_searchQuery.isNotEmpty) {
        final haystack = '${e.title} ${e.subtitle1} ${e.subtitle2} ${e.tag}'
            .toLowerCase();
        if (!haystack.contains(_searchQuery)) return false;
      }
      // filter by date range
      if (_dateRange != null) {
        final d = DateTime(
          e.timestamp.year,
          e.timestamp.month,
          e.timestamp.day,
        );
        final start = DateTime(
          _dateRange!.start.year,
          _dateRange!.start.month,
          _dateRange!.start.day,
        );
        final end = DateTime(
          _dateRange!.end.year,
          _dateRange!.end.month,
          _dateRange!.end.day,
        );
        if (d.isBefore(start) || d.isAfter(end)) return false;
      }
      return true;
    }).toList();
  }

  // ─── Open filter dropdown ─────────────────────────────────────────────
  void _openFilterMenu(BuildContext context) async {
    final RenderBox btn = context.findRenderObject() as RenderBox;
    final Offset pos = btn.localToGlobal(Offset.zero);
    final String? picked = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        pos.dx,
        pos.dy + btn.size.height + 4,
        pos.dx + btn.size.width,
        0,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      items: _filterOptions
          .map(
            (opt) => PopupMenuItem<String>(
              value: opt,
              child: Row(
                children: [
                  _filterDot(opt),
                  const SizedBox(width: 8),
                  Text(
                    opt,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2B3A67),
                    ),
                  ),
                  if ((_selectedFilter ?? 'All') == opt) ...[
                    const Spacer(),
                    const Icon(Icons.check, size: 16, color: Color(0xFF4F6EDB)),
                  ],
                ],
              ),
            ),
          )
          .toList(),
    );
    if (picked != null) {
      setState(() {
        _selectedFilter = picked == 'All' ? null : picked;
        _currentPage = 0;
      });
    }
  }

  Widget _filterDot(String opt) {
    Color c;
    switch (opt) {
      case 'Motion':
        c = const Color(0xFFFF4444);
        break;
      case 'Weather':
        c = const Color(0xFF6A9EFF);
        break;
      case 'Manual':
        c = const Color(0xFFFFB020);
        break;
      default:
        c = const Color(0xFF9EA3A7);
    }
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
    );
  }

  // ─── Date range picker ────────────────────────────────────────────────
  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4F6EDB),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF2B3A67),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateRange = picked;
        _currentPage = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final totalEntries = filtered.length;
    final totalPages = (totalEntries / _pageSize).ceil();
    final showPagination = totalEntries > _pageSize;

    // Current page slice
    final int start = _currentPage * _pageSize;
    final int end = (start + _pageSize).clamp(0, totalEntries);
    final pageEntries = filtered.sublist(start, end);

    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4F6EDB), Color(0xFF6DB8E8)],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
          ),
          child: Column(
            children: [
              // ─── Top bar ─────────────────────────────────────────────
              const SizedBox(height: 40),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              'Activity Log',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                height: 1,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'See all your recent activities.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 22),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ─── Search + Filter bar ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    // Search input with calendar inside
                    Expanded(
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA4C7F4),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search,
                              size: 16,
                              color: Color(0xFFE4F0FF),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: TextField(
                                controller: _searchCtrl,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                cursorColor: Colors.white,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  hintText: 'Search activity...',
                                  hintStyle: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFFE4F0FF),
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            // Clear button
                            if (_searchQuery.isNotEmpty)
                              GestureDetector(
                                onTap: () => _searchCtrl.clear(),
                                child: const Padding(
                                  padding: EdgeInsets.only(right: 4),
                                  child: Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Color(0xFFE4F0FF),
                                  ),
                                ),
                              ),
                            // Calendar icon inside search bar
                            GestureDetector(
                              onTap: _pickDateRange,
                              child: Icon(
                                Icons.calendar_today_rounded,
                                size: 16,
                                color: _dateRange != null
                                    ? Colors.white
                                    : const Color(0xFFE4F0FF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Filter button
                    Builder(
                      builder: (btnCtx) => GestureDetector(
                        onTap: () => _openFilterMenu(btnCtx),
                        child: Container(
                          height: 36,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: _selectedFilter != null
                                ? const Color(0xFF4F6EDB)
                                : const Color(0xFFEAF4FF),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.filter_alt_rounded,
                                size: 16,
                                color: _selectedFilter != null
                                    ? Colors.white
                                    : const Color(0xFF8C9DAE),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _selectedFilter ?? 'Filter',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _selectedFilter != null
                                      ? Colors.white
                                      : const Color(0xFF8C9DAE),
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 16,
                                color: _selectedFilter != null
                                    ? Colors.white
                                    : const Color(0xFF8C9DAE),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Active date range chip
              if (_dateRange != null)
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24, top: 6),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.date_range_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_dateRange!.start.day}/${_dateRange!.start.month}/${_dateRange!.start.year}'
                              ' – '
                              '${_dateRange!.end.day}/${_dateRange!.end.month}/${_dateRange!.end.year}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => setState(() => _dateRange = null),
                              child: const Icon(
                                Icons.close,
                                size: 13,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 13),

              // ─── White card list ──────────────────────────────────────
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      // List
                      Expanded(
                        child: pageEntries.isEmpty
                            ? _buildEmpty()
                            : ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: pageEntries.length,
                                itemBuilder: (ctx, i) =>
                                    _HistoryItem(entry: pageEntries[i]),
                              ),
                      ),

                      // Pagination (only when more than one page)
                      if (showPagination)
                        _buildPagination(totalEntries, totalPages, start, end),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: Color(0xFFCCCCCC)),
          SizedBox(height: 12),
          Text(
            'No activities found',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFAAAAAA),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(int total, int totalPages, int start, int end) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Prev
          GestureDetector(
            onTap: _currentPage > 0
                ? () => setState(() => _currentPage--)
                : null,
            child: Icon(
              Icons.chevron_left,
              size: 22,
              color: _currentPage > 0
                  ? const Color(0xFF4F6EDB)
                  : const Color(0xFFCCCCCC),
            ),
          ),
          const SizedBox(width: 4),
          // Page numbers
          ...List.generate(totalPages, (i) {
            final isActive = i == _currentPage;
            return GestureDetector(
              onTap: () => setState(() => _currentPage = i),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF0D3473)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    color: isActive ? Colors.white : const Color(0xFF8E8E8E),
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(width: 4),
          // Next
          GestureDetector(
            onTap: _currentPage < totalPages - 1
                ? () => setState(() => _currentPage++)
                : null,
            child: Icon(
              Icons.chevron_right,
              size: 22,
              color: _currentPage < totalPages - 1
                  ? const Color(0xFF4F6EDB)
                  : const Color(0xFFCCCCCC),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── History Item ─────────────────────────────────────────────────────────────
class _HistoryItem extends StatelessWidget {
  final ActivityLogEntry entry;
  const _HistoryItem({required this.entry});

  // ─── Fungsi penentu warna & icon ────────────────────────────────
  _LogItemStyle _getStyle(ActivityLogEntry entry) {
    final String title = entry.title;
    final String tag = entry.tag;

    // 1. Retracted Alert + Weather → abu-abu semua, icon tutupjemurancard
    if (title.contains('Retracted') && tag.toLowerCase() == 'weather') {
      return _LogItemStyle(
        lineColor: const Color(0xFF9EA3A7),
        tagBgColor: const Color(0xFFE3E6E7),
        tagTextColor: const Color(0xFF9EA3A7),
        titleColor: const Color(0xFF9EA3A7),
        iconBgColor: const Color(0xFFE5E5E5),
        imagePath: 'assets/images/masukweathercard.png',
        iconPadding: 6,
      );
    }

    // 2. Extended Alert + Weather → biru semua, icon bukajemurancard
    if (title.contains('Extended') && tag.toLowerCase() == 'weather') {
      return _LogItemStyle(
        lineColor: const Color(0xFF6A9EFF),
        tagBgColor: const Color(0xFFC6D7FF),
        tagTextColor: const Color(0xFF5E93FF),
        titleColor: const Color(0xFF5E93FF),
        iconBgColor: const Color(0xFFDCE7FF),
        imagePath: 'assets/images/bukajemurancard.png',
        iconPadding: 6,
      );
    }

    // 3. Motion Detected → merah semua, tag Motion merah, icon motioncard
    if (title.contains('Motion Detected')) {
      return _LogItemStyle(
        lineColor: const Color(0xFFFF4444),
        tagBgColor: const Color(0xFFFFCACA),
        tagTextColor: const Color(0xFFFF4444),
        titleColor: const Color(0xFFFF1E1E),
        iconBgColor: const Color(0xFFFFE0E0),
        imagePath: 'assets/images/motioncard.png',
        iconPadding: 9,
      );
    }

    // 4. Retracted Alert + Motion → abu-abu semua TAPI tag Motion merah
    if (title.contains('Retracted') && tag.toLowerCase() == 'motion') {
      return _LogItemStyle(
        lineColor: const Color(0xFF9EA3A7),
        tagBgColor: const Color(0xFFFFCACA),
        tagTextColor: const Color(0xFFFF4444),
        titleColor: const Color(0xFF9EA3A7),
        iconBgColor: const Color(0xFFE5E5E5),
        imagePath: 'assets/images/masukweathercard.png',
        iconPadding: 4,
      );
    }

    // 5. Manual → orange semua
    if (entry.type == ActivityType.manual || tag.toLowerCase() == 'manual') {
      final isOut = title.contains('Extended') || title.toLowerCase().contains('out');
      return _LogItemStyle(
        lineColor: const Color(0xFFFF9F0A),
        tagBgColor: const Color(0xFFFFECC8),
        tagTextColor: const Color(0xFFFF9F0A),
        titleColor: const Color(0xFFFF9F0A),
        iconBgColor: const Color(0xFFFFE8C8),
        imagePath: isOut
            ? 'assets/images/keluarmanualcard.png'
            : 'assets/images/masukmanualcard.png',
        iconPadding: 7,
      );
    }

    // Fallback: motion type merah
    if (entry.type == ActivityType.motion) {
      return _LogItemStyle(
        lineColor: const Color(0xFFFF4444),
        tagBgColor: const Color(0xFFFFCACA),
        tagTextColor: const Color(0xFFFF4444),
        titleColor: const Color(0xFFFF1E1E),
        iconBgColor: const Color(0xFFFFE0E0),
        imagePath: 'assets/images/motioncard.png',
        iconPadding: 8,
      );
    }

    // Fallback: weather type
    if (entry.type == ActivityType.weather) {
      final isRetracted = title.contains('Retracted') || entry.isRain;
      return _LogItemStyle(
        lineColor: isRetracted ? const Color(0xFF9EA3A7) : const Color(0xFF6A9EFF),
        tagBgColor: isRetracted ? const Color(0xFFE3E6E7) : const Color(0xFFC6D7FF),
        tagTextColor: isRetracted ? const Color(0xFF9EA3A7) : const Color(0xFF5E93FF),
        titleColor: isRetracted ? const Color(0xFF9EA3A7) : const Color(0xFF5E93FF),
        iconBgColor: isRetracted ? const Color(0xFFE5E5E5) : const Color(0xFFDCE7FF),
        imagePath: isRetracted
            ? 'assets/images/masukweathercard.png'
            : 'assets/images/keluarweathercard.png',
      );
    }

    // Default fallback
    return _LogItemStyle(
      lineColor: const Color(0xFF9EA3A7),
      tagBgColor: const Color(0xFFE3E6E7),
      tagTextColor: const Color(0xFF9EA3A7),
      titleColor: const Color(0xFF5B5B5B),
      iconBgColor: const Color(0xFFF0F0F0),
      imagePath: 'assets/images/motioncard.png',
    );
  }

  // ─── Build widget ───────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final style = _getStyle(entry);

    return SizedBox(
      height: 88,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left color bar
          Container(
            width: 5,
            height: 74,
            decoration: BoxDecoration(
              color: style.lineColor,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(width: 10),

          // Image icon circle
          Container(
            width: 49,
            height: 49,
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: style.iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SizedBox(
                width: 49 - style.iconPadding * 2,
                height: 49 - style.iconPadding * 2,
                child: Image.asset(
                  style.imagePath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Text content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    maxLines: 1,
                    style: TextStyle(
                      color: style.titleColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    entry.subtitle1,
                    style: const TextStyle(
                      color: Color(0xFFB0B0B0),
                      fontSize: 14,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (entry.subtitle2.isNotEmpty)
                    Text(
                      entry.subtitle2,
                      style: const TextStyle(
                        color: Color(0xFFB0B0B0),
                        fontSize: 14,
                        height: 1.2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        entry.isRain
                            ? Icons.cloudy_snowing
                            : Icons.wb_sunny_rounded,
                        color: entry.isRain
                            ? const Color(0xFF78B8E8)
                            : const Color(0xFFFFC107),
                        size: 13,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        entry.temp,
                        style: const TextStyle(
                          color: Color(0xFF8A8A8A),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFF8A8A8A),
                        size: 13,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        entry.location,
                        style: const TextStyle(
                          color: Color(0xFF8A8A8A),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Time + Tag column
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: style.tagBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    entry.tag,
                    style: TextStyle(
                      color: style.tagTextColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  entry.formattedTime,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Color(0xFF9A9A9A),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

