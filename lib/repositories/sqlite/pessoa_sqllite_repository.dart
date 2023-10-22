import 'package:flutter_imc/models/pessoa_sql_model.dart';
import 'package:flutter_imc/repositories/sqlite/sqlitedatabase.dart';

class PessoaSQLiteRepository {
  Future<List<PessoaSQLiteModel>> obterDados() async {
    List<PessoaSQLiteModel> pessoas = [];
    var db = await SQLiteDataBase().obterDataBase();
    var result = await db
        .rawQuery("SELECT id, nome, peso, altura, imc, estado FROM pessoas");
    for (var element in result) {
      var pessoaModel = PessoaSQLiteModel(
          int.parse(element["id"].toString()),
          element["nome"].toString(),
          double.parse(element["peso"].toString()),
          double.parse(element["altura"].toString()),
          double.parse(element["imc"].toString()),
          element["estado"].toString());
      pessoas.add(pessoaModel);
    }
    return pessoas;
  }

  Future<int> salvar(PessoaSQLiteModel pessoaSQLiteModel) async {
    var db = await SQLiteDataBase().obterDataBase();
    final id = await db.rawInsert(
        'INSERT INTO pessoas (nome, peso, altura, imc, estado) values(?,?,?,?,?)',
        [
          pessoaSQLiteModel.nome,
          pessoaSQLiteModel.peso,
          pessoaSQLiteModel.altura,
          pessoaSQLiteModel.imc,
          pessoaSQLiteModel.estado
        ]);

    return id;
  }

  Future<void> atualizar(PessoaSQLiteModel pessoaSQLiteModel) async {
    var db = await SQLiteDataBase().obterDataBase();
    await db.rawInsert(
        'UPDATE pessoas SET nome = ?, peso = ?, altura = ?, imc = ?, estado = ? WHERE id = ?',
        [
          pessoaSQLiteModel.nome,
          pessoaSQLiteModel.peso,
          pessoaSQLiteModel.altura,
          pessoaSQLiteModel.imc,
          pessoaSQLiteModel.estado,
          pessoaSQLiteModel.id
        ]);
  }

  Future<void> remover(int id) async {
    var db = await SQLiteDataBase().obterDataBase();
    await db.rawInsert('DELETE FROM pessoas WHERE id = ?', [id]);
  }

  Future<void> limparSQLite() async {
    var db = await SQLiteDataBase().obterDataBase();
    await db.rawInsert('DELETE FROM pessoas');
  }
}
