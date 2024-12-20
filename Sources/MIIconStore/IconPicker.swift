//
//  SwiftUIView.swift
//  
//
//  Created by Imthath on 28/03/21.
//

import SwiftUI

public struct IconPicker: View {
  @StateObject var coreData = IconStore.shared
  @Binding var selectedIcon: Icon?

  public init(icon: Binding<Icon?>) {
    self._selectedIcon = icon
  }

  public var body: some View {
    _IconPicker(selectedIcon: $selectedIcon)
      .environment(\.managedObjectContext, coreData.mainContext)
  }
}

struct _IconPicker: View {

  @Binding var selectedIcon: Icon?
  @Environment(\.presentationMode) var presentationMode
  @Environment(\.managedObjectContext) var context

  var fetchRquest: FetchRequest<CDIcon> = FetchRequest(
    entity: CDIcon.entity(),
    sortDescriptors: [NSSortDescriptor(keyPath: \CDIcon.identifier, ascending: false)]
  )

  var icons: FetchedResults<CDIcon> {
    fetchRquest.wrappedValue
  }

  var body: some View {
    NavigationView {
      ScrollView {
        gridView
          .padding()
      }
      .navigationBarTitle(Text(verbatim: "Choose an icon"))
    }
  }

  var gridView: some View {
    LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))], alignment: .center, spacing: 8, pinnedViews: [.sectionHeaders]) {
      ForEach(icons) { icon in
        _IconView(icon: icon)
          .onTapGesture {
            self.selectedIcon = icon.result
            presentationMode.wrappedValue.dismiss()
          }
      }
    }
  }
}

struct _IconView: View {
  let icon: CDIcon

  var body: some View {
    ZStack {
      Rectangle()
        .foregroundColor(.clear)
        .frame(width: 44, height: 44, alignment: .center)
      IconView(icon: icon.result)
        .font(.system(size: 36))
    }
  }
}

public struct IconView: View {
  let icon: Icon

  public init(icon: Icon) {
    self.icon = icon
  }

  public var body: some View {
    switch icon.type {
    case .emoji:
      Text(verbatim: icon.identifier)
    case .sfSymbol:
      Image(systemName: icon.identifier)
    }
  }
}

struct IconPicker_Previews: PreviewProvider {
  static var previews: some View {
    IconPicker(icon: .constant(nil))
  }
}
