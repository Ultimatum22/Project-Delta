app.directive('clock', ['$interval', 'dateFilter', function($interval, dateFilter) {
    return {
        restrict: 'A',
        transclude: true,
        scope: {
            format: '@'
        },
        link: function(scope, element, attrs) {
            var format = scope.format || '';

            var updateTime = function() {
                element.text(dateFilter(new Date(), format));
            };

            var timer = $interval(updateTime, 1000);
            element.on('$destroy', function() {
                $interval.cancel(timer);
            });
        }
    };
}]);