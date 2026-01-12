@Entry
@Component
struct MainPage {
  pathStack: NavPathStack = new NavPathStack()

  // Set a NavPathStack object globally.
  aboutToAppear(): void {
  }

  build() {
    Navigation(this.pathStack) {

    }
    .onAppear(() => {
      this.pathStack.pushPathByName('indexPage', null)
    })
  }
}

