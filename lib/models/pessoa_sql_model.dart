class PessoaSQLiteModel {
  int _id = 0;
  String _nome = "";
  double _peso = 0.0;
  double _altura = 0.0;
  double _imc = 0.0;
  String _estado = "";

  get id => _id;

  set id(value) => _id = value;

  get nome => _nome;

  set nome(value) => _nome = value;

  get peso => _peso;

  set peso(value) => _peso = value;

  get altura => _altura;

  set altura(value) => _altura = value;

  get imc => _imc;

  set imc(value) => _imc = value;

  get estado => _estado;

  set estado(value) => _estado = value;

  PessoaSQLiteModel(
    this._id,
    this._nome,
    this._peso,
    this._altura,
    this._imc,
    this._estado,
  );

  PessoaSQLiteModel.optionalId(
      this._nome, this._peso, this._altura, this._imc, this._estado);
}
