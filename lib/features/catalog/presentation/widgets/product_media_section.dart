import 'package:flutter/material.dart';

class ProductMediaSection extends StatelessWidget {
  const ProductMediaSection({
    super.key,
    required this.imageUrl,
    required this.imageFileName,
    required this.technicalSheetUrl,
    required this.technicalSheetFileName,
    required this.onViewImage,
    required this.onViewTechnicalSheet,
    required this.onSelectExistingImage,
    required this.onUploadNewImage,
    required this.onClearImage,
    required this.onSelectExistingTechnicalSheet,
    required this.onUploadNewTechnicalSheet,
    required this.onClearTechnicalSheet,
    this.isBusy = false,
  });

  final String imageUrl;
  final String imageFileName;
  final String technicalSheetUrl;
  final String technicalSheetFileName;
  final VoidCallback onViewImage;
  final VoidCallback onViewTechnicalSheet;
  final VoidCallback onSelectExistingImage;
  final VoidCallback onUploadNewImage;
  final VoidCallback onClearImage;
  final VoidCallback onSelectExistingTechnicalSheet;
  final VoidCallback onUploadNewTechnicalSheet;
  final VoidCallback onClearTechnicalSheet;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withAlpha(128),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Archivos del producto',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _ProductFileCard(
              title: 'Imagen del producto',
              subtitle: imageFileName.isEmpty
                  ? 'Aun no se ha seleccionado una imagen.'
                  : imageFileName,
              icon: Icons.image_outlined,
              isBusy: isBusy,
              preview: imageUrl.isEmpty
                  ? null
                  : _ImagePreview(imageUrl: imageUrl, onTap: onViewImage),
              onViewFile: imageUrl.isEmpty ? null : onViewImage,
              viewLabel: 'Ver imagen',
              onSelectExisting: onSelectExistingImage,
              onUploadNew: onUploadNewImage,
              onClear: imageUrl.isEmpty ? null : onClearImage,
              selectLabel: 'Elegir de files',
              uploadLabel: 'Subir nueva',
            ),
            const SizedBox(height: 16),
            _ProductFileCard(
              title: 'Ficha tecnica PDF',
              subtitle: technicalSheetFileName.isEmpty
                  ? 'Aun no se ha seleccionado una ficha tecnica.'
                  : technicalSheetFileName,
              icon: Icons.picture_as_pdf_outlined,
              isBusy: isBusy,
              preview: technicalSheetUrl.isEmpty
                  ? null
                  : _PdfPreview(
                      fileName: technicalSheetFileName,
                      onTap: onViewTechnicalSheet,
                    ),
              onViewFile: technicalSheetUrl.isEmpty ? null : onViewTechnicalSheet,
              viewLabel: 'Ver PDF',
              onSelectExisting: onSelectExistingTechnicalSheet,
              onUploadNew: onUploadNewTechnicalSheet,
              onClear: technicalSheetUrl.isEmpty ? null : onClearTechnicalSheet,
              selectLabel: 'Elegir de files',
              uploadLabel: 'Subir PDF',
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductFileCard extends StatelessWidget {
  const _ProductFileCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isBusy,
    this.preview,
    this.onViewFile,
    this.viewLabel,
    required this.onSelectExisting,
    required this.onUploadNew,
    required this.selectLabel,
    required this.uploadLabel,
    this.onClear,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isBusy;
  final Widget? preview;
  final VoidCallback? onViewFile;
  final String? viewLabel;
  final VoidCallback onSelectExisting;
  final VoidCallback onUploadNew;
  final VoidCallback? onClear;
  final String selectLabel;
  final String uploadLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (onClear != null)
                IconButton(
                  onPressed: isBusy ? null : onClear,
                  tooltip: 'Quitar archivo',
                  icon: const Icon(Icons.close_rounded),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (preview != null) ...[const SizedBox(height: 12), preview!],
          if (onViewFile != null && viewLabel != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: isBusy ? null : onViewFile,
                icon: const Icon(Icons.open_in_new_rounded),
                label: Text(viewLabel!),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isBusy ? null : onSelectExisting,
                  icon: const Icon(Icons.folder_outlined),
                  label: Text(selectLabel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: isBusy ? null : onUploadNew,
                  icon: isBusy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload_file_outlined),
                  label: Text(uploadLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.imageUrl, required this.onTap});

  final String imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) {
              return _PreviewPlaceholder(
                icon: Icons.broken_image_outlined,
                label: 'No se pudo cargar la imagen',
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }

              return const _PreviewPlaceholder(
                icon: Icons.image_outlined,
                label: 'Cargando imagen...',
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PdfPreview extends StatelessWidget {
  const _PdfPreview({required this.fileName, required this.onTap});

  final String fileName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.picture_as_pdf_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                fileName.isEmpty ? 'Abrir ficha tecnica' : fileName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewPlaceholder extends StatelessWidget {
  const _PreviewPlaceholder({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon), const SizedBox(height: 8), Text(label)],
      ),
    );
  }
}
