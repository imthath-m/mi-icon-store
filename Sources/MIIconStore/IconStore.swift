import CoreData
import MIDataStore

public class IconStore: CoreDataStorable, ObservableObject {
  public var modelName: String { "CoreDataStore" }
  lazy var managedObjectModel: NSManagedObjectModel = {
    let bundle = Bundle.module
    let modelURL = bundle.url(forResource: modelName, withExtension: "momd")!
    return NSManagedObjectModel(contentsOf: modelURL)!
  }()
  lazy public var persistantContainer: NSPersistentContainer = .init(name: modelName, managedObjectModel: managedObjectModel)
  lazy public var mainContext: NSManagedObjectContext = persistantContainer.viewContext
  lazy public var privateContextWithParent: NSManagedObjectContext = mainContext.privateChildContext

  var loadingIcons = false

  private init() { }

  public static let shared: IconStore = .init()

  public static func initialize() {
    shared.loadStore { desc, error in
      shared.setupIcons()
    }
  }

  internal static var context: NSManagedObjectContext { shared.currentContext }
}

extension IconStore {
  func setupIcons() {
    guard isEmpty,
          !loadingIcons,
          let icons: [Icon] = FileIO.getObject(from: iconsJson),
          !icons.isEmpty else {
      return
    }

    loadingIcons = true
    for icon in icons {
      let object = CDIcon(context: currentContext)
      object.identifier = icon.identifier
      object.typeString = icon.type.rawValue
    }

    saveChanges()
  }

  var isEmpty: Bool {
    let fetchRequest: NSFetchRequest<CDIcon> = CDIcon.fetchRequest()
    fetchRequest.fetchLimit = 1
    return currentContext.fetchAndWait(fetchRequest).isEmpty
  }
}

extension CDIcon {
//  var uniqueID: String { identifier ?? }

  var result: Icon {
    guard let string = typeString,
          let id = identifier,
          let result = IconType(rawValue: string) else {
      return .new
    }

    return .init(identifier: id, type: result, keywords: [])
  }

//  var type: CDIconType {
//    guard let string = typeString,
//          let id = identifier,
//          let result = IconType(rawValue: string) else {
//      return .sfSymbol("pencil")
//    }
//
//    switch result {
//    case .emoji: return .emoji(id)
//    case .sfSymbol: return .sfSymbol(id)
//    }
//  }
}

//enum CDIconType {
//  case emoji(String)
//  case sfSymbol(String)
//}

public struct Icon: Codable {
  public static var new: Icon { .init(identifier: "photo.fill", type: .sfSymbol, keywords: []) }

  public var identifier: String
  public var type: IconType
  var keywords: [String]

  public init(identifier: String, type: IconType, keywords: [String] = []) {
    self.identifier = identifier
    self.type = type
    self.keywords = keywords
  }
}

public enum IconType: String, Codable {
  case emoji, sfSymbol
}

//extension UserDefaults {
//  static var 
//}
