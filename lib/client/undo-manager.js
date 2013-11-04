/**
 * The undo manager handles the history of a given document
 * and provides the abillity to undo or redo local operations.
 *
 *
 */
var UndoManager = module.exports = function(historyLimit) {
  // Allow usage as
  //     var  undoManager = UndoManager();
  // or
  //     var undoManager = new UndoManger();
  if (!(this instanceof UndoManager)) return new UndoManager(historyLimit);

  // The maximum number of items in the undo history.
  this.historyLimit = historyLimit || 100;

  // The undo stack
  this.undoStack = [];

  // The redo stack
  this.redoStack = [];

};

// Push to a given stack and remove the first operation if the history limit
// is reached.
UndoManager.prototype._push = function(stack, op) {
  // If we have reached the history limit we delete the first element in the
  // undo stack.
  if (this.historyLimit < stack.length + 1) {
    stack.shift();
  }
  stack.push(op);
}

// Add a single operation to the undo stack. The operation passed
// in is expected to be the inverted operation of the operation that
// was acutally applied.
UndoManager.prototype.pushUndo = function(op) {
  this._push(this.undoStack, op);
};

// Add a single operation to the redo stack. The operation passed
// in is expected to be the inverted operation of the operation that
// was acutally applied.
UndoManager.prototype.pushRedo = function(op) {
  this._push(this.redoStack, op);
};

// Undo a single operation.
UndoManager.prototype.undo = function() {
  if (this.undoStack.length === 0) throw new Error('No actions to be undone!');

  return this.undoStack.pop();
};

// Redo a single operation.
UndoManager.prototype.redo = function() {
  if (this.redoStack.length === 0) throw new Error('No actions to be redone!');

  return this.redoStack.pop();
};


UndoManager.prototype.canUndo = function () {
  return this.undoStack.length !== 0;
};

UndoManager.prototype.canRedo = function () {
  return this.redoStack.length !== 0;
};





