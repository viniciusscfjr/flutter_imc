import 'package:flutter/material.dart';
import 'package:flutter_imc/models/pessoa_sql_model.dart';

import '../models/pessoa.dart';
import '../repositories/sqlite/pessoa_sqllite_repository.dart';

class ImcPage extends StatefulWidget {
  const ImcPage({Key? key}) : super(key: key);

  @override
  State<ImcPage> createState() => _ImcPageState();
}

class _ImcPageState extends State<ImcPage> {
  final TextEditingController _nomeController = TextEditingController(text: "");
  final TextEditingController _pesoController = TextEditingController(text: "");
  final TextEditingController _alturaController =
      TextEditingController(text: "");
  final TextEditingController idController = TextEditingController(text: "");
  List<Pessoa> _pessoas = [];
  var id = 0;

  PessoaSQLiteRepository pessoaSQLiteRepository = PessoaSQLiteRepository();

  Future<void> _adicionarPessoa() async {
    final nome = _nomeController.text;
    final peso = double.tryParse(_pesoController.text) ?? 0.0;
    final altura = double.tryParse(_alturaController.text) ?? 0.0;
    if (nome.isNotEmpty && peso > 0 && altura > 0) {
      final imc = peso / (altura * altura);
      var estado = "";

      if (imc < 16) {
        estado = "Magreza grave";
      } else if (imc >= 16 && imc < 17) {
        estado = "Magrega Moderada";
      } else if (imc >= 17 && imc < 18.5) {
        estado = "Magreza leve";
      } else if (imc >= 18.5 && imc < 25) {
        estado = "Saudável";
      } else if (imc >= 25 && imc < 30) {
        estado = "Sobrepeso";
      } else if (imc >= 30 && imc < 35) {
        estado = "Obesidade Grau I";
      } else if (imc >= 35 && imc < 40) {
        estado = "Obesidade Grau II (severa)";
      } else {
        estado = "Obesidade Grau 5 (mórbida)";
      }
      var pessoaModel =
          PessoaSQLiteModel.optionalId(nome, peso, altura, imc, estado);

      final id = await pessoaSQLiteRepository.salvar(pessoaModel);

      await _carregarPessoas();

      setState(() {
        _nomeController.clear();
        _pesoController.clear();
        _alturaController.clear();
      });
    }
  }

  bool loading = false;

  @override
  void initState() {
    super.initState();
    _carregarPessoas();
  }

  Future<void> _carregarPessoas() async {
    final pessoasBanco = await pessoaSQLiteRepository.obterDados();

    if (pessoasBanco.isNotEmpty) {
      setState(() {
        List<Pessoa> parsePessoa = [];

        for (var pessoa in pessoasBanco) {
          parsePessoa.add(Pessoa(
              id: pessoa.id,
              nome: pessoa.nome,
              peso: pessoa.peso,
              altura: pessoa.altura,
              imc: pessoa.imc,
              estado: pessoa.estado));
        }

        _pessoas = parsePessoa;
      });
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _pesoController.dispose();
    _alturaController.dispose();
    super.dispose();
  }

  _showEditModal(Pessoa pessoa) {
    // Definir os controladores com os valores atuais do item
    _nomeController.text = pessoa.nome;
    _alturaController.text = pessoa.altura.toString();
    _pesoController.text = pessoa.peso.toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Para que o modal seja de altura total
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('Editar Item'),
                TextField(
                  controller: _nomeController,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                  ),
                ),
                TextField(
                  controller: _alturaController,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(labelText: 'Altura'),
                ),
                TextField(
                  controller: _pesoController,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(labelText: 'Peso'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await pessoaSQLiteRepository.remover(pessoa.id!);

                    await _adicionarPessoa();

                    await _carregarPessoas();

                    // Fechar o modal
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                  },
                  child: const Text('Salvar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Calculadora de IMC'),
        ),
        body: Column(children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: const TextStyle(color: Colors.black),
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: const TextStyle(color: Colors.black),
              controller: _pesoController,
              decoration: const InputDecoration(labelText: 'Peso (kg)'),
              keyboardType: TextInputType.number,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: const TextStyle(color: Colors.black),
              controller: _alturaController,
              decoration: const InputDecoration(labelText: 'Altura (m)'),
              keyboardType: TextInputType.number,
            ),
          ),
          ElevatedButton(
            onPressed: _adicionarPessoa,
            child: const Text('Adicionar Pessoa'),
          ),
          ElevatedButton(
            onPressed: () async {
              await pessoaSQLiteRepository.limparSQLite();
              await _carregarPessoas();

              setState(() {
                _pessoas = [];
              });
            },
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red)),
            child: const Text(
              'Limpar SQLite',
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await _carregarPessoas();
            },
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.amber)),
            child: const Text(
              'Refresh SQLite',
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(
                      label:
                          Text('Nome', style: TextStyle(color: Colors.black))),
                  DataColumn(
                      label: Text('Altura',
                          style: TextStyle(color: Colors.black))),
                  DataColumn(
                      label:
                          Text('Peso', style: TextStyle(color: Colors.black))),
                  DataColumn(
                      label:
                          Text('IMC', style: TextStyle(color: Colors.black))),
                  DataColumn(
                      label: Text('Estado',
                          style: TextStyle(color: Colors.black))),
                  DataColumn(
                      label:
                          Text('Ações', style: TextStyle(color: Colors.black))),
                ],
                rows: _pessoas
                    .map(
                      (pessoa) => DataRow(
                        cells: [
                          DataCell(Text(pessoa.nome,
                              style: const TextStyle(color: Colors.black))),
                          DataCell(Text(pessoa.altura.toStringAsFixed(2),
                              style: const TextStyle(color: Colors.black))),
                          DataCell(Text(pessoa.peso.toStringAsFixed(2),
                              style: const TextStyle(color: Colors.black))),
                          DataCell(Text(pessoa.imc.toStringAsFixed(2),
                              style: const TextStyle(color: Colors.black))),
                          DataCell(Text(pessoa.estado.toString(),
                              style: const TextStyle(color: Colors.black))),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.amber,
                                  ),
                                  onPressed: () {
                                    // Ação de editar
                                    print('Editar ${pessoa.id}');

                                    _showEditModal(pessoa);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () async {
                                    // Ação de excluir
                                    print('Excluir ${pessoa.id}');
                                    await pessoaSQLiteRepository
                                        .remover(pessoa.id!);

                                    await _carregarPessoas();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          )
        ]));
  }
}
