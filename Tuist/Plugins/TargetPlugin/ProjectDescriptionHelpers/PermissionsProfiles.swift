import ProjectDescription

public enum Permission: String, CaseIterable, Sendable {
	case camera
	case microphone
	case photoLibrary
	case photoLibraryAdd
	case locationWhenInUse
	case locationAlways
	case bluetooth
	case contacts
	case calendars
	case reminders
	case motion
	case music
	case notification
	case tracking
	case health
	case nfc
}

public struct PermissionOption: Sendable, Hashable {
	public let permission: Permission
	public let usageDescription: String?

	public init(
		permission: Permission,
		usageDescription: String? = nil
	) {
		self.permission = permission
		self.usageDescription = usageDescription
	}
}

public typealias PermissionDescription = PermissionOption

extension PermissionOption {
	public static var camera: Self {
		make(.camera)
	}

	public static func camera(_ usageDescription: String?) -> Self {
		make(.camera, usageDescription: usageDescription)
	}

	public static var microphone: Self {
		make(.microphone)
	}

	public static func microphone(_ usageDescription: String?) -> Self {
		make(.microphone, usageDescription: usageDescription)
	}

	public static var photoLibrary: Self {
		make(.photoLibrary)
	}

	public static func photoLibrary(_ usageDescription: String?) -> Self {
		make(.photoLibrary, usageDescription: usageDescription)
	}

	public static var photoLibraryAdd: Self {
		make(.photoLibraryAdd)
	}

	public static func photoLibraryAdd(_ usageDescription: String?) -> Self {
		make(.photoLibraryAdd, usageDescription: usageDescription)
	}

	public static var locationWhenInUse: Self {
		make(.locationWhenInUse)
	}

	public static func locationWhenInUse(_ usageDescription: String?) -> Self {
		make(.locationWhenInUse, usageDescription: usageDescription)
	}

	public static var locationAlways: Self {
		make(.locationAlways)
	}

	public static func locationAlways(_ usageDescription: String?) -> Self {
		make(.locationAlways, usageDescription: usageDescription)
	}

	public static var bluetooth: Self {
		make(.bluetooth)
	}

	public static func bluetooth(_ usageDescription: String?) -> Self {
		make(.bluetooth, usageDescription: usageDescription)
	}

	public static var contacts: Self {
		make(.contacts)
	}

	public static func contacts(_ usageDescription: String?) -> Self {
		make(.contacts, usageDescription: usageDescription)
	}

	public static var calendars: Self {
		make(.calendars)
	}

	public static func calendars(_ usageDescription: String?) -> Self {
		make(.calendars, usageDescription: usageDescription)
	}

	public static var reminders: Self {
		make(.reminders)
	}

	public static func reminders(_ usageDescription: String?) -> Self {
		make(.reminders, usageDescription: usageDescription)
	}

	public static var motion: Self {
		make(.motion)
	}

	public static func motion(_ usageDescription: String?) -> Self {
		make(.motion, usageDescription: usageDescription)
	}

	public static var music: Self {
		make(.music)
	}

	public static func music(_ usageDescription: String?) -> Self {
		make(.music, usageDescription: usageDescription)
	}

	public static var notification: Self {
		make(.notification)
	}

	public static func notification(_ usageDescription: String?) -> Self {
		make(.notification, usageDescription: usageDescription)
	}

	public static var tracking: Self {
		make(.tracking)
	}

	public static func tracking(_ usageDescription: String?) -> Self {
		make(.tracking, usageDescription: usageDescription)
	}

	public static var health: Self {
		make(.health)
	}

	public static func health(_ usageDescription: String?) -> Self {
		make(.health, usageDescription: usageDescription)
	}

	public static var nfc: Self {
		make(.nfc)
	}

	public static func nfc(_ usageDescription: String?) -> Self {
		make(.nfc, usageDescription: usageDescription)
	}

	private static func make(_ permission: Permission) -> Self {
		.init(permission: permission)
	}

	private static func make(
		_ permission: Permission,
		usageDescription: String?
	) -> Self {
		.init(permission: permission, usageDescription: usageDescription)
	}
}

public struct TargetPermissionConfiguration: Sendable {
	public let required: [Permission]
	public let optional: [Permission]
	public let usageDescriptions: [Permission: String]

	public init(
		required: [PermissionOption],
		optional: [PermissionOption] = []
	) {
		self.required = required.map(\.permission)
		self.optional = optional.map(\.permission)
		let merged = required + optional
		self.usageDescriptions = merged.reduce(into: [:]) { partialResult, entry in
			guard let usageDescription = entry.usageDescription else { return }
			partialResult[entry.permission] = usageDescription
		}
	}

	public init(
		required: [Permission],
		optional: [Permission] = [],
		usageDescriptions: [Permission: String] = [:]
	) {
		self.required = required
		self.optional = optional
		self.usageDescriptions = usageDescriptions
	}

	public init(
		required: [Permission],
		optional: [Permission] = [],
		descriptions: [Permission: String]
	) {
		self.init(
			required: required,
			optional: optional,
			usageDescriptions: descriptions
		)
	}

	public var infoPlist: InfoPlist {
		.extendingDefault(with: plist)
	}

	public var plist: [String: Plist.Value] {
		var entries: [String: Plist.Value] = [:]
		for permission in required + optional {
			let override = usageDescriptions[permission]
			for (key, value) in permission.usageDescriptions {
				entries[key] = .string(override ?? value)
			}
		}
		return entries
	}
}

extension Permission {
	fileprivate var usageDescriptions: [String: String] {
		switch self {
		case .camera:
			return ["NSCameraUsageDescription": "사진/동영상 촬영 및 전송을 위해 카메라 접근을 허용해야합니다."]
		case .microphone:
			return ["NSMicrophoneUsageDescription": "동영상 촬영 시 소리 녹음을 위해 마이크 접근을 허용해야합니다."]
		case .photoLibrary:
			return ["NSPhotoLibraryUsageDescription": "사진/동영상 선택 및 전송을 위해 사진 라이브러리 접근을 허용해야합니다."]
		case .photoLibraryAdd:
			return [
				"NSPhotoLibraryAddUsageDescription": "사진/동영상 저장을 위해 사진 라이브러리 접근을 허용해야합니다."
			]
		case .locationWhenInUse:
			return ["NSLocationWhenInUseUsageDescription": "현재 위치 정보를 바탕으로 맞춤형 경험을 제공합니다."]
		case .locationAlways:
			return [
				"NSLocationAlwaysAndWhenInUseUsageDescription": "백그라운드 위치 권한은 지속적인 위치 서비스를 제공할 때 필요합니다."
			]
		case .bluetooth:
			let message = "Bluetooth는 주변 기기와 연결할 때 필요합니다."
			return [
				"NSBluetoothAlwaysUsageDescription": message,
				"NSBluetoothPeripheralUsageDescription": message,
			]
		case .contacts:
			return ["NSContactsUsageDescription": "연락처 접근은 친구와 공유하거나 초대할 때 필요합니다."]
		case .calendars:
			return ["NSCalendarsUsageDescription": "캘린더 접근은 학습 일정을 동기화할 때 필요합니다."]
		case .reminders:
			return ["NSRemindersUsageDescription": "미리 알림 접근은 학습 알림을 생성할 때 필요합니다."]
		case .motion:
			return ["NSMotionUsageDescription": "Motion & Fitness 데이터는 활동 기반 기능을 제공할 때 필요합니다."]
		case .music:
			return ["NSAppleMusicUsageDescription": "Apple Music 접근은 보호된 오디오를 재생할 때 필요합니다."]
		case .notification:
			return ["NSUserNotificationUsageDescription": "알림을 통해 중요한 소식을 받아볼 수 있습니다."]
		case .tracking:
			return ["NSUserTrackingUsageDescription": "맞춤형 광고 추천을 위해 iOS 기기의 광고식별자를 수집합니다."]
		case .health:
			return [
				"NSHealthShareUsageDescription": "헬스 데이터 공유는 맞춤형 건강 피드를 제공할 때 필요합니다.",
				"NSHealthUpdateUsageDescription": "헬스 데이터를 기록할 때 필요합니다.",
			]
		case .nfc:
			return ["NFCReaderUsageDescription": "NFC 태그/카드를 스캔할 때 필요합니다."]
		}
	}
}
