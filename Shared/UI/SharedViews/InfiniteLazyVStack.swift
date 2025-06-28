//
//  InfiniteLazyVStack.swift
//  Dash
//
//  Created by Steffi Tan on 2/9/22.
//

import SwiftUI


struct InfiniteLazyVStack<Data, Content>: View
where Data : RandomAccessCollection,
      Data.Element : Hashable,
      Data.Element : Identifiable,
      Content : View  {
  
  @Binding var data: Data
  @Binding var isLoading: Bool
  let loadMoreIndexOffset: Int
  let loadMore: () -> Void
  let content: (Data.Element) -> Content
  
  init(data: Binding<Data>,
       isLoading: Binding<Bool>,
       loadMoreIndexOffset: Int = -1,
       loadMore: @escaping () -> Void,
       @ViewBuilder content: @escaping (Data.Element) -> Content) {
    _data = data
    _isLoading = isLoading
    self.loadMoreIndexOffset = loadMoreIndexOffset
    self.loadMore = loadMore
    self.content = content
  }
  
  var body: some View {
    ScrollView {
      LazyVStack(alignment: .leading) {
        ForEach(data, id: \.self) { item in
          content(item)
            .onAppear {
              //  Trigger loading when item in view is the last item, change offsetBy to adjust.
              let thresholdIndex = data.index(data.endIndex, offsetBy: loadMoreIndexOffset)
              if data.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
                print("did reach threshold index at \(thresholdIndex). Invoking loadMore()")
                loadMore()
              }
            }
        }
        if isLoading {
          ProgressView()
            .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
        }
      }      
    }
    //.onAppear(perform: loadMore)

    
//    List {
//      ForEach(data, id: \.self) { item in
//        content(item)
//          .onAppear {
//            if item == data.last { // 6
//              loadMore()
//            }
//          }
//      }
//      if isLoading { // 7
//        ProgressView()
//          .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
//      }
//    }.onAppear(perform: loadMore) // 8
  }
}

//struct InfiniteLazyVStack_Previews: PreviewProvider {
//  static var previews: some View {
//    InfiniteLazyVStack()
//  }
//}
