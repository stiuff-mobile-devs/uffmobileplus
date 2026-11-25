import 'package:uffmobileplus/app/data/models/inbox_notification.dart';

/// Exemplos para a aba Notificações enquanto `CdcController.notificacoesDeTeste`
/// estiver ligado. Textos fixos em português de propósito: são dados de teste,
/// não textos da interface.
List<InboxNotification> cdcMockNotifications() {
  final now = DateTime.now();
  return [
    InboxNotification(
      id: 'teste-1',
      title: 'Matrícula: prazo de ajuste',
      body: 'O ajuste de matrícula vai até sexta-feira, às 23h59. '
          'Confira suas disciplinas no IdUFF.',
      receivedAt: now.subtract(const Duration(minutes: 20)),
    ),
    InboxNotification(
      id: 'teste-2',
      title: 'Restaurante Universitário',
      body: 'Hoje o RU do Gragoatá funciona em horário reduzido, '
          'das 11h às 14h.',
      receivedAt: now.subtract(const Duration(hours: 3)),
    ),
    InboxNotification(
      id: 'teste-3',
      title: 'Nova sala oficial disponível',
      body: 'Entrou uma sala do seu curso na Central de Comunicação.',
      receivedAt: now.subtract(const Duration(days: 1, hours: 2)),
      read: true,
    ),
    InboxNotification(
      id: 'teste-4',
      title: 'Aviso da coordenação',
      body: 'A reunião com os calouros foi transferida para a próxima '
          'quarta-feira, no auditório do bloco E. Leve um documento com '
          'foto. Quem não puder ir pode acompanhar a transmissão pela sala '
          'oficial do curso no Google Chat, onde também ficarão os slides '
          'e as respostas para as dúvidas mais frequentes.',
      receivedAt: now.subtract(const Duration(days: 2)),
    ),
    InboxNotification(
      id: 'teste-5',
      title: 'Biblioteca',
      body: 'Seu empréstimo vence em 2 dias. Renove pelo app.',
      receivedAt: now.subtract(const Duration(days: 4)),
      read: true,
    ),
    InboxNotification(
      id: 'teste-6',
      title: 'Bem-vindo à Central de Comunicação',
      body: 'Os avisos oficiais da UFF vão aparecer aqui.',
      receivedAt: now.subtract(const Duration(days: 9)),
      read: true,
    ),
  ];
}
