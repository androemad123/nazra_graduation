import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/models/community.dart';
import '../../resources/color_manager.dart';
import '../../resources/styles_manager.dart';
import '../community_details_screen.dart';

class CommunityCard extends StatelessWidget {
  final Community c;

  const CommunityCard({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0.3,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: ColorManager.lightBrown),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        minTileHeight: 99.h,
        title: Text(
          c.name,
          style: semiBoldStyle(fontSize: 18, color: ColorManager.black),
        ),
        subtitle: Text(
          c.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: regularStyle(fontSize: 14, color: ColorManager.gray),
        ),
        trailing: Text(
          '${c.members.length} members',
          style: regularStyle(fontSize: 12, color: ColorManager.black),
        ),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => CommunityDetailsScreen(communityId: c.id),
          ));
        },
      ),
    );
  }
}
