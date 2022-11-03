import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:read_info/bean/entity/source_header_entity.dart';
import 'package:read_info/data/net/dio_helper.dart';
import 'package:read_info/data/rule/RuleUtil.dart';
import 'package:read_info/data/rule/app_helper.dart';
import 'package:read_info/data/source_net_repository.dart';
import 'package:read_info/generated/json/base/json_convert_content.dart';
import 'package:read_info/global/constant.dart';

import '../bean/book_item_bean.dart';
import '../bean/entity/source_entity.dart';
import 'local_repository.dart';

const int pageLimited = 20;

class SourceManager {
  static SourceManager instance=SourceManager();
  Rx<List<SourceEntity>> sourcesRx = Rx([]);

  List<SourceEntity> get sources => sourcesRx.value;

  SourceManager() {}

  Future<SourceEntity?> getSourceFromUrl(String? url) async {
    if(url==null) return null;
    await ensureSources();
    return sources.firstWhereOrNull((e) => e.bookSourceUrl == url);
  }

  Future<List<SourceEntity>> ensureSources() async {
    if (sources.isEmpty) sourcesRx.value = (await LocalRepository.getSourceList())..sortBy<num>((e){
      if(e.bookSourceType==source_type_sms) return 0;
      if(e.bookSourceType==source_type_comic) return 1;
      if(e.bookSourceType==source_type_novel) return 2;
      return 3;
    });
    return sources;
  }

  Future<List<SourceEntity>> refreshSources() async {
    sourcesRx.value = (await LocalRepository.getSourceList())..sortBy<num>((e)=>e.bookSourceType??0);
    return sources;
  }

  Future<List<SourceEntity>> insertOrUpdateSources(List<SourceEntity> sources) async {
    await LocalRepository.insertOrUpdateSources(sources);
    return await refreshSources();
  }
  Future deleteSource(SourceEntity entity) async {
    await ensureSources();
    await LocalRepository.deleteSource(entity);
    sourcesRx.value =[...sources..remove(entity)];
  }

}
typedef SearchCallBack = Function(List<BookItemBean>,int totalCount,int doneCount);
