'use strict';

appUpload.controller('UploadController', ['$scope', 'FileUploader', '$http', function($scope, FileUploader, $http) {
    var uploader = $scope.uploader = new FileUploader({
        url: '/background/upload/do'
    });

    $scope.config = {
      valueField: 'value',
      labelField: 'text',
      searchField: ['value'],
      sortField: 'value',
      placeholder: 'Type Something',
      allowEmptyOption: true,
      create: true
    };

    $http.get('/background/list').then(function(response) {
        console.log(response.data.directories);
        $scope.albums = response.data.directories;
    });

//    $scope.albums = [
//        { value: 'Gaia Zoo - 2013', text: ' Gaia Zoo - 2013' },
//        { value: 'Duiken\\Vinkeveen - 2014', text: ' Duiken\\Vinkeveen - 2014' },
//        { value: 'Duiken\\Zeelandweekend - Mei 2014', text: 'Duiken\\Zeelandweekend - Mei 2014' }
//    ];

    uploader.onBeforeUploadItem = function(item) {
        item.formData = [{'album': $scope.album, 'taken_by': $scope.taken_by}]
    };
}]);