// Generated by CoffeeScript 1.3.3
(function() {
  var google, mimeCheck, portfolio, sync;

  google = require('./reader');

  mimeCheck = require('./mimeCheck');

  portfolio = (function() {

    function portfolio(item, callback) {
      var _this = this;
      this.callback = callback;
      console.log("constructor");
      google.getChildren(null, item.id, function(resp) {
        var _i, _len, _ref;
        _ref = resp.items;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          item = _ref[_i];
          _this.findFolders(item);
        }
        _this.projects = [];
        return _this.i = 0;
      });
    }

    portfolio.prototype.findFolders = function(item) {
      var _this = this;
      console.log("findFolders");
      return google.getFile(null, item.id, function(resp) {
        if (resp.mimeType === 'application/vnd.google-apps.folder') {
          _this.i++;
          return _this.addFolder(resp, function() {
            console.log("and we're back");
            _this.i--;
            if (_this.i === 0) {
              return _this.callback(_this.projects);
            }
          });
        }
      });
    };

    portfolio.prototype.addFolder = function(item, callback) {
      var project;
      console.log("addFolder");
      project = {
        id: item.id,
        title: item.title,
        modified: item.modifiedDate,
        description: item.description,
        files: []
      };
      this.projects.push(project);
      return this.getChildren(this.projects.length - 1, item.id, callback);
    };

    portfolio.prototype.getChildren = function(index, id, callback) {
      var _this = this;
      return (function(index, id) {
        return google.getChildren(null, id, function(resp) {
          var i, item, _i, _len, _ref, _results;
          _ref = resp.items;
          _results = [];
          for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
            item = _ref[i];
            _results.push((function(item, i) {
              return google.getFile(null, item.id, function(file) {
                var fileObj, thumbIndex;
                if (mimeCheck.indexOf(file.mimeType) > -1) {
                  thumbIndex = file.thumbnailLink.slice(0, file.thumbnailLink.lastIndexOf('='));
                  fileObj = {
                    id: file.id,
                    mime: file.mimeType,
                    thumb: thumbIndex
                  };
                  if (file.mimeType.split('/')[0] === 'video') {
                    fileObj.url = file.embedLink;
                  }
                  _this.projects[index].files.push(fileObj);
                  if (i === resp.items.length - 1) {
                    return callback();
                  }
                } else {
                  if (i === resp.items.length - 1) {
                    return callback();
                  }
                }
              });
            })(item, i));
          }
          return _results;
        });
      })(index, id);
    };

    return portfolio;

  })();

  sync = (function() {

    function sync(changes, portfolio) {
      this.changes = changes;
      this.portfolio = portfolio;
      console.log("init");
    }

    return sync;

  })();

  module.exports = {
    create: function(item, callback) {
      console.log("init");
      return portfolio(item, function(resp) {
        return callback(resp);
      });
    },
    sync: function(changes, portfolio, callback) {
      console.log("sync");
      return sync(changes, portfolio, function(resp) {
        return callback(resp);
      });
    }
  };

}).call(this);
