import geoLocationManager from '@ohos.geoLocationManager';
import { Waypoint, loadWaypoints, saveWaypoints } from '../common/WaypointStore';
import { ArcList, ArcListItem, ArcListAttribute } from '@ohos.arkui.ArcList';
import { LengthMetrics } from '@kit.ArkUI';

@Entry
@Component
struct WaypointPage {
  @State waypoints: Waypoint[] = []
  @State newName: string = ''
  @State newTag: string = ''
  @State newLat: string = ''
  @State newLon: string = ''

  aboutToAppear() {
    loadWaypoints(getContext(this)).then(list => {
      this.waypoints = list;
    })
  }
  private async getCurrentLocation(){
    geoLocationManager.getCurrentLocation((err, loc) => {
      console.log(loc.latitude.toString())
      if (!err && loc)
      {
        this.newLat = loc.latitude.toFixed(6);
        this.newLon = loc.longitude.toFixed(6);
      }
    })
  }
  private async addWaypoint(){
    if(!this.newName || !this.newLat || !this.newLon) {
      return
    }
    this.waypoints.push({
      name: this.newName,
      tag: this.newTag.substring(0,3).toUpperCase(),
      lat: parseFloat(this.newLat),
      lon: parseFloat(this.newLon)
    })
    await saveWaypoints(getContext(this), this.waypoints)
    this.newName = ''
    this.newTag = ''
    this.newLat = ''
    this.newLon = ''
  }
  private async deleteWaypoint(index: number){
    this.waypoints.splice(index, 1)
    await saveWaypoints(getContext(this), this.waypoints)
  }
  isAddEnabled(): boolean{
    if(!this.newName || this.newName.trim().length === 0) {
      return false
    }
    if(!this.newTag || this.newTag.trim().length === 0) {
      return false
    }
    const lat = Number(this.newLat)
    const lon = Number(this.newLon)
    if(isNaN(lat) || isNaN(lon)) {
      return false
    }
    return true
  }
  build() {
    Column(){
      Text('Waypoint Manager')
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .padding({
          top:10,
          bottom:10
        })
      ArcList(){
        ArcListItem() {
          TextInput({ placeholder: 'Name', text: this.newName ? this.newName : '' })
            .onChange((value: string) => {
              this.newName = value
            }).width('75%')
            .height(35)
            .type(InputType.Normal)

        }
        ArcListItem() {
          TextInput({ placeholder: 'Tag (max 3)', text: this.newTag ? this.newTag : '' })
            .maxLength(3)
            .onChange((value: string) => {
              this.newTag = value.substring(0, 3).toUpperCase();
            }).width('75%')
            .height(35)
            .type(InputType.Normal)
        }
        ArcListItem() {
          TextInput({ placeholder:  'Latitude' , text: this.newLat ? this.newLat : ''})
            .onChange((value: string) => {
              this.newLat = value
            }).width('75%')
            .height(35)
            .type(InputType.Normal)
        }
        ArcListItem(){
      TextInput({placeholder:  'Longitude', text: this.newLon ? this.newLon : ''})
        .width('75%')
        .height(35)
        .onChange((value: string) => {
          this.newLon = value
        })
        .type(InputType.Normal)
        }
        ArcListItem(){
          Column({space: 20}){
            Button('Use Current') .fontSize(10)
              .width('75%')
              .height(35)
              .onClick(() =>{
                this.getCurrentLocation()
              })
            Button('Add')
              .enabled(this.isAddEnabled())
              .fontSize(10)
              .width('70%')
              .height(35)
              .onClick(() =>{
                this.addWaypoint()
              })
          }
        }
        ForEach(this.waypoints, (wp: Waypoint, index: number) =>{
          ArcListItem(){
            Column({space:5}){
              Text(`${wp.name} (${wp.tag})`)
                .fontSize(14)
              Text(`${wp.lat.toFixed(4)}, ${wp.lon.toFixed(4)}`)
                .fontColor(Color.Gray)
                .fontSize(12)

            Button('Delete')
              .fontSize(10)
              .width('60%')
              .height(20)
              .backgroundColor(Color.Red)
              .fontColor(Color.White)
              .onClick(() => {
                this.deleteWaypoint(index)
              })
          }.padding(8)
          .backgroundColor('#222')
          .borderRadius(8)
            .width('70%')
          }
        })

      }.space(LengthMetrics.px(50))
      .height(150)



    }.padding(20)
    .backgroundColor('#111')
    .height('100%')
    .width('100%')
  }
}