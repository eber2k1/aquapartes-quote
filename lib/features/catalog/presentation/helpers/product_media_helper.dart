import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/services/app_notifications.dart';
import '../../domain/entities/stored_file.dart';
import '../../domain/repositories/catalog_repository.dart';

class ProductMediaHelper {
  ProductMediaHelper({required this.repository});

  final CatalogRepository repository;

  Future<void> selectExistingImage({
    required BuildContext context,
    required ValueChanged<StoredFile> onSelected,
  }) {
    return _selectExistingFile(
      context: context,
      loadFiles: repository.fetchProductImageFiles,
      deleteFile: repository.deleteGenericProductImage,
      title: 'Elegir imagen existente',
      onSelected: onSelected,
      isImage: true,
    );
  }

  Future<void> selectExistingTechnicalSheet({
    required BuildContext context,
    required ValueChanged<StoredFile> onSelected,
  }) {
    return _selectExistingFile(
      context: context,
      loadFiles: repository.fetchTechnicalSheetFiles,
      deleteFile: repository.deleteGenericTechnicalSheet,
      title: 'Elegir ficha tecnica existente',
      onSelected: onSelected,
    );
  }

  Future<void> uploadNewImage({
    required BuildContext context,
    required void Function(String url, String fileName) onUploaded,
    required ValueChanged<bool> onBusyChanged,
  }) {
    return _pickAndUploadFile(
      context: context,
      type: FileType.image,
      uploadFile: repository.uploadGenericProductImage,
      onUploaded: onUploaded,
      onBusyChanged: onBusyChanged,
      emptySelectionMessage: 'No se selecciono ninguna imagen.',
      successMessage: 'Imagen subida correctamente.',
    );
  }

  Future<void> uploadNewTechnicalSheet({
    required BuildContext context,
    required void Function(String url, String fileName) onUploaded,
    required ValueChanged<bool> onBusyChanged,
  }) {
    return _pickAndUploadFile(
      context: context,
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      uploadFile: repository.uploadGenericTechnicalSheet,
      onUploaded: onUploaded,
      onBusyChanged: onBusyChanged,
      emptySelectionMessage: 'No se selecciono ningun PDF.',
      successMessage: 'Ficha tecnica subida correctamente.',
    );
  }

  Future<void> openUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) {
      AppNotifications.showInfo('La URL del archivo no es valida.');
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && context.mounted) {
      AppNotifications.showInfo('No se pudo abrir el archivo.');
    }
  }

  Future<void> showImagePreview({
    required BuildContext context,
    required String imageUrl,
  }) async {
    if (imageUrl.trim().isEmpty) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                automaticallyImplyLeading: false,
                title: const Text('Vista de imagen'),
                actions: [
                  IconButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              Flexible(
                child: InteractiveViewer(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) {
                      return const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('No se pudo cargar la imagen.'),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.tonalIcon(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    await openUrl(context, imageUrl);
                  },
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Abrir enlace'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectExistingFile({
    required BuildContext context,
    required Future<List<StoredFile>> Function() loadFiles,
    required Future<void> Function(String url)? deleteFile,
    required String title,
    required ValueChanged<StoredFile> onSelected,
    bool isImage = false,
  }) async {
    try {
      final files = await loadFiles();
      if (!context.mounted) return;

      if (files.isEmpty) {
        AppNotifications.showInfo(
          'No hay archivos disponibles en el servidor.',
        );
        return;
      }

      final selectedFile = await showModalBottomSheet<StoredFile>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (sheetContext) {
          return StatefulBuilder(
            builder: (context, setState) {
              final theme = Theme.of(context);
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 12),
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: files.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (itemContext, index) {
                            final file = files[index];
                            return ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: theme.colorScheme.outlineVariant,
                                ),
                              ),
                              title: Text(file.label),
                              trailing: deleteFile != null
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: theme.colorScheme.error,
                                      ),
                                      onPressed: () async {
                                        final confirm =
                                            await _showDeleteConfirmation(
                                              context: itemContext,
                                              file: file,
                                              isImage: isImage,
                                            );

                                        if (confirm == true) {
                                          try {
                                            await deleteFile(file.url);
                                            setState(() {
                                              files.removeAt(index);
                                            });
                                            if (itemContext.mounted) {
                                              AppNotifications.showSuccess(
                                                'Archivo eliminado correctamente.',
                                              );
                                            }
                                          } catch (e) {
                                            if (itemContext.mounted) {
                                              final msg = e
                                                  .toString()
                                                  .replaceFirst(
                                                    'Exception: ',
                                                    '',
                                                  );
                                              AppNotifications.showDelete(
                                                'No se pudo eliminar: $msg',
                                              );
                                            }
                                          }
                                        }
                                      },
                                    )
                                  : null,
                              onTap: () => Navigator.of(itemContext).pop(file),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );

      if (selectedFile == null) return;
      onSelected(selectedFile);
    } catch (_) {
      if (context.mounted) {
        AppNotifications.showInfo(
          'No se pudieron cargar los archivos del servidor.',
        );
      }
    }
  }

  Future<bool?> _showDeleteConfirmation({
    required BuildContext context,
    required StoredFile file,
    required bool isImage,
  }) async {
    final products = await repository.loadCachedProducts();
    final usedBy = products.where((p) {
      if (isImage) {
        return p.imageUrl == file.url;
      } else {
        return p.technicalSheetUrl == file.url;
      }
    }).toList();

    if (!context.mounted) return false;

    final theme = Theme.of(context);
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('¿Eliminar archivo?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (usedBy.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withAlpha(128),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.error.withAlpha(128),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '¡Cuidado! Este archivo esta siendo usado por ${usedBy.length} producto(s) (ej: ${usedBy.first.name}). Si lo eliminas, desaparecera de esos productos.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                '¿Estas seguro de que deseas eliminar permanentemente este archivo del servidor?\n\n${file.label}',
                style: theme.textTheme.bodyMedium,
              ),
              if (isImage) ...[
                const SizedBox(height: 16),
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Image.network(
                    file.url,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Text('No se pudo previsualizar la imagen'),
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton.tonal(
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.errorContainer,
                foregroundColor: theme.colorScheme.onErrorContainer,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickAndUploadFile({
    required BuildContext context,
    required FileType type,
    List<String>? allowedExtensions,
    required Future<String> Function(String filePath) uploadFile,
    required void Function(String url, String fileName) onUploaded,
    required ValueChanged<bool> onBusyChanged,
    required String emptySelectionMessage,
    required String successMessage,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: type,
      allowedExtensions: allowedExtensions,
      withData: false,
    );

    if (result == null || result.files.single.path == null) {
      if (context.mounted) {
        AppNotifications.showInfo(emptySelectionMessage);
      }
      return;
    }

    final filePath = result.files.single.path!;
    final selectedFileName = result.files.single.name;

    onBusyChanged(true);

    try {
      final uploadedUrl = await uploadFile(filePath);
      if (!context.mounted) return;

      onUploaded(uploadedUrl, selectedFileName);
      AppNotifications.showSuccess(successMessage);
    } catch (e) {
      if (context.mounted) {
        final errorMessage = e.toString().replaceFirst('Exception: ', '');
        AppNotifications.showDelete('No se pudo subir: $errorMessage');
      }
    } finally {
      if (context.mounted) {
        onBusyChanged(false);
      }
    }
  }
}
