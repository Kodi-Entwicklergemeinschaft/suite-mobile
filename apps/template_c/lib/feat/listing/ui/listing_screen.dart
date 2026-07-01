import 'dart:developer';

import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/feat/home/widgets/listing/listing_item_card.dart';
import 'package:template_c/feat/home/widgets/listing/listing_loading.dart';
import 'package:template_c/feat/listing/controller/listing_screen_controller.dart';
import 'package:template_c/feat/listing/params/listing_screen_params.dart';
import 'package:template_c/router/route_constant.dart';

class ListingScreen extends BaseStatefulWidget {
  final ListingScreenParams params;

  const ListingScreen({super.key, required this.params});

  @override
  String get screenName => RouteConstant.listingScreen.name;

  @override
  ConsumerState<ListingScreen> createState() => _ListingScreenState();
}

class _ListingScreenState extends BaseStatefulWidgetState<ListingScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() {
      if (!mounted) return;
      log(
        "Listing Screen family Key ${widget.params.familyKey}",
        name: 'ListingScreenFamilyKey',
      );

      ref
          .read(
            listingScreenControllerProvider(widget.params.familyKey).notifier,
          )
          .getListing(widget.params.initialFilter);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200.h) {
      ref
          .read(
            listingScreenControllerProvider(widget.params.familyKey).notifier,
          )
          .loadMore();
    }
  }

  Widget _buildCard(item) {
    void onTap() => _onCardTap(item.id);

    void onFavTap() {
      final ctrl = ref.read(
        listingScreenControllerProvider(widget.params.familyKey).notifier,
      );
      if (item.id == null) return;
      if (item.isFavorite == true) {
        ctrl.removeFav(id: item.id!);
      } else {
        ctrl.addFav(id: item.id!);
      }
    }

    switch (widget.params.cardVariant) {
      case ListingCardVariant.subcategory:
        return ListingItemCard.subcategory(model: item, onTap: onTap);
      case ListingCardVariant.moreDates:
        return ListingItemCard.moreDates(model: item, onTap: onTap);
      case ListingCardVariant.highlight:
        return ListingItemCard.highlight(model: item, onTap: onTap);
      case ListingCardVariant.standard:
        return ListingItemCard(
          model: item,
          onTap: onTap,
          onFavoriteTap: onFavTap,
        );
      case ListingCardVariant.compact:
        return ListingItemCard.compact(model: item, onTap: onTap);
    }
  }

  void _onCardTap(String? id) {
    if (id == null || id.isEmpty) return;
    context.pushNamed(
      RouteConstant.listingDetail.name,
      pathParameters: {'id': id},
      queryParameters: {'familyKey': widget.params.familyKey},
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      listingScreenControllerProvider(widget.params.familyKey),
    );

    return Scaffold(
      appBar: CommonAppBar(
        title: widget.params.screenTitle,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16.sp,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1),
        ),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(state) {
    final isFirstLoad =
        state.stateConstant == StateConstant.loading && state.items.isEmpty;

    if (isFirstLoad) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: ListingShimmerV2(),
      );
    }

    if (state.stateConstant == StateConstant.error && state.items.isEmpty) {
      return const ListingStatusWidget(isError: true);
    }

    if (state.items.isEmpty) {
      return const ListingStatusWidget(isEmpty: true);
    }

    return RefreshIndicator(
      onRefresh: () => ref
          .read(
            listingScreenControllerProvider(widget.params.familyKey).notifier,
          )
          .refresh(),
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          16.w,
          16.h,
          16.w,
          32.h + MediaQuery.of(context).padding.bottom,
        ),
        itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => SizedBox(
          height: widget.params.cardVariant == ListingCardVariant.standard
              ? 24.h
              : 12.h,
        ),
        itemBuilder: (context, index) {
          if (index == state.items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final item = state.items[index];
          return _buildCard(item);
        },
      ),
    );
  }
}
