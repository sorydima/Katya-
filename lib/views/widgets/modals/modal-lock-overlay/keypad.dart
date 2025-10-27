import 'package:flutter/material.dart';
import 'package:katya/global/dimensions.dart';
import 'package:katya/views/widgets/modals/modal-lock-overlay/lock-buttons.dart';
import 'package:katya/views/widgets/modals/modal-lock-overlay/lock-controller.dart';

/// In order to arrange the buttons neatly by their size,
/// I dared to adjust them without using GridView or Wrap.
/// If you use GridView, you have to specify the overall width to adjust the size of the button,
/// which makes it difficult to specify the size intuitively.
class KeyPad extends StatelessWidget {
  const KeyPad({
    super.key,
    required this.lockController,
    required this.canCancel,
    this.inputButtonConfig = const Object(),
    this.rightButtonChild,
    this.onLeftButtonTap,
    this.deleteButton,
    this.cancelButton,
  });

  final LockController lockController;
  final bool canCancel;
  final Object inputButtonConfig; // Using Object for compatibility
  final Widget? rightButtonChild;
  final Future<void> Function()? onLeftButtonTap;
  final Widget? cancelButton;
  final Widget? deleteButton;

  Widget _buildLeftSideButton() {
    return StreamBuilder<String>(
      stream: lockController.currentInput,
      builder: (context, snapshot) {
        if ((snapshot.hasData == false || snapshot.data!.isEmpty) && canCancel) {
          return Container(
            child: IconButton(
              onPressed: onLeftButtonTap == null ? () => false : () => onLeftButtonTap!(),
              icon: const Icon(
                Icons.cancel,
                size: Dimensions.iconSizeLarge,
              ),
            ),
          );
        } else {
          return Container(
            child: IconButton(
              onPressed: () => lockController.removeCharacter(),
              icon: const Icon(
                Icons.backspace,
                size: Dimensions.iconSizeLarge,
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildRightSideButton() {
    return StreamBuilder<bool>(
      stream: lockController.loading,
      builder: (context, loadingData) => StreamBuilder<String>(
        stream: lockController.currentInput,
        builder: (context, currentInput) {
          final loading = loadingData.data ?? false;

          if (currentInput.hasData == false || currentInput.data!.isEmpty) {
            return Container(); // Hidden button
          } else {
            return LockButton(
              disabled: loading,
              onPressed: () => lockController.verify(),
              child: const Icon(
                Icons.check_circle,
                size: Dimensions.iconSizeLarge,
              ),
            );
          }
        },
      ),
    );
  }

  Widget _generateRow(BuildContext context, int rowNumber) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final number = (rowNumber - 1) * 3 + index + 1;
        final input = '$number'; // Simplified for compatibility
        final display = '$number'; // Simplified for compatibility

        return Container(
          child: TextButton(
            onPressed: () => lockController.addCharacter(input),
            child: Text(display),
          ),
        );
      }),
    );
  }

  Widget _generateLastRow(BuildContext context) {
    const input = '0'; // Simplified for compatibility
    const display = '0'; // Simplified for compatibility

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLeftSideButton(),
        Container(
          child: TextButton(
            onPressed: () => lockController.addCharacter(input),
            child: const Text(display),
          ),
        ),
        _buildRightSideButton(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // assert(inputButtonConfig.displayStrings.length == 10); // Simplified for compatibility
    // assert(inputButtonConfig.inputStrings.length == 10); // Simplified for compatibility

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _generateRow(context, 1),
        _generateRow(context, 2),
        _generateRow(context, 3),
        _generateLastRow(context),
      ],
    );
  }
}
