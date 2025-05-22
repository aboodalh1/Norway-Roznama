import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:norway_roznama_new_project/core/util/service_locator.dart';
import 'package:norway_roznama_new_project/features/articles_and_stickers/data/repos/stickers_repos/stickers_repo_impl.dart';
import 'package:norway_roznama_new_project/features/articles_and_stickers/stickers/manger/stickers/stickers_cubit.dart';

class StickersPage extends StatelessWidget {
  const StickersPage(
      {super.key, required this.catIndex, required this.catName});

  final int catIndex;

  final String catName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StickersCubit(getIt.get<StickersRepoImpl>()),
      child: BlocBuilder<StickersCubit, StickersState>(
        builder: (context, state) {
          StickersCubit stickersCubit = context.read<StickersCubit>();
          return Scaffold(
            appBar: AppBar(
              title: Text(catName),
            ),
            body: GridView.builder(
                itemBuilder: (context, state) {
                  return Container(
                    child: Image.network(
                      fit: BoxFit.contain,
                        stickersCubit.stickersModel.data[catIndex].url),
                  );
                },
                itemCount: stickersCubit.stickersModel.data.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                )
            ),
          );
        },
      ),
    );
  }
}
