'use strict';

var app = angular.module('ProjectDeltaApp', ['angular-loading-bar']);
app.config(['cfpLoadingBarProvider', function(cfpLoadingBarProvider) {
    cfpLoadingBarProvider.includeSpinner = false;
  }]);

var appUpload = angular.module('ProjectDeltaUploadApp', ['angularFileUpload', 'ng-selectize']);