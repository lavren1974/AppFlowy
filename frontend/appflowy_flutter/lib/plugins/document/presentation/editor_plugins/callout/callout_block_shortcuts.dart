import 'package:appflowy/plugins/document/presentation/editor_plugins/plugins.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';

/// Pressing Enter in a callout block will insert a newline (\n) within the callout,
/// while pressing Shift+Enter in a callout will insert a new paragraph next to the callout.
///
/// - support
///   - desktop
///   - mobile
///   - web
///
final CharacterShortcutEvent insertNewLineInCalloutBlock =
    CharacterShortcutEvent(
  key: 'insert a new line in callout block',
  character: '\n',
  handler: _insertNewLineHandler,
);

CharacterShortcutEventHandler _insertNewLineHandler = (editorState) async {
  final selection = editorState.selection?.normalized;
  if (selection == null) {
    return false;
  }

  final node = editorState.getNodeAtPath(selection.start.path);
  if (node == null || node.type != CalloutBlockKeys.type) {
    return false;
  }

  // delete the selection
  await editorState.deleteSelection(selection);

  if (HardwareKeyboard.instance.isShiftPressed) {
    // ignore the shift+enter event, fallback to the default behavior
    return false;
  } else if (node.children.isEmpty) {
    // insert a new paragraph within the callout block
    final path = node.path.child(0);
    final transaction = editorState.transaction;
    transaction.insertNode(
      path,
      paragraphNode(),
    );
    transaction.afterSelection = Selection.collapsed(
      Position(
        path: path,
      ),
    );
    await editorState.apply(transaction);
  }

  return true;
};
