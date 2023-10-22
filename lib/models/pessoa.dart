class Pessoa {
  int? id;
  String nome = "";
  double peso = 0.0;
  double altura = 0.0;
  double imc = 0.0;
  String estado = "";

  get getId => id;

  set setId(id) => this.id = id;

  get getNome => nome;

  set setNome(nome) => this.nome = nome;

  get getPeso => peso;

  set setPeso(peso) => this.peso = peso;

  get getAltura => altura;

  set setAltura(altura) => this.altura = altura;

  get getImc => imc;

  set setImc(imc) => this.imc = imc;

  get getEstado => estado;

  set setEstado(estado) => this.estado = estado;

  Pessoa(
      {required this.nome,
      required this.peso,
      required this.altura,
      required this.imc,
      required this.estado,
      required this.id});
}
