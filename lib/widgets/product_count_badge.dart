import 'package:flutter/material.dart';

class ProductCountBadge extends StatelessWidget {
  final List<String> imageUrls;
  final int totalCount;

  const ProductCountBadge({
    super.key,
    required this.imageUrls,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: List.generate(
              imageUrls.length.clamp(0, 3), // show up to 3 images
                  (index) => Padding(padding: EdgeInsets.only(left: index * 20), child: CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.black,
                      child: CircleAvatar(
                        radius: 11,
                        backgroundImage: NetworkImage(imageUrls[0]),
                      ),
                    ),
                  ),),
            ),
          ),
          const SizedBox(width: 8), // spacing after last avatar
          // --- Product count text ---
          Text(
            "$totalCount sản phẩm",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
