class StoryCatalog {
  const StoryCatalog({required this.stories});

  final List<StorySummary> stories;

  factory StoryCatalog.fromMap(Map<String, dynamic> map) {
    return StoryCatalog(
      stories: (map['stories'] as List<dynamic>)
          .map((dynamic story) =>
              StorySummary.fromMap(story as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class StorySummary {
  const StorySummary({
    required this.id,
    required this.archiveLabel,
    required this.title,
    required this.subtitle,
    required this.cover,
    required this.estimatedMinutes,
    required this.pageCount,
    required this.tags,
    required this.contentVersion,
  });

  final String id;
  final String archiveLabel;
  final String title;
  final String subtitle;
  final String cover;
  final int estimatedMinutes;
  final int pageCount;
  final List<String> tags;
  final String contentVersion;

  factory StorySummary.fromMap(Map<String, dynamic> map) {
    return StorySummary(
      id: map['id'] as String,
      archiveLabel: map['archiveLabel'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String,
      cover: map['cover'] as String,
      estimatedMinutes: (map['estimatedMinutes'] as num).toInt(),
      pageCount: (map['pageCount'] as num).toInt(),
      tags: (map['tags'] as List<dynamic>? ?? const <dynamic>[]).cast<String>(),
      contentVersion: map['contentVersion'] as String,
    );
  }
}

class StoryPageData {
  const StoryPageData({
    required this.id,
    required this.asset,
    required this.width,
    required this.height,
  });

  final String id;
  final String asset;
  final double width;
  final double height;

  double get aspectRatio => width / height;

  factory StoryPageData.fromMap(
    Map<String, dynamic> map, {
    required String storyId,
    required int index,
  }) {
    final fallbackId = '$storyId-${(index + 1).toString().padLeft(3, '0')}';
    return StoryPageData(
      id: map['id'] as String? ?? fallbackId,
      asset: map['asset'] as String,
      width: (map['width'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
    );
  }
}

class StoryData {
  const StoryData({
    required this.id,
    required this.archiveLabel,
    required this.title,
    required this.subtitle,
    required this.contentVersion,
    required this.estimatedMinutes,
    required this.pages,
  });

  final String id;
  final String archiveLabel;
  final String title;
  final String subtitle;
  final String contentVersion;
  final int estimatedMinutes;
  final List<StoryPageData> pages;

  factory StoryData.fromMap(Map<String, dynamic> map) {
    final id = map['id'] as String;
    final pages = map['pages'] as List<dynamic>;
    return StoryData(
      id: id,
      archiveLabel: map['archiveLabel'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String,
      contentVersion: map['contentVersion'] as String,
      estimatedMinutes: (map['estimatedMinutes'] as num).toInt(),
      pages: <StoryPageData>[
        for (var i = 0; i < pages.length; i += 1)
          StoryPageData.fromMap(
            pages[i] as Map<String, dynamic>,
            storyId: id,
            index: i,
          ),
      ],
    );
  }

  StorySummary toSummary({required String cover, required List<String> tags}) {
    return StorySummary(
      id: id,
      archiveLabel: archiveLabel,
      title: title,
      subtitle: subtitle,
      cover: cover,
      estimatedMinutes: estimatedMinutes,
      pageCount: pages.length,
      tags: tags,
      contentVersion: contentVersion,
    );
  }
}

class UpdateManifest {
  const UpdateManifest({
    required this.available,
    required this.currentContentVersion,
    required this.latestContentVersion,
    required this.headline,
    required this.body,
    required this.items,
    required this.demo,
  });

  final bool available;
  final String currentContentVersion;
  final String latestContentVersion;
  final String headline;
  final String body;
  final List<String> items;
  final bool demo;

  factory UpdateManifest.fromMap(Map<String, dynamic> map) {
    return UpdateManifest(
      available: map['available'] as bool,
      currentContentVersion: map['currentContentVersion'] as String,
      latestContentVersion: map['latestContentVersion'] as String,
      headline: map['headline'] as String,
      body: map['body'] as String,
      items: (map['items'] as List<dynamic>).cast<String>(),
      demo: map['demo'] as bool? ?? false,
    );
  }
}
