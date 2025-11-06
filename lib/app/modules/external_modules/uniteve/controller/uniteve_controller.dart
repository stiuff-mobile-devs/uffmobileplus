import 'package:get/get.dart';
import 'package:googleapis/youtube/v3.dart' as youtube;
import 'package:uffmobileplus/app/modules/external_modules/uniteve/data/services/youtube_services.dart';

// TODO: estar aqui ou em outro arquivo?
class Playlist {
    String? name;
    String id;
    String? description;
    int miliseconds;
    List<youtube.PlaylistItem>? videos;
    bool hasFinishLoading = false;

    Playlist(this.id, this.miliseconds);
}

class UniteveController extends GetxController {
    var playlists = <Playlist>[].obs;
    var gotPlaylists = false.obs;

    @override
    Future<void> onInit() async {
        super.onInit();
        List<String> l = await fetchPlaylistIdList();
        await fetchPlaylistListInfo(l);
    }

    // TODO: escolher um nome melhor
    Future<List<String>> fetchPlaylistIdList() async {
        List<String> playlistIdList = await YoutubeService.instance.getChannelSectionPlaylists();
        gotPlaylists.value = true;

        return playlistIdList;
    }

    // TODO: escolher um nome melhor
    fetchPlaylistListInfo(List<String> l) async {
        int m = DateTime.now().millisecondsSinceEpoch;

        for (var id in l) {
            var p = await YoutubeService.instance.getPlaylistInfo(id);
            var playlist = Playlist(id, m);
            playlist.name = p!.snippet!.title;
            playlist.description = p.snippet!.description;
            playlists.add(playlist);

            var item = (await YoutubeService.instance.getPlaylistItems(
                playlistId: playlist.id
            ))!;

            List<youtube.PlaylistItem> it = [];

            for (var i in item) {
                if (i.status!.privacyStatus != 'private') it.add(i);
            }

            playlist.videos = it;
            playlist.miliseconds = it[0].snippet!.publishedAt!.millisecondsSinceEpoch;
            playlist.hasFinishLoading = true;
            playlists.sort((a, b) => b.miliseconds.compareTo(a.miliseconds));
        }
    }
}
