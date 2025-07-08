// lib/photo_editor_page.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pro_image_editor/core/models/layers/layer_interaction.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:kiosk_app/models/frame_model.dart';

class PhotoEditorPage extends StatefulWidget {
  @override
  _PhotoEditorPageState createState() => _PhotoEditorPageState();
}

class _PhotoEditorPageState extends State<PhotoEditorPage> {
  final _editorKey = GlobalKey<ProImageEditorState>();
  late Frame _frame;
  late File _customerImageFile; 
  late Uint8List _blankBackground;
  late bool _isAsset;
  late String _assetImagePath;


  Future<void> _loadBlankBackground() async {
    final data = await rootBundle.load('assets/images/frames/white.jpg');
    setState(() {
      _blankBackground = data.buffer.asUint8List();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadBlankBackground();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupEditor();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _frame = args['frame'] as Frame;
    // _customerImageFile = args['customerImageFile'] as File;
    final bool isAsset = args['isAsset'] ?? false;
    final String imagePath = args['imagePath'] as String;

     if (isAsset) {
      _customerImageFile = File('');
      _isAsset = true;
      _assetImagePath = imagePath;
    } else {
      _customerImageFile = File(imagePath);
      _isAsset = false;
      _assetImagePath = '';
    }
  }
  
  Future<void> _setupEditor() async {
    await Future.delayed(const Duration(milliseconds: 100));
    await _addLayers();
  }

  Future<void> _addLayers() async {
    // Add customer photo as the bottom layer
    // final customerImageBytes = await _customerImageFile.readAsBytes();
    // _editorKey.currentState?.addLayer(
    //   WidgetLayer(
    //     widget: Image.memory(customerImageBytes),
    //     offset: Offset.zero,
    //     scale: 4.0,
    //   ),
    // );
    Uint8List customerImageBytes;
    if (_isAsset) {
      final data = await rootBundle.load(_assetImagePath);
      customerImageBytes = data.buffer.asUint8List();
    } else {
      customerImageBytes = await _customerImageFile.readAsBytes();
    }

    _editorKey.currentState?.addLayer(
      WidgetLayer(
        widget: Image.memory(customerImageBytes),
        offset: Offset.zero,
        scale: 4.0,
      ),
    );

    // Add frame as the top layer
    final frameBytes = await _loadImageBytes(_frame.imagePath);
    _editorKey.currentState?.addLayer(
      WidgetLayer(
        widget: Image.memory(
          frameBytes,
          // width: _editorKey.currentState!.sizesManager.bodySize.width,
          // height: _editorKey.currentState!.sizesManager.bodySize.height,
          fit: BoxFit.contain,
        ),
        scale: 5.0,
        offset: Offset(450, -200), // Adjust as needed
        interaction: LayerInteraction(
          // enableMove: false,
          // enableScale: false,
          // enableRotate: false,
          // enableEdit: false,
          // enableSelection: false,
        ),
      ),
    );
  }

  Future<Uint8List> _loadImageBytes(String path) async {
    if (path.startsWith('assets/')) {
      final byteData = await DefaultAssetBundle.of(context).load(path);
      return byteData.buffer.asUint8List();
    } else {
      return await File(path).readAsBytes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProImageEditor.memory(
      _blankBackground,
      key: _editorKey,
      callbacks: ProImageEditorCallbacks(
        // The one true way to get the final image
        onImageEditingComplete: (Uint8List bytes) async {
          showDialog(
            context: context,
            builder: (dialogContext) {
              return AlertDialog(
                // The title of the dialog
                title: const Text('Editor Output'),
                
                // The main content of the dialog
                content: Column(
                  mainAxisSize: MainAxisSize.min, // Make the column size to its content
                  children: [
                    Text('Are you sure you want to print this image?'),
                    const SizedBox(height: 16),
                    // Display the image that we received from the editor
                    Image.memory(bytes, fit: BoxFit.contain, height: 500, width: 500),
                  ],
                ),
                
                // Action buttons for the dialog
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Close'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red, // This changes the text (and icon) color
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Close the dialog AND then proceed to the print page
                      // Navigator.of(dialogContext).pop();
                      Navigator.pushNamed(context, '/print_confirmation', arguments: bytes);
                    },
                    child: const Text('Print This'),
                  )
                ],
              );
            },
          );

          // Navigator.pop(context, bytes); // Return the final image as a result

          // Navigator.pushNamed(
          //   context,
          //   '/print_confirmation',
          //   arguments: bytes,
          // );
        },
        // onCloseEditor: (_) {
        //   if (Navigator.canPop(context)) Navigator.pop(context);
        // },
      ),
      configs: ProImageEditorConfigs(
        cropRotateEditor: const CropRotateEditorConfigs(enabled: false),
        paintEditor: const PaintEditorConfigs(enabled: true),
        textEditor: const TextEditorConfigs(enabled: true),
        filterEditor: const FilterEditorConfigs(enabled: false),
        blurEditor: const BlurEditorConfigs(enabled: false),
        stickerEditor: const StickerEditorConfigs(enabled: false),
               
        mainEditor: MainEditorConfigs(
          widgets: MainEditorWidgets(
            // This injects our custom bottom bar.
            bottomBar: (editor, rebuildStream, key) {
              return ReactiveWidget(
                stream: rebuildStream,
                key: key,
                builder: (_) => _buildCustomBottomBar(editor),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCustomBottomBar(ProImageEditorState editor) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // TextButton.icon(
              //   icon: const Icon(Icons.crop_rotate, size: 28, color: Colors.black),
              //   label: const Text("Crop/Rotate", style: TextStyle(fontSize: 28, color: Colors.black),),
              //   onPressed: editor.openCropRotateEditor,
              // ),
              TextButton.icon(
                icon: const Icon(Icons.info, size: 28, color: Colors.white60),
                label: const Text("How to?", style: TextStyle(fontSize: 28, color: Colors.white60),),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) {
                      return AlertDialog(
                        
                        title: const Text('How to Use This Editor'),
                        content: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.8, // 80% of screen
                          ),
                          child: const Text(
                            '1. Tap a layer to select it.\n'
                            '2. Drag the layer to move around.\n'
                            '3. Hold and drag the bottom right corner of a layer to resize/rotate it.\n\n'
                            '   NOTE: Edit the photo layer first. Placing the frame layer prevents access to the photo layer. If you want to edit the photo layer after placing the frame, you can simply move the frame away from the photo layer, edit the photo layer, and then move the frame back on top of the photo layer.\n\n'
                            '4. Tap the buttons below to use advance drawing or text features.\n'
                            '5. When done, click the check icon on the top right of the screen to proceed.',
                            softWrap: true,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text('Got it!'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(width: 30),
              TextButton.icon(
                icon: const Icon(Icons.edit, size: 28, color: Colors.white),
                label: const Text("Draw", style: TextStyle(fontSize: 28, color: Colors.white),),
                onPressed: editor.openPaintEditor,
              ),
              const SizedBox(width: 30), 
              TextButton.icon(
                icon: const Icon(Icons.text_fields_rounded, size: 32, color: Colors.white),
                label: const Text("Add Text", style: TextStyle(fontSize: 28, color: Colors.white),),
                onPressed: editor.openTextEditor,
              ),
            ],
          ),
          // const Divider(height: 16),
        ],
      ),
    );
  }


}