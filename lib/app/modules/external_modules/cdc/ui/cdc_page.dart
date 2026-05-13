import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/controller/cdc_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

class CdcPage extends GetView<CdcController> {
  const CdcPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient(),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildNotificationsSection(),
                SizedBox(height: 24),
                _buildChatRoomsSection(),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'Central de Comunicação',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      elevation: 8,
      foregroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppColors.appBarTopGradient(),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildNotificationsSection() {
    final notifications = [
      {
        'title': 'Aviso Importante',
        'subtitle': 'Trancamento de disciplinas encerra hoje às 18h',
        'timestamp': '10 min',
        'icon': Icons.warning_amber_rounded,
        'color': Colors.amber,
      },
      {
        'title': 'Calendário Acadêmico',
        'subtitle': 'Próxima semana é semana de avaliação',
        'timestamp': '2h',
        'icon': Icons.calendar_today,
        'color': Colors.blue,
      },
      {
        'title': 'Manutenção do Sistema',
        'subtitle': 'Sistema em manutenção na próxima terça',
        'timestamp': '1 dia',
        'icon': Icons.build,
        'color': Colors.orange,
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Notificações',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${notifications.length}',
                style: TextStyle(
                  color: AppColors.lightBlue(),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.darkBlue().withOpacity(0.3),
                  AppColors.darkBlue().withOpacity(0.1),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: List.generate(
                notifications.length,
                (index) => _buildNotificationCard(
                  notifications[index],
                  isLast: index == notifications.length - 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    Map<String, dynamic> notification, {
    required bool isLast,
  }) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (notification['color'] as Color).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  notification['icon'] as IconData,
                  color: notification['color'] as Color,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification['title'] as String,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      notification['subtitle'] as String,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Text(
                notification['timestamp'] as String,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Divider(
              color: Colors.white.withOpacity(0.1),
              height: 1,
            ),
          ),
      ],
    );
  }

  Widget _buildChatRoomsSection() {
    final chatRooms = [
      {
        'name': 'Coordenação Ciência da Computação UFF Niterói',
        'lastMessage': 'Importante: Reunião de departamento amanhã às 14h',
        'unreadCount': 3,
        'members': 127,
        'icon': Icons.school,
      },
      {
        'name': 'Informes UFF',
        'lastMessage': 'Editais e comunicados importantes da universidade',
        'unreadCount': 2,
        'members': 4500,
        'icon': Icons.info,
      },
      {
        'name': 'Central de Atendimento ao Discente',
        'lastMessage': 'Tire suas dúvidas sobre processos acadêmicos',
        'unreadCount': 0,
        'members': 892,
        'icon': Icons.help_center,
      },
      {
        'name': 'Monitoria - Algoritmos I',
        'lastMessage': 'Dúvidas sobre recursão e sorting',
        'unreadCount': 1,
        'members': 45,
        'icon': Icons.people,
      },
      {
        'name': 'Projetos e Eventos',
        'lastMessage': 'Venha participar de nossos eventos acadêmicos',
        'unreadCount': 5,
        'members': 234,
        'icon': Icons.event,
      },
      {
        'name': 'Trocas e Vendas - CdC',
        'lastMessage': 'Compre e venda materiais acadêmicos com outros alunos',
        'unreadCount': 0,
        'members': 312,
        'icon': Icons.shopping_bag,
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Salas de Chat',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.mediumBlue().withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${chatRooms.length} salas',
                  style: TextStyle(
                    color: AppColors.lightBlue(),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              return _buildChatRoomCard(chatRooms[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChatRoomCard(Map<String, dynamic> room) {
    return GestureDetector(
      onTap: () {
        // Ação ao clicar na sala
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.mediumBlue().withOpacity(0.4),
              AppColors.darkBlue().withOpacity(0.5),
            ],
          ),
          border: Border.all(
            color: AppColors.lightBlue().withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.lightBlue().withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          room['icon'] as IconData,
                          color: AppColors.lightBlue(),
                          size: 18,
                        ),
                      ),
                      if ((room['unreadCount'] as int) > 0)
                        Spacer(),
                      if ((room['unreadCount'] as int) > 0)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${room['unreadCount']}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    room['name'] as String,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6),
                  Text(
                    room['lastMessage'] as String,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Spacer(),
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        color: Colors.white38,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${room['members']}',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}