// GENERATED CODE - DO NOT MODIFY BY HAND
// This code was generated by ObjectBox. To update it run the generator again
// with `dart run build_runner build`.
// See also https://docs.objectbox.io/getting-started#generate-objectbox-code

// ignore_for_file: camel_case_types, depend_on_referenced_packages
// coverage:ignore-file

import 'dart:typed_data';

import 'package:flat_buffers/flat_buffers.dart' as fb;
import 'package:objectbox/internal.dart'
    as obx_int; // generated code can access "internal" functionality
import 'package:objectbox/objectbox.dart' as obx;
import 'package:objectbox_flutter_libs/objectbox_flutter_libs.dart';

import 'domain/entities/episode_entity.dart';
import 'domain/entities/podcast_entity.dart';

export 'package:objectbox/objectbox.dart'; // so that callers only have to import this file

final _entities = <obx_int.ModelEntity>[
  obx_int.ModelEntity(
      id: const obx_int.IdUid(1, 1565139607905705435),
      name: 'EpisodeEntity',
      lastPropertyId: const obx_int.IdUid(26, 1886093547491996978),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 4670561052217846231),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 2662069751007399050),
            name: 'eId',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(3, 2894976091804058789),
            name: 'title',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(4, 4329526841166662602),
            name: 'description',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(5, 3054363751521067596),
            name: 'guid',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(6, 1573153674570213847),
            name: 'datePublished',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(7, 6782909844481842595),
            name: 'datePublishedPretty',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(8, 7580731945232437536),
            name: 'enclosureUrl',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(9, 7251155709238231353),
            name: 'enclosureLength',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(10, 7378168781950407657),
            name: 'duration',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(11, 4133060487547384495),
            name: 'explicit',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(12, 502446722681619724),
            name: 'episodeNr',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(13, 8573786366849211392),
            name: 'episodeType',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(14, 6785024666013952419),
            name: 'season',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(15, 5800456178041182279),
            name: 'image',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(16, 8404203205950663405),
            name: 'link',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(17, 6856879803896141474),
            name: 'feedUrl',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(18, 9025815632140074550),
            name: 'feedImage',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(19, 3974881699213436009),
            name: 'feedId',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(20, 2148929595363273923),
            name: 'podcastGuid',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(21, 783674117604261378),
            name: 'favorite',
            type: 1,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(22, 1095060026663765051),
            name: 'read',
            type: 1,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(23, 7541322564005801263),
            name: 'completed',
            type: 1,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(24, 522667113853777195),
            name: 'position',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(25, 6290802938905714025),
            name: 'filePath',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(26, 1886093547491996978),
            name: 'podcastId',
            type: 11,
            flags: 520,
            indexId: const obx_int.IdUid(1, 1126246801486907936),
            relationTarget: 'PodcastEntity')
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[]),
  obx_int.ModelEntity(
      id: const obx_int.IdUid(2, 6590084371707452549),
      name: 'PodcastEntity',
      lastPropertyId: const obx_int.IdUid(18, 945864541081495901),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 5979486489309103380),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 4325799128129907292),
            name: 'pId',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(3, 704359096505156456),
            name: 'podcastGuid',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(4, 3305081657196920305),
            name: 'title',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(5, 1099235061316896203),
            name: 'url',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(6, 7805721346745967317),
            name: 'link',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(7, 6792149331943271003),
            name: 'description',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(8, 1341617678989576884),
            name: 'author',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(9, 5460988606514859371),
            name: 'ownerName',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(10, 4043638115481313914),
            name: 'artwork',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(11, 1511026048992656246),
            name: 'lastUpdateTime',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(12, 5702708520446065096),
            name: 'language',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(13, 4974944475010125855),
            name: 'explicit',
            type: 1,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(14, 394027088125504604),
            name: 'medium',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(15, 3012060787921803881),
            name: 'episodeCount',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(16, 5983946716952113249),
            name: 'categories',
            type: 30,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(17, 8120025628198903036),
            name: 'subscribed',
            type: 1,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(18, 945864541081495901),
            name: 'artworkBytes',
            type: 23,
            flags: 0)
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[
        obx_int.ModelBacklink(
            name: 'episodes', srcEntity: 'EpisodeEntity', srcField: 'podcast')
      ])
];

/// Shortcut for [obx.Store.new] that passes [getObjectBoxModel] and for Flutter
/// apps by default a [directory] using `defaultStoreDirectory()` from the
/// ObjectBox Flutter library.
///
/// Note: for desktop apps it is recommended to specify a unique [directory].
///
/// See [obx.Store.new] for an explanation of all parameters.
///
/// For Flutter apps, also calls `loadObjectBoxLibraryAndroidCompat()` from
/// the ObjectBox Flutter library to fix loading the native ObjectBox library
/// on Android 6 and older.
Future<obx.Store> openStore(
    {String? directory,
    int? maxDBSizeInKB,
    int? maxDataSizeInKB,
    int? fileMode,
    int? maxReaders,
    bool queriesCaseSensitiveDefault = true,
    String? macosApplicationGroup}) async {
  await loadObjectBoxLibraryAndroidCompat();
  return obx.Store(getObjectBoxModel(),
      directory: directory ?? (await defaultStoreDirectory()).path,
      maxDBSizeInKB: maxDBSizeInKB,
      maxDataSizeInKB: maxDataSizeInKB,
      fileMode: fileMode,
      maxReaders: maxReaders,
      queriesCaseSensitiveDefault: queriesCaseSensitiveDefault,
      macosApplicationGroup: macosApplicationGroup);
}

/// Returns the ObjectBox model definition for this project for use with
/// [obx.Store.new].
obx_int.ModelDefinition getObjectBoxModel() {
  final model = obx_int.ModelInfo(
      entities: _entities,
      lastEntityId: const obx_int.IdUid(2, 6590084371707452549),
      lastIndexId: const obx_int.IdUid(1, 1126246801486907936),
      lastRelationId: const obx_int.IdUid(0, 0),
      lastSequenceId: const obx_int.IdUid(0, 0),
      retiredEntityUids: const [],
      retiredIndexUids: const [],
      retiredPropertyUids: const [],
      retiredRelationUids: const [],
      modelVersion: 5,
      modelVersionParserMinimum: 5,
      version: 1);

  final bindings = <Type, obx_int.EntityDefinition>{
    EpisodeEntity: obx_int.EntityDefinition<EpisodeEntity>(
        model: _entities[0],
        toOneRelations: (EpisodeEntity object) => [object.podcast],
        toManyRelations: (EpisodeEntity object) => {},
        getId: (EpisodeEntity object) => object.id,
        setId: (EpisodeEntity object, int id) {
          object.id = id;
        },
        objectToFB: (EpisodeEntity object, fb.Builder fbb) {
          final titleOffset = fbb.writeString(object.title);
          final descriptionOffset = fbb.writeString(object.description);
          final guidOffset = fbb.writeString(object.guid);
          final datePublishedPrettyOffset =
              fbb.writeString(object.datePublishedPretty);
          final enclosureUrlOffset = fbb.writeString(object.enclosureUrl);
          final episodeTypeOffset = object.episodeType == null
              ? null
              : fbb.writeString(object.episodeType!);
          final imageOffset = fbb.writeString(object.image);
          final linkOffset = fbb.writeString(object.link);
          final feedUrlOffset = fbb.writeString(object.feedUrl);
          final feedImageOffset = fbb.writeString(object.feedImage);
          final podcastGuidOffset = fbb.writeString(object.podcastGuid);
          final filePathOffset = object.filePath == null
              ? null
              : fbb.writeString(object.filePath!);
          fbb.startTable(27);
          fbb.addInt64(0, object.id);
          fbb.addInt64(1, object.eId);
          fbb.addOffset(2, titleOffset);
          fbb.addOffset(3, descriptionOffset);
          fbb.addOffset(4, guidOffset);
          fbb.addInt64(5, object.datePublished);
          fbb.addOffset(6, datePublishedPrettyOffset);
          fbb.addOffset(7, enclosureUrlOffset);
          fbb.addInt64(8, object.enclosureLength);
          fbb.addInt64(9, object.duration);
          fbb.addInt64(10, object.explicit);
          fbb.addInt64(11, object.episodeNr);
          fbb.addOffset(12, episodeTypeOffset);
          fbb.addInt64(13, object.season);
          fbb.addOffset(14, imageOffset);
          fbb.addOffset(15, linkOffset);
          fbb.addOffset(16, feedUrlOffset);
          fbb.addOffset(17, feedImageOffset);
          fbb.addInt64(18, object.feedId);
          fbb.addOffset(19, podcastGuidOffset);
          fbb.addBool(20, object.favorite);
          fbb.addBool(21, object.read);
          fbb.addBool(22, object.completed);
          fbb.addInt64(23, object.position);
          fbb.addOffset(24, filePathOffset);
          fbb.addInt64(25, object.podcast.targetId);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final eIdParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 6, 0);
          final titleParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 8, '');
          final descriptionParam =
              const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 10, '');
          final guidParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 12, '');
          final datePublishedParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 14, 0);
          final datePublishedPrettyParam =
              const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 16, '');
          final enclosureUrlParam =
              const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 18, '');
          final enclosureLengthParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 20, 0);
          final durationParam =
              const fb.Int64Reader().vTableGetNullable(buffer, rootOffset, 22);
          final explicitParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 24, 0);
          final episodeNrParam =
              const fb.Int64Reader().vTableGetNullable(buffer, rootOffset, 26);
          final episodeTypeParam =
              const fb.StringReader(asciiOptimization: true)
                  .vTableGetNullable(buffer, rootOffset, 28);
          final seasonParam =
              const fb.Int64Reader().vTableGetNullable(buffer, rootOffset, 30);
          final imageParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 32, '');
          final feedUrlParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 36, '');
          final linkParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 34, '');
          final feedImageParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 38, '');
          final feedIdParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 40, 0);
          final podcastGuidParam =
              const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 42, '');
          final favoriteParam =
              const fb.BoolReader().vTableGet(buffer, rootOffset, 44, false);
          final readParam =
              const fb.BoolReader().vTableGet(buffer, rootOffset, 46, false);
          final completedParam =
              const fb.BoolReader().vTableGet(buffer, rootOffset, 48, false);
          final positionParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 50, 0);
          final filePathParam = const fb.StringReader(asciiOptimization: true)
              .vTableGetNullable(buffer, rootOffset, 52);
          final object = EpisodeEntity(
              eId: eIdParam,
              title: titleParam,
              description: descriptionParam,
              guid: guidParam,
              datePublished: datePublishedParam,
              datePublishedPretty: datePublishedPrettyParam,
              enclosureUrl: enclosureUrlParam,
              enclosureLength: enclosureLengthParam,
              duration: durationParam,
              explicit: explicitParam,
              episodeNr: episodeNrParam,
              episodeType: episodeTypeParam,
              season: seasonParam,
              image: imageParam,
              feedUrl: feedUrlParam,
              link: linkParam,
              feedImage: feedImageParam,
              feedId: feedIdParam,
              podcastGuid: podcastGuidParam,
              favorite: favoriteParam,
              read: readParam,
              completed: completedParam,
              position: positionParam,
              filePath: filePathParam)
            ..id = const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);
          object.podcast.targetId =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 54, 0);
          object.podcast.attach(store);
          return object;
        }),
    PodcastEntity: obx_int.EntityDefinition<PodcastEntity>(
        model: _entities[1],
        toOneRelations: (PodcastEntity object) => [],
        toManyRelations: (PodcastEntity object) => {
              obx_int.RelInfo<EpisodeEntity>.toOneBacklink(26, object.id,
                      (EpisodeEntity srcObject) => srcObject.podcast):
                  object.episodes
            },
        getId: (PodcastEntity object) => object.id,
        setId: (PodcastEntity object, int id) {
          object.id = id;
        },
        objectToFB: (PodcastEntity object, fb.Builder fbb) {
          final podcastGuidOffset = fbb.writeString(object.podcastGuid);
          final titleOffset = fbb.writeString(object.title);
          final urlOffset = fbb.writeString(object.url);
          final linkOffset = fbb.writeString(object.link);
          final descriptionOffset = fbb.writeString(object.description);
          final authorOffset = fbb.writeString(object.author);
          final ownerNameOffset = fbb.writeString(object.ownerName);
          final artworkOffset = fbb.writeString(object.artwork);
          final languageOffset = fbb.writeString(object.language);
          final mediumOffset = fbb.writeString(object.medium);
          final categoriesOffset = fbb.writeList(
              object.categories.map(fbb.writeString).toList(growable: false));
          final artworkBytesOffset = object.artworkBytes == null
              ? null
              : fbb.writeListInt8(object.artworkBytes!);
          fbb.startTable(19);
          fbb.addInt64(0, object.id);
          fbb.addInt64(1, object.pId);
          fbb.addOffset(2, podcastGuidOffset);
          fbb.addOffset(3, titleOffset);
          fbb.addOffset(4, urlOffset);
          fbb.addOffset(5, linkOffset);
          fbb.addOffset(6, descriptionOffset);
          fbb.addOffset(7, authorOffset);
          fbb.addOffset(8, ownerNameOffset);
          fbb.addOffset(9, artworkOffset);
          fbb.addInt64(10, object.lastUpdateTime);
          fbb.addOffset(11, languageOffset);
          fbb.addBool(12, object.explicit);
          fbb.addOffset(13, mediumOffset);
          fbb.addInt64(14, object.episodeCount);
          fbb.addOffset(15, categoriesOffset);
          fbb.addBool(16, object.subscribed);
          fbb.addOffset(17, artworkBytesOffset);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final pIdParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 6, 0);
          final podcastGuidParam =
              const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 8, '');
          final titleParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 10, '');
          final urlParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 12, '');
          final linkParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 14, '');
          final descriptionParam =
              const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 16, '');
          final authorParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 18, '');
          final ownerNameParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 20, '');
          final artworkParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 22, '');
          final lastUpdateTimeParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 24, 0);
          final languageParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 26, '');
          final explicitParam =
              const fb.BoolReader().vTableGet(buffer, rootOffset, 28, false);
          final mediumParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 30, '');
          final episodeCountParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 32, 0);
          final categoriesParam = const fb.ListReader<String>(
                  fb.StringReader(asciiOptimization: true),
                  lazy: false)
              .vTableGet(buffer, rootOffset, 34, []);
          final subscribedParam =
              const fb.BoolReader().vTableGet(buffer, rootOffset, 36, false);
          final artworkBytesParam = const fb.Uint8ListReader(lazy: false)
              .vTableGetNullable(buffer, rootOffset, 38) as Uint8List?;
          final object = PodcastEntity(
              pId: pIdParam,
              podcastGuid: podcastGuidParam,
              title: titleParam,
              url: urlParam,
              link: linkParam,
              description: descriptionParam,
              author: authorParam,
              ownerName: ownerNameParam,
              artwork: artworkParam,
              lastUpdateTime: lastUpdateTimeParam,
              language: languageParam,
              explicit: explicitParam,
              medium: mediumParam,
              episodeCount: episodeCountParam,
              categories: categoriesParam,
              subscribed: subscribedParam,
              artworkBytes: artworkBytesParam)
            ..id = const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);
          obx_int.InternalToManyAccess.setRelInfo<PodcastEntity>(
              object.episodes,
              store,
              obx_int.RelInfo<EpisodeEntity>.toOneBacklink(26, object.id,
                  (EpisodeEntity srcObject) => srcObject.podcast));
          return object;
        })
  };

  return obx_int.ModelDefinition(model, bindings);
}

/// [EpisodeEntity] entity fields to define ObjectBox queries.
class EpisodeEntity_ {
  /// See [EpisodeEntity.id].
  static final id =
      obx.QueryIntegerProperty<EpisodeEntity>(_entities[0].properties[0]);

  /// See [EpisodeEntity.eId].
  static final eId =
      obx.QueryIntegerProperty<EpisodeEntity>(_entities[0].properties[1]);

  /// See [EpisodeEntity.title].
  static final title =
      obx.QueryStringProperty<EpisodeEntity>(_entities[0].properties[2]);

  /// See [EpisodeEntity.description].
  static final description =
      obx.QueryStringProperty<EpisodeEntity>(_entities[0].properties[3]);

  /// See [EpisodeEntity.guid].
  static final guid =
      obx.QueryStringProperty<EpisodeEntity>(_entities[0].properties[4]);

  /// See [EpisodeEntity.datePublished].
  static final datePublished =
      obx.QueryIntegerProperty<EpisodeEntity>(_entities[0].properties[5]);

  /// See [EpisodeEntity.datePublishedPretty].
  static final datePublishedPretty =
      obx.QueryStringProperty<EpisodeEntity>(_entities[0].properties[6]);

  /// See [EpisodeEntity.enclosureUrl].
  static final enclosureUrl =
      obx.QueryStringProperty<EpisodeEntity>(_entities[0].properties[7]);

  /// See [EpisodeEntity.enclosureLength].
  static final enclosureLength =
      obx.QueryIntegerProperty<EpisodeEntity>(_entities[0].properties[8]);

  /// See [EpisodeEntity.duration].
  static final duration =
      obx.QueryIntegerProperty<EpisodeEntity>(_entities[0].properties[9]);

  /// See [EpisodeEntity.explicit].
  static final explicit =
      obx.QueryIntegerProperty<EpisodeEntity>(_entities[0].properties[10]);

  /// See [EpisodeEntity.episodeNr].
  static final episodeNr =
      obx.QueryIntegerProperty<EpisodeEntity>(_entities[0].properties[11]);

  /// See [EpisodeEntity.episodeType].
  static final episodeType =
      obx.QueryStringProperty<EpisodeEntity>(_entities[0].properties[12]);

  /// See [EpisodeEntity.season].
  static final season =
      obx.QueryIntegerProperty<EpisodeEntity>(_entities[0].properties[13]);

  /// See [EpisodeEntity.image].
  static final image =
      obx.QueryStringProperty<EpisodeEntity>(_entities[0].properties[14]);

  /// See [EpisodeEntity.link].
  static final link =
      obx.QueryStringProperty<EpisodeEntity>(_entities[0].properties[15]);

  /// See [EpisodeEntity.feedUrl].
  static final feedUrl =
      obx.QueryStringProperty<EpisodeEntity>(_entities[0].properties[16]);

  /// See [EpisodeEntity.feedImage].
  static final feedImage =
      obx.QueryStringProperty<EpisodeEntity>(_entities[0].properties[17]);

  /// See [EpisodeEntity.feedId].
  static final feedId =
      obx.QueryIntegerProperty<EpisodeEntity>(_entities[0].properties[18]);

  /// See [EpisodeEntity.podcastGuid].
  static final podcastGuid =
      obx.QueryStringProperty<EpisodeEntity>(_entities[0].properties[19]);

  /// See [EpisodeEntity.favorite].
  static final favorite =
      obx.QueryBooleanProperty<EpisodeEntity>(_entities[0].properties[20]);

  /// See [EpisodeEntity.read].
  static final read =
      obx.QueryBooleanProperty<EpisodeEntity>(_entities[0].properties[21]);

  /// See [EpisodeEntity.completed].
  static final completed =
      obx.QueryBooleanProperty<EpisodeEntity>(_entities[0].properties[22]);

  /// See [EpisodeEntity.position].
  static final position =
      obx.QueryIntegerProperty<EpisodeEntity>(_entities[0].properties[23]);

  /// See [EpisodeEntity.filePath].
  static final filePath =
      obx.QueryStringProperty<EpisodeEntity>(_entities[0].properties[24]);

  /// See [EpisodeEntity.podcast].
  static final podcast = obx.QueryRelationToOne<EpisodeEntity, PodcastEntity>(
      _entities[0].properties[25]);
}

/// [PodcastEntity] entity fields to define ObjectBox queries.
class PodcastEntity_ {
  /// See [PodcastEntity.id].
  static final id =
      obx.QueryIntegerProperty<PodcastEntity>(_entities[1].properties[0]);

  /// See [PodcastEntity.pId].
  static final pId =
      obx.QueryIntegerProperty<PodcastEntity>(_entities[1].properties[1]);

  /// See [PodcastEntity.podcastGuid].
  static final podcastGuid =
      obx.QueryStringProperty<PodcastEntity>(_entities[1].properties[2]);

  /// See [PodcastEntity.title].
  static final title =
      obx.QueryStringProperty<PodcastEntity>(_entities[1].properties[3]);

  /// See [PodcastEntity.url].
  static final url =
      obx.QueryStringProperty<PodcastEntity>(_entities[1].properties[4]);

  /// See [PodcastEntity.link].
  static final link =
      obx.QueryStringProperty<PodcastEntity>(_entities[1].properties[5]);

  /// See [PodcastEntity.description].
  static final description =
      obx.QueryStringProperty<PodcastEntity>(_entities[1].properties[6]);

  /// See [PodcastEntity.author].
  static final author =
      obx.QueryStringProperty<PodcastEntity>(_entities[1].properties[7]);

  /// See [PodcastEntity.ownerName].
  static final ownerName =
      obx.QueryStringProperty<PodcastEntity>(_entities[1].properties[8]);

  /// See [PodcastEntity.artwork].
  static final artwork =
      obx.QueryStringProperty<PodcastEntity>(_entities[1].properties[9]);

  /// See [PodcastEntity.lastUpdateTime].
  static final lastUpdateTime =
      obx.QueryIntegerProperty<PodcastEntity>(_entities[1].properties[10]);

  /// See [PodcastEntity.language].
  static final language =
      obx.QueryStringProperty<PodcastEntity>(_entities[1].properties[11]);

  /// See [PodcastEntity.explicit].
  static final explicit =
      obx.QueryBooleanProperty<PodcastEntity>(_entities[1].properties[12]);

  /// See [PodcastEntity.medium].
  static final medium =
      obx.QueryStringProperty<PodcastEntity>(_entities[1].properties[13]);

  /// See [PodcastEntity.episodeCount].
  static final episodeCount =
      obx.QueryIntegerProperty<PodcastEntity>(_entities[1].properties[14]);

  /// See [PodcastEntity.categories].
  static final categories =
      obx.QueryStringVectorProperty<PodcastEntity>(_entities[1].properties[15]);

  /// See [PodcastEntity.subscribed].
  static final subscribed =
      obx.QueryBooleanProperty<PodcastEntity>(_entities[1].properties[16]);

  /// See [PodcastEntity.artworkBytes].
  static final artworkBytes =
      obx.QueryByteVectorProperty<PodcastEntity>(_entities[1].properties[17]);

  /// see [PodcastEntity.episodes]
  static final episodes = obx.QueryBacklinkToMany<EpisodeEntity, PodcastEntity>(
      EpisodeEntity_.podcast);
}
