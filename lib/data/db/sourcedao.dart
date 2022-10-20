import 'package:floor/floor.dart';
import 'package:read_info/bean/db/source_db.dart';

@dao
abstract class SourceDao {
  @Query('SELECT * FROM Source')
  Future<List<Source>> findAllSources();
  @Query('SELECT * FROM Source where bookSourceUrl = :url')
  Future<Source?> findSource(String url);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertSource(Source bean);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertSources(List<Source> bean);

  @delete
  Future<int> deleteSource(Source bean);

}