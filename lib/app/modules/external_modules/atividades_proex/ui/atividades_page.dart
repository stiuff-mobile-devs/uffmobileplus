import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uffmobileplus/app/modules/internal_modules/web_view/ui/webview_page.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import '../models/atividade.dart';
import '../services/api_service.dart';
import 'package:get/get.dart';

enum ExerciseFilter {
  todos('Todos'),
  curso('Curso'),
  oficina('Oficina'),
  congresso('Congresso'),
  palestra('Palestra'),
  grupoDeEstudo('Grupo de estudo'),
  rodaDeConversa('Roda de conversa'),
  seminario('Seminário'),
  conferencia('Conferência'),
  mesaRedonda('Mesa redonda'),
  simposio('Simpósio'),
  visitaTecnica('Visita técnica'),
  outro('Outro');

  final String label;
  const ExerciseFilter(this.label);
}

class AtividadesPage extends StatefulWidget {
  const AtividadesPage({super.key});

  @override
  State<AtividadesPage> createState() => _AtividadesPageState();
}

class _AtividadesPageState extends State<AtividadesPage> {
  List<Atividade> atividades = [];
  List<Atividade> atividadesFiltradas = [];
  bool isLoading = true;
  final TextEditingController _ThemeController = TextEditingController();
  final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
  
  bool _isDarkTheme = false;

  TextEditingController searchController = TextEditingController();
  Set<ExerciseFilter> filters = {ExerciseFilter.todos};

  @override
  void initState() {
    super.initState();
    _loadTheme();
    carregarAtividades();
  }  
  Future<void> _loadTheme() async {
    final value1 = await asyncPrefs.getBool('tema');
    setState(() {
      _isDarkTheme = value1 ?? false;
    });
  }
  Future<void> _saveTheme(bool value1) async {    
    setState(() {
      _isDarkTheme = value1;
    });
    await asyncPrefs.setBool('tema', _isDarkTheme);
  }

  Future<void> carregarAtividades() async {
      try {
        final fetchedAtividades = await fetchAtividades();
        setState(() {
          atividades = fetchedAtividades;
          atividadesFiltradas = fetchedAtividades;
          isLoading = false;
        });
      } catch (e) {
        setState(() => isLoading = false);
        //print('Erro ao carregar atividades: $e');
      }
    }

  void filtrarAtividades(String query) {
    final filtered = atividades.where((atividade) {
      final matchTitulo =
          atividade.titulo.toLowerCase().contains(query.toLowerCase());
      final matchTipo = filters.contains(ExerciseFilter.todos) ||
          filters.any((f) => f.label == atividade.tipo);
      return matchTitulo && matchTipo;
    }).toList();

    setState(() => atividadesFiltradas = filtered);
  }

  void toggleFilter(ExerciseFilter filter) {
    setState(() {
      if (filter == ExerciseFilter.todos) {
        filters = {ExerciseFilter.todos};
      } else {
        filters.remove(ExerciseFilter.todos);
        if (filters.contains(filter)) {
          filters.remove(filter);
        } else {
          filters.add(filter);
        }
        if (filters.isEmpty) filters.add(ExerciseFilter.todos);
      }
      filtrarAtividades(searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
              backgroundColor:  _isDarkTheme ? Colors.black : AppColors.lightBlue(),           
      appBar: AppBar(
              backgroundColor:  AppColors.darkBlue(),
              foregroundColor: Colors.white,
              automaticallyImplyLeading: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 IconButton(onPressed: () async { /*                     
                  */}, 
                  icon: const Icon(Icons.arrow_back)
                  ),
                  Expanded(child: Center(child: Text('Atividades PROEX'))),
                  IconButton(
                    onPressed:(){
                      _saveTheme(!_isDarkTheme);
                    },
                    icon:Icon(_isDarkTheme? Icons.invert_colors: Icons.invert_colors),
                  ),
                  IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(Icons.close)
                  ),  

              ],
            ),
          ),
      body: SafeArea(
          child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SizedBox(height: 16),
                    // Campo de busca
                    TextField(
                      controller: searchController,
                      style:TextStyle(color: _isDarkTheme ? Colors.white : Colors.black,) ,                  
                      decoration: InputDecoration(                        
                        hintText: 'Buscar atividades...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            filtrarAtividades('');
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: filtrarAtividades,
                    ),
                    const SizedBox(height: 10),
          
                    // Scroll horizontal com FilterChips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                        child:Row(
                          children: [
                            ... ExerciseFilter.values.map((filter) {
                              return Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: FilterChipWidget(
                                  filter: filter,
                                  isSelected: filters.contains(filter),
                                  onSelected: toggleFilter,
                                  isDarkTheme:_isDarkTheme,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                              
                    // Lista de atividades filtradas
                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              itemCount: atividadesFiltradas.length,
                              itemBuilder: (context, index) {
                                final atividade = atividadesFiltradas[index];
                                return _SampleCard(
                                  titulo: atividade.titulo,
                                  detalhes: atividade.detalhes,
                                  extra:
                                      'Carga horária: ${atividade.cargaHoraria ?? 'N/A'}\nCoordenação: ${atividade.coordenacao ?? 'N/A'}\nDescrição: ${atividade.descricaoResumida ?? 'N/A'}',
                                  linkInscricao: atividade.linkInscricao,
                                  isDarkTheme:_isDarkTheme,
                                );
                              },
                            ),
                    ),
          
                  ],
                  
                ),
              ),
        ),
    );
  }
}
//filterchip class
class FilterChipWidget extends StatelessWidget {
  final ExerciseFilter filter;
  final bool isSelected;
  final Function(ExerciseFilter) onSelected;
  final bool isDarkTheme;

  const FilterChipWidget({
    required this.filter,
    required this.isSelected,
    required this.onSelected,
    required this.isDarkTheme,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        filter.label,

      ),
      selected: isSelected,
      onSelected: (_) => onSelected(filter),
      backgroundColor: isDarkTheme? Colors.white : AppColors.mediumBlue(),
      selectedColor:  isDarkTheme? AppColors.mediumBlue()  : AppColors.darkBlue(), 
      labelStyle: TextStyle(
      color: isSelected ? (isDarkTheme ? Colors.black : Colors.white) :
                          (isDarkTheme ? Colors.black : Colors.white),
  ),
    );
  }
}

// Card customizado com expansão
class _SampleCard extends StatefulWidget {
  const _SampleCard({
    required this.titulo,
    this.detalhes,
    this.extra = '',
    required this.linkInscricao, 
    required this.isDarkTheme,
    Key? key,
  }) : super(key: key);

  final String titulo;
  final String? detalhes;
  final String extra;
  final String linkInscricao; 
  final bool isDarkTheme;

  @override
  State<_SampleCard> createState() => _SampleCardState();
}


class _SampleCardState extends State<_SampleCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.titulo,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (widget.detalhes != null) 
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(widget.detalhes!),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.all(8.0),      
              child: Row(
                        children: [                  
                          Icon(
                            _isExpanded
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down,
                          ),
                          Text(_isExpanded ? 'Esconder' : 'Ver detalhes'),
                          const Spacer(),
                          OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.darkBlue(), 
                                side: BorderSide(color: AppColors.darkBlue()), 
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8), 
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                            onPressed: () {
                              Get.to(
                                () => const WebViewPage(),
                                arguments: {
                                  'url': widget.linkInscricao,
                                  'title': widget.titulo,
                                },
                              );
                            },
                            child: const Text('Inscrever-se'),
                          ),
                        ],
              ),
            ),
            if (_isExpanded && widget.extra.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
              color: widget.isDarkTheme? AppColors.darkBlue() : AppColors.lightBlue(),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  blurRadius: 6, 
                ),
              ],
              ),
              child: Text(widget.extra,
                style:TextStyle(color: widget.isDarkTheme ? Colors.white : Colors.black,) ,
                ),
            ),        
          ],
        ),
      ),
    );
  }
}
