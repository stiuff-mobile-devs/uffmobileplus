import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:googleapis/youtube/v3.dart' as youtube;
import 'package:uffmobileplus/app/modules/external_modules/uniteve/controller/uniteve_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/ui_components/custom_progress_display.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';

class UnitevePage extends GetView<UniteveController> {
  const UnitevePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Unitevê"),
        centerTitle: true,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.appBarTopGradient()),
        ),
        actions: <Widget>[
          PopupMenuTheme(
            data: PopupMenuThemeData(
              color: Colors.black.withOpacity(0.25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(12),
              ),
            ),
            child: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'historia') controller.historia();
                if (value == 'contato') controller.contato();
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'historia',
                  child: Text('História', style: TextStyle(color: Colors.white),),
                ),
                PopupMenuItem(
                  value: 'contato',
                  child: Text('Contato', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        // <- torna a tela rolável
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: AppColors.darkBlueToBlackGradient(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              // Logo menor alinhado no canto superior esquerdo da página
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SvgPicture.asset(
                    'assets/images/logo_uniteve.svg',
                    width: 80,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Lista reativa de playlists; rebuilda quando controller.playlists mudar
              Obx(
                () => Column(
                  children: controller.playlists
                      .map(
                        (p) =>
                            PlaylistCard(playlist: p, controller: controller),
                      )
                      .toList(),
                ),
              ),

              const SizedBox(height: 16),
              FooterWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final UniteveController controller;

  const PlaylistCard({
    super.key,
    required this.playlist,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasDescription =
        playlist.description != null && playlist.description != "";
    return Column(
      children: [
        Card(
          shape: const ContinuousRectangleBorder(),
          color: Colors.transparent,
          elevation: 0,
          shadowColor: Colors.transparent,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 32),
                  Expanded(
                    child: Text(
                      playlist.name ?? 'utv_loading'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: hasDescription
                        ? () => PlaylistInfoDialog.show(controller, playlist)
                        : null,
                    icon: Icon(
                      Icons.info_outline,
                      color: hasDescription ? Colors.white : Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              CarouselSlider(
                options: CarouselOptions(
                  enlargeCenterPage: true,
                  autoPlay: false,
                  clipBehavior: Clip.antiAlias,
                ),
                items: playlist.hasFinishLoading
                    ? playlist.videos!
                          .map(
                            (el) =>
                                VideoCard(video: el, playlistID: playlist.id),
                          )
                          .toList()
                    : [const Center(child: CustomProgressDisplay())],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class VideoCard extends StatelessWidget {
  final youtube.PlaylistItem video;
  final String playlistID;

  const VideoCard({super.key, required this.video, required this.playlistID});

  @override
  Widget build(BuildContext context) {
    youtube.Thumbnail? a =
        (video.snippet!.thumbnails!.standard ??
        video.snippet!.thumbnails!.high ??
        video.snippet!.thumbnails!.default_);
    String url = "";
    if (a != null) {
      url = a.url!;
    } else {
      return const SizedBox.shrink();
    }

    return Card(
      color: AppColors.darkBlue(),
      child: GestureDetector(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
          ),
          child: Center(
            child: Icon(
              Icons.play_arrow_rounded,
              color: Colors.grey[200],
              size: 64,
            ),
          ),
        ),
        onTap: () async {
          //print("\n\nID DO VÍDEO: ${video.snippet?.resourceId?.videoId}\n\n");
          Uri uri = Uri.https("www.youtube.com", "/watch", {
            "v": "${video.snippet?.resourceId?.videoId}",
            "list": playlistID,
          });
          launchUrl(uri, mode: LaunchMode.externalApplication);
        },
      ),
    );
  }
}

class PlaylistInfoDialog extends StatelessWidget {
  final Playlist playlist;
  const PlaylistInfoDialog({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const ContinuousRectangleBorder(),
      backgroundColor: AppColors.darkBlue(),
      title: Center(
        child: Text(
          playlist.name ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      content: Text(
        playlist.description ?? '',
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  static void show(UniteveController controller, Playlist playlist) {
    Get.dialog(PlaylistInfoDialog(playlist: playlist));
  }
}

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Link(
          uri: Uri.parse('https://pt-br.facebook.com/uniteveuff/'),
          builder: (_, link) => IconButton(
            onPressed: link,
            icon: SvgPicture.asset('assets/icons/circle_facebook.svg'),
          ),
        ),
        Link(
          uri: Uri.parse('https://www.instagram.com/uniteveuff/'),
          builder: (_, link) => IconButton(
            onPressed: link,
            icon: SvgPicture.asset('assets/icons/circle_instagram.svg'),
          ),
        ),
        Link(
          uri: Uri.parse('https://www.youtube.com/user/uniteveuff'),
          builder: (_, link) => IconButton(
            onPressed: link,
            icon: SvgPicture.asset('assets/icons/circle_youtube.svg'),
          ),
        ),
      ],
    );
  }
}
