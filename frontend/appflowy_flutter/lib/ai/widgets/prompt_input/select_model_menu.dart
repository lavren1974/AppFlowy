import 'package:appflowy/ai/ai.dart';
import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flowy_infra_ui/style_widget/hover.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectModelMenu extends StatefulWidget {
  const SelectModelMenu({
    super.key,
    required this.aiModelStateNotifier,
  });

  final AIModelStateNotifier aiModelStateNotifier;

  @override
  State<SelectModelMenu> createState() => _SelectModelMenuState();
}

class _SelectModelMenuState extends State<SelectModelMenu> {
  final popoverController = PopoverController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SelectModelBloc(
        aiModelStateNotifier: widget.aiModelStateNotifier,
      ),
      child: BlocBuilder<SelectModelBloc, SelectModelState>(
        builder: (context, state) {
          if (state.selectedModel == null) {
            return const SizedBox.shrink();
          }
          return AppFlowyPopover(
            offset: Offset(-12.0, 0.0),
            constraints: BoxConstraints(maxWidth: 250, maxHeight: 600),
            direction: PopoverDirection.topWithLeftAligned,
            margin: EdgeInsets.zero,
            controller: popoverController,
            popupBuilder: (popoverContext) {
              return SelectModelPopoverContent(
                models: state.models,
                selectedModel: state.selectedModel,
                onSelectModel: (model) {
                  if (model != state.selectedModel) {
                    context
                        .read<SelectModelBloc>()
                        .add(SelectModelEvent.selectModel(model));
                  }
                  popoverController.close();
                },
              );
            },
            child: _CurrentModelButton(
              modelName: state.selectedModel!.name,
              onTap: () => popoverController.show(),
            ),
          );
        },
      ),
    );
  }
}

class SelectModelPopoverContent extends StatelessWidget {
  const SelectModelPopoverContent({
    super.key,
    required this.models,
    required this.selectedModel,
    this.onSelectModel,
  });

  final List<AiModel> models;
  final AiModel? selectedModel;
  final void Function(AiModel)? onSelectModel;

  @override
  Widget build(BuildContext context) {
    if (models.isEmpty) {
      return const SizedBox.shrink();
    }

    // separate models into local and cloud models
    final localModels = models.where((model) => model.isLocal).toList();
    final cloudModels = models.where((model) => !model.isLocal).toList();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (localModels.isNotEmpty) ...[
            _ModelSectionHeader(
              title: LocaleKeys.chat_switchModel_localModel.tr(),
            ),
            const VSpace(4.0),
          ],
          ...localModels.map(
            (model) => _ModelItem(
              model: model,
              isSelected: model == selectedModel,
              onTap: () => onSelectModel?.call(model),
            ),
          ),
          if (cloudModels.isNotEmpty && localModels.isNotEmpty) ...[
            const VSpace(8.0),
            _ModelSectionHeader(
              title: LocaleKeys.chat_switchModel_cloudModel.tr(),
            ),
            const VSpace(4.0),
          ],
          ...cloudModels.map(
            (model) => _ModelItem(
              model: model,
              isSelected: model == selectedModel,
              onTap: () => onSelectModel?.call(model),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModelSectionHeader extends StatelessWidget {
  const _ModelSectionHeader({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      child: FlowyText(
        title,
        fontSize: 12,
        figmaLineHeight: 16,
        color: Theme.of(context).hintColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _ModelItem extends StatelessWidget {
  const _ModelItem({
    required this.model,
    required this.isSelected,
    required this.onTap,
  });

  final AiModel model;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: FlowyButton(
        onTap: onTap,
        margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        text: FlowyText(model.name),
        rightIcon: isSelected ? FlowySvg(FlowySvgs.check_s) : null,
      ),
    );
  }
}

class _CurrentModelButton extends StatelessWidget {
  const _CurrentModelButton({
    required this.modelName,
    required this.onTap,
  });

  final String modelName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FlowyTooltip(
      message: LocaleKeys.chat_switchModel_label.tr(),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: DesktopAIPromptSizes.actionBarButtonSize,
          child: FlowyHover(
            style: const HoverStyle(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(4.0),
              child: Row(
                children: [
                  FlowyText(
                    modelName,
                    fontSize: 12,
                    figmaLineHeight: 16,
                    color: Theme.of(context).hintColor,
                  ),
                  HSpace(2.0),
                  FlowySvg(
                    FlowySvgs.ai_source_drop_down_s,
                    color: Theme.of(context).hintColor,
                    size: const Size.square(8),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
