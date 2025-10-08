import { geoLocationManager } from '@kit.LocationKit';
import { calculateBearing, calcDistance } from '../common/LocationUtils';
import { loadWaypoints , Waypoint} from '../common/WaypointStore';
import { router } from '@kit.ArkUI';


interface WaypointWithDistance extends Waypoint {
  dist: number;
  bearing: number;
}

interface waypointScreenPos {
  x: number;
  y: number;
}

@Entry
@Component
struct Index {
  @State latitude: number = 0;
  @State longitude: number = 0;
  @State altitude: number = 0;
  @State bearing: number = 0;
  @State speed: number = 0;
  @State heading: number = 0;
  @State waypointScreenPos: waypointScreenPos[] = [];
  @State waypoints: Waypoint[] = [];
  @State selectedIndex: number = 0;
  private speedHistory: number[] = [];
  private maxHistory: number = 5;
  private lastLat: number | null = null;
  private lastLon: number | null = null;
  private lastTime: number | null = null;
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private updateSpeed(newSpeed: number){
    this.speedHistory.push(newSpeed)
    if(this.speedHistory.length > this.maxHistory){
      this.speedHistory.shift()
    }
    let sum = this.speedHistory.reduce((a,b) => a + b, 0)
    this.speed = sum / this.speedHistory.length
  }
  private drawRadar = (ctx:
    CanvasRenderingContext2D) => {
    this.waypointScreenPos = [];
    let centerX = ctx.width / 2;
    let centerY = ctx.height / 2;
    let r = Math.min(centerX, centerY) - 20;
    ctx.fillStyle = '#111';
    ctx.fillRect(0, 0, ctx.width, ctx.height)
    ctx.strokeStyle = '#0f0';
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(centerX - r + 33, centerY);
    ctx.lineTo(centerX + r - 33, centerY);
    ctx.moveTo(centerX, centerY - r + 33);
    ctx.lineTo(centerX, centerY + r - 33);
    ctx.stroke();
    ctx.beginPath();
    ctx.moveTo(centerX - r + 25, centerY - r + 25);
    ctx.lineTo(centerX + r - 25, centerY + r - 25);
    ctx.moveTo(centerX - r + 25, centerY + r - 25);
    ctx.lineTo(centerX + r - 25, centerY - r + 25);
    ctx.stroke();
    let distances: WaypointWithDistance[] = this.waypoints.map(wp => ({
      name: wp.name,
      tag: wp.tag,
      lat: wp.lat,
      lon: wp.lon,
      dist:
      calcDistance(this.latitude, this.longitude, wp.lat, wp.lon),
      bearing:
      calculateBearing(this.latitude, this.longitude, wp.lat, wp.lon)
    } as WaypointWithDistance));
    distances.sort((a, b) => a.dist - b.dist);
    const maxDist = distances.length > 0 ? distances[distances.length - 1].dist : 1000;
    ctx.strokeStyle = '#0f0';
    ctx.lineWidth = 1.5;
    const rings = 3;
    for (let i = 1; i <= rings; i++) {

      const rr = (r / rings) * i;

      ctx.fillStyle = '#fff';
      ctx.font = '14px sans-serif';
      ctx.textAlign = 'right';
      ctx.textBaseline = 'middle';
      ctx.fillText(`Altitude`, centerX - 68, centerY - 6)
      ctx.fillText(`${this.altitude?.toFixed(1)} m`, centerX - 70, centerY + 3)
      ctx.beginPath();
      ctx.arc(centerX, centerY, rr, 0, 2 * Math.PI);
      ctx.stroke();
      const ringDist = (maxDist / rings) * i;
      ctx.fillStyle = '#0f0';
      ctx.font = 'bold 12px sans-serif';
      ctx.textAlign = 'left';
      ctx.textBaseline = 'middle';
      ctx.fillText(`${(ringDist / 1000).toFixed(0)}km`, centerX + rr - 26, centerY - 3);
    }
    const fov = 60;
    const startAngle = (-fov / 2 - 90) * Math.PI / 180;
    const endAngle = (fov / 2 - 90) * Math.PI / 180;
    ctx.fillStyle = 'rgba(255, 0, 0, 0.2)';
    ctx.beginPath();
    ctx.moveTo(centerX, centerY);
    ctx.arc(centerX, centerY, r, startAngle, endAngle);
    ctx.closePath();
    ctx.fill();

    for (let i = 0; i < distances.length; i++) {
      const wp = distances[i];
      const angle = ((wp.bearing - this.heading + 90 + 360) % 360) * Math.PI / 180;
      const distRatio = Math.min(1, wp.dist / maxDist);
      const wx = centerX + Math.cos(angle) * (r * distRatio);
      const wy = centerY - Math.sin(angle) * (r * distRatio);
      this.waypointScreenPos.push({ x: wx, y: wy });
      ctx.beginPath();
      ctx.arc(wx, wy, 6, 0, 2 * Math.PI);
      ctx.fillStyle = (i === this.selectedIndex ? '#f00' : '#0ff');
      ctx.fill();
      ctx.fillStyle = (i === this.selectedIndex ? '#0ff' : '#f00');
      ctx.font = 'bold 14px sans-serif';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillText(wp.tag, wx, wy)

    }

    ctx.fillStyle = '#ff0';
    ctx.beginPath();
    ctx.arc(centerX, centerY, 3, 0, 2 * Math.PI);
    ctx.fill()
    if (this.selectedIndex >= 0 && this.selectedIndex < distances.length) {
      const d = distances[this.selectedIndex].dist;
      ctx.fillStyle = '#fff';
      ctx.font = '16px sans-serif';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'bottom';
      ctx.fillText(`Target: ${(d / 1000).toFixed(2)} km`, centerX, ctx.height - 40);
    }
    const dirs = ['N', 'E', 'S', 'W'];
    for (let i = 0; i < 4; i++) {
      const dirAngle = ((i * 90 - this.heading + 180) % 360) * Math.PI / 180;
      const x = centerX + Math.sin(dirAngle) * (r + 10);
      const y = centerX + Math.cos(dirAngle) * (r + 10);
      ctx.fillStyle = '#fff';
      ctx.font = '20px sans-serif';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillText(dirs[i], x, y);
    }

    const speedKmh = (this.speed * 3.6).toFixed(0);
    ctx.fillStyle = '#fff';
    ctx.font = '14px sans-serif';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'bottom';
    ctx.fillText(`${speedKmh} km/h`, centerX, ctx.height - 25);

  }

  aboutToAppear() {
    this.startTracking()
    loadWaypoints(getContext(this)).then(list => {
      this.waypoints = list
      this.drawRadar(this.ctx);
    })
  }
  onPageShow() {
    loadWaypoints(getContext(this)).then(list => {
      this.waypoints = list
      this.drawRadar(this.ctx);
    })
  }

  startTracking(intervalMs: number = 1000) {
    let request: geoLocationManager.ContinuousLocationRequest =
      { 'interval': 1, 'locationScenario': geoLocationManager.UserActivityScenario.NAVIGATION };
    let locationCallback = (location: geoLocationManager.Location): void => {
      console.info('locationCallback: data: ' + JSON.stringify(location));
      let now = Date.now();
      if(this.lastLat !== null && this.lastLon !== null && this.lastTime !== null){
        let distance = calcDistance(this.lastLat, this.lastLon, location.latitude, location.longitude)
        let dt = (now - this.lastTime) / 1000;
        if(dt > 0){
          let rawSpeed = (distance / dt) * 3.6;
          this.updateSpeed(rawSpeed);
        }
      }
      this.lastLat = location.latitude;
      this.lastLon = location.longitude;
      this.lastTime = now;
      this.latitude = location.latitude;
      this.longitude = location.longitude;
      this.heading = location.direction;
      this.altitude = location.altitude;
      this.updateBearingAndRedraw();
    };

    try {
      geoLocationManager.on('locationChange', request, locationCallback);
    } catch (err) {
      console.error('errCode:' + err.code + ', message:' + err.message);
    }
  }

  private updateBearingAndRedraw() {
    if (this.selectedIndex >= 0 && this.selectedIndex < this.waypoints.length) {
      const wp = this.waypoints[this.selectedIndex]
      this.bearing = calculateBearing(this.latitude, this.longitude, wp.lat, wp.lon)
    } else {
      this.bearing = 0;
    }
    this.drawRadar(this.ctx);
  }

  build() {
Stack(){

      Canvas(this.ctx)
        .onReady(() => {
          this.drawRadar(this.ctx)
        })

  Column(){
  Image($rawfile('svgviewer-output.svg')).width(40).height(40).fillColor(Color.Red).opacity(0.4).onClick(() =>{
    router.push({url: 'pages/WaypointPage'})
  })

  }.width('100%').height('100%').justifyContent(FlexAlign.End).alignItems(HorizontalAlign.Start).padding(30)
}.onTouch((e) => {
  const touchX = e.touches[0].x;
  const touchY = e.touches[0].y;
  for (let i = 0; i < this.waypointScreenPos.length; i++) {
    console.log(this.waypointScreenPos.length.toString())
    const wpPos = this.waypointScreenPos[i];
    const dx = touchX - wpPos.x;
    const dy = touchY - wpPos.y;
    if (dx * dx + dy * dy <= 6 * 6) {
      this.selectedIndex = i;
      console.log(this.selectedIndex.toString())
      this.drawRadar(this.ctx);
      break;
    }
  }


})
  }
}