

var state = {
  DEFAULT: 'default',
  UNDOING: 'undoing',
  REDOING: 'redoing'
};

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

  // Current state
  this.state = state.DEFAULT;
};

// Push to a given stack and remove the first operation if the history limit
// is reached.
UndoManager.prototype._push = function(stack, op) {
  if (!op || op.length === 0) return;

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
  switch (this.state) {
  case state.UNDOING:
    break;
  case state.REDOING:
    this._push(this.undoStack, op);
    break;
  case state.DEFAULT:
    this._push(this.undoStack, op);
    this.redoStack = [];
    break;
  }
};

// Add a single operation to the redo stack. The operation passed
// in is expected to be the inverted operation of the operation that
// was acutally applied.
UndoManager.prototype.pushRedo = function(op) {
  switch (this.state) {
  case state.UNDOING:
    this._push(this.redoStack, op);
    break;
  case state.REDOING:
  case state.DEFAULT:
    break;
  }
};


// Undo a single operation.
UndoManager.prototype.undo = function(callback) {
  this.state = state.UNDOING;
  if (this.undoStack.length === 0) return callback(new Error('No actions to be undone!'));

  callback(null, this.undoStack.pop());
  this.state = state.DEFAULT;
};

// Redo a single operation.
UndoManager.prototype.redo = function(callback) {
  this.state = state.REDOING;
  if (this.redoStack.length === 0) return callback(new Error('No actions to be redone!'));

  callback(null, this.redoStack.pop());
  this.state = state.DEFAULT;
};

// Check if undoes are possible
UndoManager.prototype.canUndo = function() {
  return this.undoStack.length !== 0;
};

// Check if redoes are possible
UndoManager.prototype.canRedo = function() {
  return this.redoStack.length !== 0;
};

// Transform a given stack against the given operation.
function transformStack(stack, op, type) {
  if (!type || typeof type.transform !== 'function') throw new Error('No vaild type provided!');

  var length = stack.length;
  for (var i = 0; i < length; i++) {
    stack[i] = type.transform(stack[i], op, 'left');
  }
}

// Transform the stacks against incoming operations
UndoManager.prototype.transform = function(op, type) {
  transformStack(this.undoStack, op, type);
  transformStack(this.redoStack, op, type);
};





