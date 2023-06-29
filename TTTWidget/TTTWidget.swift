//
//  TTTWidget.swift
//  TTTWidget
//
//  Created by zhang shijie on 2023/6/29.
//

import WidgetKit
import SwiftUI
import Intents
import AVFAudio
import SoNowClockRotation
struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
      SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        var currentDate = Date()
        MyCache.sharedInstance.i += 1

//        var rCount = 0
//        while rCount < 200 {
//            rCount += 1
//        if MyCache.sharedInstance.i > 81{
//      MyCache.sharedInstance.i = 1
//  }
//            currentDate =  Calendar.current.date(byAdding: .second, value: 1, to: currentDate)!
//            var entry = SimpleEntry(date: currentDate, configuration: configuration,frame: MyCache.sharedInstance.i)
//            entry.frame = MyCache.sharedInstance.i
//            entries.append(entry)
//        }

      if MyCache.sharedInstance.i > 81{
          MyCache.sharedInstance.i = 1
      }
      currentDate = Calendar.current.date(byAdding: .nanosecond, value: 1000000, to: currentDate)!
       let entry = SimpleEntry(date: currentDate, configuration: configuration,frame: MyCache.sharedInstance.i)
       entries.append(entry)
      let timeline = Timeline(entries: entries, policy: .never)
      completion(timeline)
    }

  func initAudioPlayer(file:String, type:String){
    let path = Bundle.main.path(forResource: file, ofType: type)!
    let url = URL(filePath: path)
      do{
          try AVAudioSession.sharedInstance().setCategory(.playback)
          try AVAudioSession.sharedInstance().setActive(true)
          let audioPlayer:AVAudioPlayer = try AVAudioPlayer(contentsOf: url)
          audioPlayer.volume = 0
          audioPlayer.numberOfLoops = -1
          audioPlayer.prepareToPlay()
          audioPlayer.play()
      }
      catch{}
  }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    var frame:Int = 0
}

struct TTTWidgetEntryView : View {
  var entry: Provider.Entry
  var myGradient = Gradient(
      colors: [
          Color(.systemTeal),
          Color(.systemPurple)
      ]
  )
  var body: some View {
    Text(entry.date, style: .timer)
//    Text("\(entry.frame)")
//    Text("asdasdasd").modifier(SoNowClockHandRotationEffect(timezone: TimeZone.current,cutomTimeInterval: 10,anchor: UnitPoint(x: 1, y: 1)))
    Image("frame_\(entry.frame)_delay-0.04s").resizable().frame(width: 100,height: 100).onAppear{
      self.tick()
    }
    ZStack(alignment: .topLeading){
        Circle().stroke(
                        LinearGradient(
                            gradient: myGradient,
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 5

        )
        HStack{
          Image("frame_\(entry.frame)_delay-0.04s").resizable().frame(width: 50,height: 50)
        }

      }.modifier(SoNowClockHandRotationEffect(timezone: TimeZone.current,cutomTimeInterval: 5,anchor: UnitPoint(x: 0.5, y: 0.5)))
    }

  private func tick() {
      DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10)) {

          WidgetCenter.shared.reloadAllTimelines()
          tick()
      }
  }
}

struct TTTWidget: Widget {
    let kind: String = "TTTWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            TTTWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct TTTWidget_Previews: PreviewProvider {
    static var previews: some View {
        TTTWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

class MyCache {
  static let sharedInstance = MyCache()
  var i:Int = 0
  var isNever = false

}
