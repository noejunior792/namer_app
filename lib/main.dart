import 'dart:io';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'App de Nomes',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme:
              ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 10, 3, 75)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void deleteFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }

  void updateFavorite(WordPair oldPair, WordPair newPair) {
    int index = favorites.indexOf(oldPair);
    if (index != -1) {
      favorites[index] = newPair;
      notifyListeners();
    }
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  bool isExtended = false;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = FavoritesPage();
      case 2:
        page = ManageFavoritesPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('namer_app'),
        actions: [
          IconButton(
            icon: Icon(Icons.contact_support),
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'App de Nomes',
                applicationVersion: '1.0.0',
                applicationLegalese: 'Criado por Noé Júnior',
                children: [
                  Text('Siga-me nas redes sociais:'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.computer),
                        onPressed: () {
                          Link("https://www.github.com/noejunior792");
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.facebook),
                        onPressed: () {
                          Link("https://www.facebook.com/noe.dombaxe");
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.discord),
                        onPressed: () {
                          Link("");
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: isExtended,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite),
                  label: Text('Favoritos'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.manage_accounts),
                  label: Text('Gerenciar Favoritos'),
                ),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('Expandir Menu'),
                    value: isExtended,
                    onChanged: (value) {
                      setState(() {
                        isExtended = value;
                      });
                    },
                  ),
                  Expanded(child: page),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Gosto'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Próximo'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('Sem favoritos ainda'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('Você tem '
              '${appState.favorites.length} favoritos:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}

class ManageFavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('Ainda sem favoritos'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('Gerencie seus ${appState.favorites.length} favoritos:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            title: Text(pair.asLowerCase),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () async {
                    var updatedPair = await showDialog<WordPair>(
                      context: context,
                      builder: (context) => EditFavoriteDialog(pair: pair),
                    );
                    if (updatedPair != null) {
                      appState.updateFavorite(pair, updatedPair);
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    appState.deleteFavorite(pair);
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class EditFavoriteDialog extends StatefulWidget {
  final WordPair pair;

  EditFavoriteDialog({required this.pair});

  @override
  // ignore: library_private_types_in_public_api
  _EditFavoriteDialogState createState() => _EditFavoriteDialogState();
}

class _EditFavoriteDialogState extends State<EditFavoriteDialog> {
  late TextEditingController _firstController;
  late TextEditingController _secondController;

  @override
  void initState() {
    super.initState();
    _firstController = TextEditingController(text: widget.pair.first);
    _secondController = TextEditingController(text: widget.pair.second);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Editar Favorito'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _firstController,
            decoration: InputDecoration(labelText: 'Primeira Palavra'),
          ),
          TextField(
            controller: _secondController,
            decoration: InputDecoration(labelText: 'Segunda Palavra'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            var updatedPair = WordPair(
              _firstController.text,
              _secondController.text,
            );
            Navigator.of(context).pop(updatedPair);
          },
          child: Text('Salvar'),
        ),
      ],
    );
  }
}
