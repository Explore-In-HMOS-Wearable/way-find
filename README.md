> **Note:** To access all shared projects, get information about environment setup, and view other guides, please visit [Explore-In-HMOS-Wearable Index](https://github.com/Explore-In-HMOS-Wearable/hmos-index).

# Way Find App

This is a wearable application developed with ArkTS that allows users to manage and visualize their waypoints on a radar-like interface. The app helps users save locations, view them on a rotating compass, and easily access navigation-related information on wearable devices.
# Preview

<div>
  <img src="screenshots/1.gif" width="25%">
</div>

# Use Cases

- **Waypoint Management:** Add, delete, and store waypoints with name, tag, and coordinates.
- **Current Location:** Use device GPS to fetch and save your current position.
- **Radar View:** Visualize waypoints around you on a rotating compass (N, E, S, W directions).
- **Live Location Updates:** Continuously update and display your current position and heading.
- **Persistent Storage:** Waypoints are saved locally and remain available after restarting the app.
- **Wearable Optimized:** ArcList UI for small screens with smooth navigation.

# Tech Stack
- **Languages**: ArkTS, ArkUI
- **Frameworks**: HarmonyOS 6.0.0 Beta3
- **Tools**: DevEco Studio 6.0.0.828
- **Libraries**:
    - `@kit.ArkUI`
    - `@kit.AbilityKit`
    - `@kit.BasicServicesKit`
    - `@kit.PerformanceAnalysisKit`
    - `@kit.LocationKit`
    - `@ohos.arkui.ArcList`
    - `@ohos.data.preferences`
## Required Permissions
- `ohos.permission.LOCATION`
- `ohos.permission.APPROXIMATELY_LOCATION`

# Directory Structure

```
entry/
├── src/main/
│ 
├── src/main/ets/
│ ├── common/
│ │ ├── LocationUtils.ets
│ │ └── WaypointStore.ets
│ │
│ ├── entryability/
│ │ └── EntryAbility.ets
│ │
│ ├── entrybackupability/
│ │ └── EntryBackupAbility.ets
│ │
│ ├── pages/
│ │ ├── WaypointPage.ets
│ │ ├── Index.ets
│ │
```

# Constraints and Restrictions
## Supported Device

* Huawei Watch 5

# License

**Way Find** is distributed under the terms of the MIT License

See the [LICENSE](./LICENSE) for more information.
