import 'dart:io';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

final ImagePicker _picker = ImagePicker();

Future<XFile?> pickImage() async {
  try {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    return pickedFile;
  } catch (e) {
    print('Image picking failed: $e');
    return null;
  }
}

Future<XFile?> takeImagePhoto() async {
  try {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    return pickedFile;
  } catch (e) {
    // Handle error (e.g., camera permission denied)
    print('Camera failed: $e');
    return null;
  }
}

Future<String> saveImageFile(XFile pickedFile) async {
  final Directory appDocDir = await getApplicationDocumentsDirectory();

  final String imagePath = '${appDocDir.path}/itemImages';
  await Directory(imagePath).create(recursive: true);

  const Uuid uuid = Uuid();
  final String fileName = '${uuid.v4()}.jpg';
  final String newFilePath = '$imagePath/$fileName';

  final File newFile = await File(pickedFile.path).copy(newFilePath);

  return newFile.path;
}

enum ImageUrlType { network, localFile, unknown }

ImageUrlType getImageUrlType(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || uri.scheme.isEmpty) {
    return ImageUrlType.localFile;
  }
  final scheme = uri.scheme.toLowerCase();
  if (scheme == 'http' || scheme == 'https') {
    return ImageUrlType.network;
  }
  if (scheme == 'file' || scheme == 'content' || scheme == 'asset') {
    return ImageUrlType.localFile;
  }

  return ImageUrlType.unknown;
}

Future<bool> saveImageBytesToGallery(
  List<int> bytes,
  String fileName, {
  String? albumName,
}) async {
  try {
    final hasAccess = await Gal.hasAccess();
    if (!hasAccess) {
      final granted = await Gal.requestAccess();
      if (!granted) {
        return false;
      }
    }

    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/$fileName');
    await tempFile.writeAsBytes(bytes);
    await Gal.putImage(tempFile.path, album: albumName);
    await tempFile.delete();

    return true;
  } catch (e) {
    print(e);
    return false;
  }
}
