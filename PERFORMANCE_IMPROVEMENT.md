# Performance Improvement: Cached Network Images in DriverAdCard

## Issue
The `DriverAdCard` widget currently uses `NetworkImage` for the driver's avatar.

```dart
backgroundImage: driver.photoUrl != null
    ? NetworkImage(driver.photoUrl!)
    : null,
```

This widget is likely used in a `ListView` or `SliverList` (implied by the feature "Find Driver").

### Problems with `NetworkImage` in Lists:
1.  **No Disk Cache:** `NetworkImage` only implements in-memory caching (via `ImageCache`). If the app is restarted or the image is evicted from memory (scrolling far away and back), it must be re-downloaded from the network.
2.  **Network Bandwidth:** Repeatedly downloading the same profile images consumes unnecessary bandwidth and data for the user.
3.  **Latency:** Re-fetching images introduces network latency, causing images to "pop in" as the user scrolls, degrading the user experience.
4.  **Flicker:** Without a placeholder or disk cache, images may flicker when reloading.

## Solution
Replace `NetworkImage` with `CachedNetworkImageProvider` from the `cached_network_image` package.

### Benefits:
1.  **Disk Caching:** Images are stored on the device's storage. Subsequent loads (even after app restart) read from the disk, which is significantly faster than network requests.
2.  **Offline Support:** Images already viewed will be available offline.
3.  **Reduced Data Usage:** Saves user's data plan by not re-downloading unchanged images.
4.  **Smoother Scrolling:** Faster image loading leads to a smoother scrolling experience in lists.

## Benchmark / Measurement Strategy
Since this environment is headless, we rely on established best practices and the known behavior of the `cached_network_image` library.

**Theoretical Improvement:**
- **First Load:** Same speed (Network request).
- **Second Load (Scroll back / Re-open app):**
    - `NetworkImage`: ~100ms - 2s (depending on network).
    - `CachedNetworkImage`: ~5ms - 20ms (Disk I/O).

**Impact:** significantly reduced "jank" during rapid scrolling and immediate display of previously loaded avatars.
