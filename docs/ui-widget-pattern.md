# UI Widget Pattern

Use this pattern for new pages and refactors so page files stay small, logic stays testable, and widget trees do not become hard to scan.

## Folder Shape

```text
lib/src/core/view/feature_name/
  _.dart
  controller_mixin.dart
  feature_name_page.dart
  widgets/
    _.dart
    feature_name_widget.dart
```

## Responsibilities

### `feature_name_page.dart`

Keep this file as the page shell only.

It can contain:

- `StatefulWidget` / `State`
- `Scaffold`
- drawer wiring
- app bar widget
- body widget
- route-level dependency wiring

Avoid putting large inline widget trees, business logic, async loading, or repeated UI sections here.

### `controller_mixin.dart`

Put page behavior here.

It can contain:

- `signals_flutter` signals
- `TextEditingController`, `ScrollController`, and lifecycle methods
- async loading/saving/deleting logic
- navigation callbacks
- dialog confirmation actions
- cleanup in `dispose`

When a page uses signals, avoid `setState` unless there is a strong reason.

### `widgets/feature_name_widget.dart`

Put UI pieces here.

It can contain:

- page body widget
- app bar widget
- cards/list items
- loading/empty/error states
- small reusable sections

Prefer named widgets over very large inline widget trees.

## Example

```dart
class FeaturePage extends StatefulWidget {
  const FeaturePage({super.key});

  @override
  State<FeaturePage> createState() => _FeaturePageState();
}

class _FeaturePageState extends State<FeaturePage>
    with FeaturePageControllerMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppMenuDrawer(
        currentDestination: AppMenuDestination.logs,
        onSelectDestination: onSelectDestination,
      ),
      appBar: FeatureAppBar(
        isLoading: isLoading,
        onRefresh: loadData,
      ),
      body: FeatureWidget(
        isLoading: isLoading,
        errorMessage: errorMessage,
        items: items,
        onRefresh: loadData,
      ),
    );
  }
}
```

## Export Pattern

Do not manually maintain `_.dart` export files.

After adding, moving, or removing page/widget/controller files, run:

```sh
make ex
```

The project tool will regenerate `_.dart` files automatically. This keeps imports simple through `package:r99/export.dart`.
