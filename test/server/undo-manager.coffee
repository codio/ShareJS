expect = require('chai').expect
UndoManager = require '../../lib/client/undo-manager'

describe 'UndoManager', ->

  it 'exists', ->
    expect(UndoManager).to.exist

  it 'can be instantiated', ->
    expect(new UndoManager).to.be.an.instanceof UndoManager
    expect(UndoManager()).to.be.an.instanceof UndoManager

  describe 'options', ->
    describe 'history limit', ->
      it 'defaults to 100', ->
        expect(new UndoManager).to.have.property 'historyLimit', 100

      it 'can be passed a custom history limit', ->
        expect(new UndoManager 10).to.have.property 'historyLimit', 10


  describe '.pushUndo', ->
    beforeEach ->
      @manager = new UndoManager

    it 'exists', ->
      expect(@manager.pushUndo).to.be.a 'function'

    it 'adds the operation to the undo stack', ->
      @manager.pushUndo ['hello']
      expect(@manager.undoStack).to.be.eql [['hello']]

    it 'deletes the first entry if the history limit is reached', ->
      @manager = new UndoManager 2
      @manager.pushUndo ['hello']
      @manager.pushUndo [' ']
      expect(@manager.undoStack).to.be.eql [['hello'], [' ']]

      @manager.pushUndo ['world']
      expect(@manager.undoStack).to.be.eql [[' '], ['world']]


  describe '.undo', ->
    beforeEach ->
      @manager = new UndoManager

    it 'exists', ->
      expect(@manager.undo).to.be.a 'function'

    it 'throws if the undo stack is empty', ->
      expect(=> @manager.undo()).to.throw 'No actions to be undone!'

    it 'pops the last operation on the undo stack and returns it', ->
      @manager.pushUndo ['hello']
      expect(@manager.undo()).to.be.eql ['hello']
      expect(@manager.undoStack).to.be.empty


  describe '.pushRedo', ->
    beforeEach ->
      @manager = new UndoManager

    it 'exists', ->
      expect(@manager.pushRedo).to.be.a 'function'

    it 'adds the operation to the redo stack', ->
      @manager.pushRedo ['hello']
      expect(@manager.redoStack).to.be.eql [['hello']]

    it 'deletes the first entry if the history limit is reached', ->
      @manager = new UndoManager 2
      @manager.pushRedo ['hello']
      @manager.pushRedo [' ']
      expect(@manager.redoStack).to.be.eql [['hello'], [' ']]

      @manager.pushRedo ['world']
      expect(@manager.redoStack).to.be.eql [[' '], ['world']]


  describe '.redo', ->
    beforeEach ->
      @manager = new UndoManager

    it 'exists', ->
      expect(@manager.redo).to.be.a 'function'

    it 'throws if the redo stack is empty', ->
      expect(=> @manager.redo()).to.throw 'No actions to be redone!'

    it 'pops the last operation on the redo stack and returns it', ->
      @manager.pushRedo ['hello']
      expect(@manager.redo()).to.be.eql ['hello']
      expect(@manager.redoStack).to.be.empty


  describe '.canUndo', ->
    beforeEach ->
      @manager = new UndoManager

    it 'exists', ->
      expect(@manager.canUndo).to.be.a 'function'

    it 'returns true if there are entries in the undo stack', ->
      @manager.pushUndo ['hello']
      expect(@manager.canUndo()).to.be.true

    it 'returns false if there are no entries in the undo stack', ->
      expect(@manager.canUndo()).to.be.false

  describe '.canRedo', ->
    beforeEach ->
      @manager = new UndoManager

    it 'exists', ->
      expect(@manager.canRedo).to.be.a 'function'

    it 'returns true if there are entries in the redo stack', ->
      @manager.pushRedo ['hello']
      expect(@manager.canRedo()).to.be.true

    it 'returns false if there are no entries in the redo stack', ->
      expect(@manager.canRedo()).to.be.false
