'use strict';

app.controller('MainController', ['$scope', '$interval', 'dateFilter', '$http', function ($scope, $interval, dateFilter, $http) {

    // Time update every 1 second
    $scope.updateTime = function() {
        $scope.date = (dateFilter(new Date(), 'EEEE, d MMM'));
        $scope.time = (dateFilter(new Date(), 'HH:mm'));
        $scope.seconds = (dateFilter(new Date(), 'ss'));
    };

    $interval($scope.updateTime, 1000); // Every 1 second
    $scope.updateTime();

    // Background update every 60 seconds
    $scope.updateBackground = function() {
        $http.get('/background/get').then(function(response) {
            $scope.background = response.data;
        });
    };

    $interval($scope.updateBackground, 60000); // Every 60 seconds
    $scope.updateBackground();

    // Weather update every 10 minutes
    $scope.updateWeather = function() {
        $http.get('/weather/get').then(function(response) {
            $scope.weather = response.data;
        });
    };

    $interval($scope.updateWeather, 600000); // Every 10 minutes
    $scope.updateWeather();

    // Calendar update every 60 minutes
    $scope.updateCalendar = function() {
        $http.get('/calendar/get').then(function(response) {
            $scope.calendar = response.data;
        });
    };

    $interval($scope.updateCalendar, 3600000); // Every 60 minutes
    $scope.updateCalendar();
}]);