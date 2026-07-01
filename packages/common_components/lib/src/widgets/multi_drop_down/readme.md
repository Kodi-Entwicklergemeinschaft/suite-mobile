# MultiSelectDropdown

A fully customizable, generic multi-select dropdown widget for Flutter with search functionality, chips display, and Material Design styling.

## Features

- Generic type support (`<T>`) - works with any data type
- Search/filter functionality
- Selected items displayed as chips inside the input field
- Maximum selection limit
- Fully customizable decorations (input, chips, dropdown)
- Dropdown always appears below the input
- Stays open for multiple selections

## Basic Usage

### With Strings

```dart
MultiSelectDropdown<String>(
  items: const [
    MultiSelectItem(value: 'apple', label: 'Apple'),
    MultiSelectItem(value: 'banana', label: 'Banana'),
    MultiSelectItem(value: 'cherry', label: 'Cherry'),
  ],
  maxSelection: 2,
  onSelectionChanged: (List<String> selected) {
    print('Selected: $selected');
  },
)
```

### With Integer IDs

```dart
MultiSelectDropdown<int>(
  items: const [
    MultiSelectItem(value: 1, label: 'Option 1'),
    MultiSelectItem(value: 2, label: 'Option 2'),
    MultiSelectItem(value: 3, label: 'Option 3'),
  ],
  initialValues: [1], // Pre-select option 1
  onSelectionChanged: (List<int> selectedIds) {
    print('Selected IDs: $selectedIds');
  },
)
```

### With Custom Model

```dart
class LocationModel {
  final String title;
  final double latitude;
  final double longitude;

  const LocationModel({
    required this.title,
    required this.latitude,
    required this.longitude,
  });

  // Required for Set comparison when using initialValues
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationModel &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}

// Usage
final locations = [
  LocationModel(title: 'Paris', latitude: 48.8566, longitude: 2.3522),
  LocationModel(title: 'London', latitude: 51.5074, longitude: -0.1278),
  LocationModel(title: 'Tokyo', latitude: 35.6762, longitude: 139.6503),
];

MultiSelectDropdown<LocationModel>(
  items: locations
      .map((loc) => MultiSelectItem(value: loc, label: loc.title))
      .toList(),
  maxSelection: 2,
  onSelectionChanged: (List<LocationModel> selected) {
    for (final loc in selected) {
      print('${loc.title}: ${loc.latitude}, ${loc.longitude}');
    }
  },
)
```

## Customization

### Full Customization Example

```dart
MultiSelectDropdown<String>(
  width: 350,
  items: const [
    MultiSelectItem(value: 'apple', label: 'Apple'),
    MultiSelectItem(value: 'banana', label: 'Banana'),
    MultiSelectItem(value: 'cherry', label: 'Cherry'),
  ],
  maxSelection: 3,
  hint: 'Select fruits',
  decoration: MultiSelectDecoration(
    border: BorderSide(color: Colors.blue, width: 1.5),
    borderRadius: BorderRadius.circular(12),
    fillColor: Colors.blue.shade50,
    contentPadding: EdgeInsets.all(8),
  ),
  chipDecoration: MultiSelectChipDecoration(
    backgroundColor: Colors.blue.shade100,
    deleteIconColor: Colors.blue.shade700,
    labelStyle: TextStyle(fontSize: 13, color: Colors.blue.shade900),
    borderRadius: BorderRadius.circular(8),
    spacing: 8,
    runSpacing: 8,
  ),
  dropdownDecoration: MultiSelectDropdownDecoration(
    elevation: 8,
    borderRadius: BorderRadius.circular(12),
    backgroundColor: Colors.white,
    maxHeight: 250,
  ),
  onSelectionChanged: (selected) {
    print('Selected: $selected');
  },
)
```

## API Reference

### MultiSelectDropdown

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `items` | `List<MultiSelectItem<T>>` | required | List of selectable items |
| `onSelectionChanged` | `ValueChanged<List<T>>?` | null | Callback when selection changes |
| `hint` | `String` | 'Search and select' | Placeholder text |
| `width` | `double` | 250 | Width of the dropdown |
| `maxSelection` | `int?` | null | Maximum number of selections (null = unlimited) |
| `initialValues` | `List<T>?` | null | Pre-selected values |
| `decoration` | `MultiSelectDecoration?` | null | Input container decoration |
| `chipDecoration` | `MultiSelectChipDecoration?` | null | Chip styling |
| `dropdownDecoration` | `MultiSelectDropdownDecoration?` | null | Dropdown menu styling |

### MultiSelectItem

| Parameter | Type | Description |
|-----------|------|-------------|
| `value` | `T` | The actual value (returned in onSelectionChanged) |
| `label` | `String` | Display text shown in dropdown and chips |

### MultiSelectDecoration

| Parameter | Type | Description |
|-----------|------|-------------|
| `border` | `BorderSide?` | Border style |
| `borderRadius` | `BorderRadius?` | Corner radius |
| `focusedBorder` | `BorderSide?` | Border when focused |
| `fillColor` | `Color?` | Background color |
| `contentPadding` | `EdgeInsets?` | Internal padding |

### MultiSelectChipDecoration

| Parameter | Type | Description |
|-----------|------|-------------|
| `backgroundColor` | `Color?` | Chip background color |
| `deleteIconColor` | `Color?` | Close icon color |
| `labelStyle` | `TextStyle?` | Chip text style |
| `borderRadius` | `BorderRadius?` | Chip corner radius |
| `padding` | `EdgeInsets?` | Chip internal padding |
| `spacing` | `double?` | Horizontal space between chips |
| `runSpacing` | `double?` | Vertical space between chip rows |

### MultiSelectDropdownDecoration

| Parameter | Type | Description |
|-----------|------|-------------|
| `elevation` | `double?` | Shadow elevation |
| `borderRadius` | `BorderRadius?` | Corner radius |
| `backgroundColor` | `Color?` | Menu background color |
| `maxHeight` | `double?` | Maximum dropdown height |

## Notes

1. **Custom Models with `initialValues`**: When using custom models with `initialValues`, ensure your model implements `==` and `hashCode` operators for proper Set comparison. Alternatively, use the `equatable` package.

2. **Search Behavior**: Search filters items by their `label` property (case-insensitive).

3. **Selection Limit**: When `maxSelection` is reached, remaining items are disabled (grayed out) but still visible. The search field hides when max is reached.

4. **Dropdown Position**: The dropdown always appears below the input field, never above.

5. **Chip Overflow**: Long labels in chips will be displayed fully. Consider truncating labels if needed:
   ```dart
   MultiSelectItem(
     value: myModel,
     label: myModel.title.length > 20
         ? '${myModel.title.substring(0, 20)}...'
         : myModel.title,
   )
   ```

6. **State Management**: The widget manages its own state internally. For external state management (Riverpod, Bloc, etc.), use `onSelectionChanged` to sync with your state and `initialValues` to restore selections.
