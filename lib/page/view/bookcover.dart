import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:read_info/res.dart';

import '../../bean/book_item_bean.dart';

class BookCover extends StatelessWidget {
  const BookCover(this.book, {Key? key,this.radius=0}) : super(key: key);
  final BookBean? book;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final placeHolder = ClipRRect(borderRadius: BorderRadius.circular(radius),
      child: Stack(
        children: [
          Positioned.fill(child: Image.asset(
            Res.cover,
            fit: BoxFit.cover,
          )),
          Positioned(
            bottom: 0,
            right: 4,
            left: 4,
            height: 42,
            child: Container(
              alignment: Alignment.topCenter,
              child: Text(
                book?.name ?? "",
                textAlign: TextAlign.center,
                overflow: TextOverflow.clip,
                maxLines: 2,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color:Colors.black54),
              ),
            ),
          )
        ],
      ),
    );
    return CachedNetworkImage(
      imageUrl: book?.coverUrl ?? "",
      placeholder: (c, url) => placeHolder,
      errorWidget: (c, url, dy) => placeHolder,
      fit: BoxFit.cover,
    );
  }
}
