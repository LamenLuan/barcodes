import 'package:barcodes/classes/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../classes/snack_bars.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.isExpanded,
    required this.onCardLongPress,
    required this.onEditButtonPressed,
    required this.onDeleteButtonPressed,
  });

  final Product product;
  final VoidCallback onCardLongPress;
  final VoidCallback onEditButtonPressed;
  final VoidCallback onDeleteButtonPressed;
  final bool isExpanded;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  List<Widget> getCardContent() {
    List<Widget> content = [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.product.name, maxLines: 1),
            SizedBox(height: 6),
            Text('EAN: ${widget.product.barcode}'),
          ],
        ),
      ),
    ];

    if (widget.isExpanded == false) return content;

    content.add(
      Row(
        spacing: 12,
        children: [
          ElevatedButton(
            onPressed: widget.onDeleteButtonPressed,
            child: Icon(Icons.delete),
          ),
          ElevatedButton(
            onPressed: widget.onEditButtonPressed,
            child: Icon(Icons.edit),
          ),
        ],
      ),
    );

    return content;
  }

  void onCardTap() async {
    await Clipboard.setData(ClipboardData(text: widget.product.barcode));

    if (mounted == false) return;

    SnackBars.showInformativeSnackBar(
      context,
      'Código EAN copiado para área de transferência!',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(0, 12, 0, 0),
      child: InkWell(
        onTap: onCardTap,
        onLongPress: widget.onCardLongPress,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: getCardContent(),
          ),
        ),
      ),
    );
  }
}
