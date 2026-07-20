import 'package:flutter/material.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';

class ModalSheet<T> {
  final BuildContext context;
  final String title;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T) onItemSelected;
  final bool Function(T, String)? searchFilter;
  final String searchHint;

  ModalSheet({
    required this.context,
    required this.title,
    required this.items,
    required this.itemLabel,
    required this.onItemSelected,
    this.searchFilter,
    this.searchHint = 'Search...',
  });

  Future<void> show() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: kOverlayScrim,
      builder: (context) => _ModalSheetContent<T>(
        title: title,
        items: items,
        itemLabel: itemLabel,
        onItemSelected: onItemSelected,
        searchFilter: searchFilter,
        searchHint: searchHint,
      ),
    );
  }
}

class _ModalSheetContent<T> extends StatefulWidget {
  const _ModalSheetContent({
    required this.title,
    required this.items,
    required this.itemLabel,
    required this.onItemSelected,
    this.searchFilter,
    required this.searchHint,
  });

  final String title;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T) onItemSelected;
  final bool Function(T, String)? searchFilter;
  final String searchHint;

  @override
  State<_ModalSheetContent<T>> createState() => _ModalSheetContentState<T>();
}

class _ModalSheetContentState<T> extends State<_ModalSheetContent<T>> {
  late final TextEditingController _searchController;
  late List<T> _filteredItems;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
        return;
      }

      _filteredItems = widget.items.where((item) {
        if (widget.searchFilter != null) {
          return widget.searchFilter!(item, query);
        }
        return widget
            .itemLabel(item)
            .toLowerCase()
            .contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      top: false,
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: kGreyLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: kBodyTitleSB.copyWith(fontSize: 18),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: kMutedText),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterItems,
                    autofocus: true,
                    style: kBodyTitleR.copyWith(color: kTextColor),
                    decoration: InputDecoration(
                      hintText: widget.searchHint,
                      hintStyle: kBodyTitleR.copyWith(color: kSecondaryTextColor),
                      prefixIcon: const Icon(Icons.search, color: kMutedText),
                      filled: true,
                      fillColor: kScreenBg,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kPrimaryColor),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kBorder),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: keyboardHeight),
                    child: _filteredItems.isEmpty
                        ? Center(
                            child: Text(
                              'No results found',
                              style: kEmptyStateM,
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: _filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = _filteredItems[index];
                              return InkWell(
                                onTap: () {
                                  widget.onItemSelected(item);
                                  Navigator.pop(context);
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 14,
                                  ),
                                  child: Text(
                                    widget.itemLabel(item),
                                    style: kBodyTitleR.copyWith(
                                      color: kTextColor,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
