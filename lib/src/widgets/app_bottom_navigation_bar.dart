part of widgets;
/*
class AppBottomBarController<T> extends ValueNotifier<T> {
  AppBottomBarController({
    required T value,
  }) : super(value);
}

class AppBottomNavigationBar<T> extends StatefulWidget {
  final AppBottomBarController<T> controller;
  final Map<T, Widget Function(BuildContext context, bool isSelected)>
      itemBuilder;
  final Map<T, String>? labels;
  final Map<T, Color?> selectedColors;
  final Widget? onTop;

  const AppBottomNavigationBar({
    super.key,
    required this.itemBuilder,
    required this.controller,
    this.selectedColors = const {},
    this.labels,
    this.onTop,
  });

  @override
  State<AppBottomNavigationBar<T>> createState() =>
      _AppBottomNavigationBarState<T>();
}

class _AppBottomNavigationBarState<T> extends State<AppBottomNavigationBar<T>> {
  late final ValueNotifier<int> _activeIndex;

  @override
  void initState() {
    super.initState();
    _activeIndex = ValueNotifier<int>(0);
    _controllerListener();
    widget.controller.addListener(_controllerListener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_controllerListener);
    _activeIndex.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AppBottomNavigationBar<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.controller.removeListener(_controllerListener);
    widget.controller.addListener(_controllerListener);
  }

  void _controllerListener() {
    final int index =
        widget.itemBuilder.keys.toList().indexOf(widget.controller.value);
    if (index == -1) {
      throw "Error! Unknown index!";
    }
    _activeIndex.value = index;
  }

  @override
  Widget build(BuildContext context) {
    final List<NavigationBarAnimatedItem> items =
        widget.itemBuilder.entries.map<NavigationBarAnimatedItem>((e) {
      return NavigationBarAnimatedItem(
        itemBuilder: e.value,
        label: widget.labels?[e.key] ?? "",
        selectedColor: widget.selectedColors[e.key],
      );
    }).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.onTop != null) widget.onTop!,
        ValueListenableBuilder<int>(
          valueListenable: _activeIndex,
          builder: (context, activeIndex, _) {
            return NavigationBarAnimated(
              backgroundColor: Colors.white,
              items: items,
              currentSelection: activeIndex,
              onSelected: (value) {
                final T item = widget.itemBuilder.keys.toList()[value];
                widget.controller.value = item;
              },
            );
          },
        ),
      ],
    );
  }
}

class AppBottomNavigationControlledView<T> extends StatefulWidget {
  final AppBottomBarController<T> controller;
  final Map<T, Widget Function(BuildContext context)> viewBuilder;

  const AppBottomNavigationControlledView({
    super.key,
    required this.controller,
    required this.viewBuilder,
  });

  @override
  State<AppBottomNavigationControlledView<T>> createState() =>
      _AppBottomNavigationControlledViewState<T>();
}

class _AppBottomNavigationControlledViewState<T>
    extends State<AppBottomNavigationControlledView<T>> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    widget.controller.addListener(_controllerListener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_controllerListener);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AppBottomNavigationControlledView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.controller.removeListener(_controllerListener);
    widget.controller.addListener(_controllerListener);
  }

  void _controllerListener() {
    final int page = widget.viewBuilder.keys.toList().indexWhere(
          (element) => element == widget.controller.value,
        );
    if (page == -1) {
      throw "Could not find page for corresponding item";
    }
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget Function(BuildContext context)> widgetBuilders =
        widget.viewBuilder.values.toList();
    return PageView.builder(
      controller: _pageController,
      itemBuilder: (context, index) => widgetBuilders[index](context),
      itemCount: widgetBuilders.length,
      physics: const NeverScrollableScrollPhysics(),
    );
  }
}
*/
