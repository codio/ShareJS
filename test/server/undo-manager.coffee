expect = require('chai').expect
UndoManager = require '../../lib/client/undo-manager'
textType = require('ottypes')['http://sharejs.org/types/textv1']

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

    it 'ignores calls when undoing', ->
      @manager = new UndoManager
      @manager.state = 'undoing'
      @manager.pushUndo ['hello']
      expect(@manager.undoStack).to.be.empty

  describe '.undo', ->
    beforeEach ->
      @manager = new UndoManager

    it 'exists', ->
      expect(@manager.undo).to.be.a 'function'

    it 'calls the callback with an error if the undo stack is empty', (done) ->
      @manager.undo (err, res) ->
        expect(err).to.be.eql new Error('No actions to be undone!')
        done()

    it 'pops the last operation on the undo stack and calls the provied callback', (done) ->
      @manager.pushUndo ['hello']
      @manager.undo (err, op) =>
        expect(op).to.be.eql ['hello']
        expect(@manager.undoStack).to.be.empty
        done()

    it 'ignores pushUndo while undoing', (done) ->
      @manager.pushUndo ['hello']
      @manager.undo (err, op) =>
        expect(op).to.be.eql ['hello']
        @manager.pushUndo ['world']
        expect(@manager.undoStack).to.be.empty
        done()

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

    it 'ignores calls when redoing', ->
      @manager = new UndoManager
      @manager.state = 'redoing'
      @manager.pushRedo ['hello']
      expect(@manager.redoStack).to.be.empty

  describe '.redo', ->
    beforeEach ->
      @manager = new UndoManager

    it 'exists', ->
      expect(@manager.redo).to.be.a 'function'

    it 'calls the callback with an error if the redo stack is empty', (done) ->
      @manager.redo (err, res) ->
        expect(err).to.be.eql new Error('No actions to be redone!')
        done()

    it 'pops the last operation on the redo stack and calls the provied callback', (done) ->
      @manager.pushRedo ['hello']
      @manager.redo (err, op) =>
        expect(op).to.be.eql ['hello']
        expect(@manager.redoStack).to.be.empty
        done()

    it 'ignores pushRedo while redoing', (done) ->
      @manager.pushRedo ['hello']
      @manager.redo (err, op) =>
        expect(op).to.be.eql ['hello']
        @manager.pushRedo ['world']
        expect(@manager.redoStack).to.be.empty
        done()

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


  describe '.transform', ->
    beforeEach ->
      @manager = new UndoManager

    it 'exists', ->
      expect(@manager.transform).to.be.a 'function'

    it 'transforms the undo stack by a single operation', ->
      # The following scenario is tested:
      #
      # local: ['hello']
      # local: [5, ' world']
      # global: [5, {d: 2}]
      # local: undo()

      @manager.pushUndo [{d: 4}]                # Delete 'hello'
      @manager.pushUndo [5, {d: 6}]             # Delete ' world'
      @manager.transform [ 5, {d: 2}], textType # Delete ' w'
      expect(@manager.undoStack).to.be.eql [
        [{d: 4}]     # Delete 'hello'
        [5, {d: 4}]  # Delete 'orld'
      ]

    it 'transforms the redo stack by a single operation', (done) ->
      # The following scenario is tested:
      #
      # local: ['hello']
      # local: [5, ' world']
      # local: undo()
      # global: [2, {d: 2}]
      # local: redo()

      @manager.pushUndo [{d: 4}]                # Delete 'hello'
      @manager.pushUndo [5, {d: 6}]             # Delete ' world'
      @manager.undo (err, op) =>
        @manager.pushRedo [5, ' world']
        @manager.transform [2, {d: 2}], textType # Delete 'll'
        expect(@manager.redoStack).to.be.eql [
          [3, ' world']
        ]
        done()


