//
//  GlobeView.swift
//  CoronaTracker
//
//  Created by Aaryan Kothari on 21/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import SwiftUI
import CoreData

struct GlobeView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Global.entity(), sortDescriptors: []) var global : FetchedResults<Global>
    @FetchRequest(entity: Country.entity(), sortDescriptors: []) var countries : FetchedResults<Country>
    
    @State var country : Country
    @State private var isShowing = true

    var width : CGFloat
    var cases : [countrycase]
    var body: some View {
            VStack{
                Text("Global Stats")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(Font.system(size: 44, weight: .bold))
                    .padding(.top,60)
                globalDataStack(global: self.global.first!, width: width/6)
                countryDataStack(country: self.$country, width: width/7)
                if self.isShowing {
                    HStack{
                VStack(alignment:.center){
                Text("Tap on a county to see details 👇🏻")
                Text("Swipe to seee more")
                }
                }
                }
                ZStack{
                 ScrollView(.horizontal, showsIndicators: false){
                           HStack{
                            ForEach(self.countries , id:\.self){ (country:Country) in
                                bar(value: self.calculateHeight(Int(country.total)), emoji: country.countrycode!)
                                       .onTapGesture {
                                        self.country = country
                                        withAnimation {
                                            self.isShowing = false
                                        }
                                   }
                               }
                           }
                 }
                }
            }
            .padding(.leading,15)
                .background(LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.7294117647, green: 0.8784313725, blue: 0.9098039216, alpha: 1)),Color(#colorLiteral(red: 0.4549019608, green: 0.7647058824, blue: 0.8235294118, alpha: 1))]), startPoint: .top, endPoint: .bottom)).edgesIgnoringSafeArea(.bottom)
                .onAppear {
            }
    }
    
    
    struct globalDataStack : View{
        @State var global : Global
        var width : CGFloat
        var body: some View {
            VStack{
            ScrollView(.horizontal, showsIndicators: false){
            HStack{
                listTab(image:0, title: "Total Confirmed", count: global.totalconfirmed.stringValue, width: width)
                listTab(image:1, title: "Total Recoveries", count: global.totalrecovered.stringValue, width: width)
                listTab(image:2, title: "Total Deaths", count: global.totaldeaths.stringValue, width: width)
                listTab(image:0, title: "New Confirmed", count: global.newconfirmed.stringValue, width: width)
                listTab(image:1, title: "New Recoveries", count: global.newrecovered.stringValue, width: width)
                listTab(image:2, title: "New Deaths", count: global.newdeaths.stringValue, width: width)
            }
            }.padding(.leading,15)
                Spacer()
        }
        }
    }
    
    struct countryDataStack : View{
        @Binding var country : Country
        var width : CGFloat
        var body: some View {
            VStack(alignment:.leading){
                Text(country.name!).font(.system(size: 35, weight: .bold, design: .rounded))
            ScrollView(.horizontal, showsIndicators: false){
            HStack{
                listTab(image:0, title: "Total Confirmed", count: country.total.stringValue, width: width)
                listTab(image:1, title: "Total Recoveries", count: country.recoveries.stringValue, width: width)
                listTab(image:2, title: "Total Deaths", count: country.deaths.stringValue, width: width)
                listTab(image:0, title: "New Confirmed", count: country.newtotal.stringValue, width: width)
                listTab(image:1, title: "New Recoveries", count: country.newrecoveries.stringValue, width: width)
                listTab(image:2, title: "New Deaths", count: country.newdeaths.stringValue, width: width)
            }
            }.padding(.leading,15)
                Spacer()
        }
        }
    }
    
    
    struct listTab : View{
        
        var image : Int
        var cases : [String] = ["virus","cross","coffin"]
        var title : String
        var count : String
        var width : CGFloat
        var body : some View{
                VStack(alignment:.center){
                    VStack{
                    Image(cases[image])
                        .resizable()
                        .frame(width: width/2, height: width/2, alignment: .center)
                        .aspectRatio(contentMode: .fit)
                    }.frame(width: width, height: width, alignment: .center)
                    Text(title)
                        .modifier(Wrap())
                        .lineLimit(nil)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.5)
                Text(count)
                    .minimumScaleFactor(0.5)
                }
            .aspectRatio(1.0, contentMode: .fit)
            .padding(15)
            .background(Color.white.opacity(0.2))
            .cornerRadius(20)
        }
    }
    

    
    func calculateHeight(_ numberOfCases : Int)->Double{
     let cases = Double(numberOfCases)
     switch cases {
         case _ where cases < 100:
                     return cases/5000
          case _ where cases < 1000:
             return  cases / 40000
                 case _ where cases < 10000:
                     return cases/350000
          case _ where cases < 20000:
             return cases / 500000
          case _ where cases > 1500000:
             return 0.5
          case  _ where cases > 150000:
             return 0.4
          default:
             return Double(cases*4)/2000000
          }
     }
}

struct bar : View {
    var value: Double
    var index: Int = 0
    
    @State var width: CGFloat = 30
    
    @State var scaleValue: Double = 0
    var emoji : String
    
    var body: some View {
    VStack{
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(LinearGradient(gradient: Gradient(colors: [.red,.orange]), startPoint: .bottom, endPoint: .top))
                }
            .frame(width: width)
                .scaleEffect(CGSize(width: 1, height: self.scaleValue*2), anchor: .bottom)
                .onAppear(){
                    self.scaleValue = self.value
                }
            .animation(Animation.spring().delay(0.01))
        Text(convertToEmoji(str: emoji))
    }
    }
}

struct countrycase: Hashable {
    var name : String
    var emoji : String
    var cases : Int
}

extension Int32 {
    var stringValue : String{
        return String(self)
    }
}

struct Wrap: ViewModifier {
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content.frame(width: geometry.size.width)
        }
    }
}
