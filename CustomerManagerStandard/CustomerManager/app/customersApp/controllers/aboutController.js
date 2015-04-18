(function () {

    var injectParams = ['customersService'];

    var AboutController = function (customersService) {
        this.causeCpuLoad = function() {
            customersService.causeCpuLoad();
        };
    };

    AboutController.$inject = injectParams;

    angular.module('customersApp').controller('AboutController', AboutController);

}());