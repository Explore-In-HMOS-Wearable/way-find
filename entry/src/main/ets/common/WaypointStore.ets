import dataPreferences from '@ohos.data.preferences';

const PREFERENCES_FILE = 'waypoints_prefs';

export interface Waypoint {
  name: string;
  tag: string;
  lat: number;
  lon: number;
}

export async function loadWaypoints(context: Context): Promise<Waypoint[]> {
  const prefs = await dataPreferences.getPreferences(context, PREFERENCES_FILE);
  const raw = await prefs.get('waypoints', '[]') as string;
  return JSON.parse(raw) as Waypoint[];
}

export async function saveWaypoints(context: Context, waypoints: Waypoint[]) {
  const prefs = await dataPreferences.getPreferences(context, PREFERENCES_FILE);
  await prefs.put('waypoints', JSON.stringify(waypoints));
  await prefs.flush();
}