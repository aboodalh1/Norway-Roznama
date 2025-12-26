/// Utility class for mapping backend reader IDs to local asset file paths.
/// 
/// Backend IDs:
/// - 1: مشاري العفاسي (Alafasi)
/// - 2: ياسر الدوسري (Yaser)
/// - 3: محمود الحصري (Alhusari)
/// - 4: عبدالباسط عبدالصمد (Abd Albaset)
/// - 5: صوت الاشعار الافتراضي (Default - system notification)
class AdhanSoundMapper {
  /// Mapping from backend reader ID to asset file path
  static const Map<int, String> backendIdToAsset = {
    1: 'sounds/alafasi.mp3',
    2: 'sounds/yaser.mp3',
    3: 'sounds/alhusari.mp3',
    4: 'sounds/abd_albaset.mp3',
  };
  
  /// Mapping from Arabic reader names to backend IDs
  static const Map<String, int> readerNameToBackendId = {
    'مشاري العفاسي': 1,
    'ياسر الدوسري': 2,
    'محمود الحصري': 3,
    'عبدالباسط عبدالصمد': 4,
    'صوت الاشعار الافتراضي': 5,
  };
  
  /// Get asset file path for a given backend reader ID.
  /// 
  /// Returns null if ID is 5 (default system sound) or invalid.
  static String? getAssetPath(int backendId) {
    return backendIdToAsset[backendId];
  }
  
  /// Get backend ID from Arabic reader name.
  /// 
  /// Returns null if reader name not found.
  static int? getBackendIdFromReaderName(String readerName) {
    return readerNameToBackendId[readerName];
  }
  
  /// Check if a backend ID corresponds to a valid asset file.
  static bool hasAsset(int backendId) {
    return backendIdToAsset.containsKey(backendId);
  }
  
  /// Get reader name from backend ID.
  /// 
  /// Returns null if ID not found.
  static String? getReaderNameFromBackendId(int backendId) {
    return readerNameToBackendId.entries
        .firstWhere((entry) => entry.value == backendId, orElse: () => MapEntry('', 0))
        .key;
  }
}

