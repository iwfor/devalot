var TableMaker = {}
TableMaker.CellEditor = Class.create();

TableMaker.CellEditor.defaultOptions = {
  okButton: false,
  cancelLink: false
}

TableMaker.CellEditor.prototype = {
  // TODO:
  //   Handle Select Forms

  initialize: function(element, column, url) {
    this.options = Object.extend({
      paramName: column
    }, TableMaker.CellEditor.defaultOptions);

    this.inPlaceEditor = new Ajax.InPlaceEditor(element, url, this.options);
    this.ipeCreateForm = this.inPlaceEditor.createForm;
    this.inPlaceEditor.createForm = this.createForm.bind(this);
  },
  createForm: function() {
    this.ipeCreateForm.bind(this.inPlaceEditor)();
    Event.observe(this.inPlaceEditor.editField, 'keypress',
                  this.keyPressEvent.bindAsEventListener(this));
  },
  keyPressEvent: function(evt) {
    if (evt.keyCode == Event.KEY_ESC) {
      this.inPlaceEditor.onclickCancel();
      evt.stop();
    }
  }
};
