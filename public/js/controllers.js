'use strict';

var bookmarkControllers = angular.module('bookmarkControllers', []);

bookmarkControllers.controller('ShowAllCtrl', [
    '$scope', '$http',
    function ($scope, $http) {

        $http.get("/bookmarks").success(function (response) {
            $scope.bookmarks = response;
        });

        $scope.showLayer = function() {
            angular.element(".layer").removeClass("ng-hide");
            angular.element(".new-quote-form").removeClass("ng-hide");
        }

        $scope.hideForm = function() {
            angular.element(".layer").addClass("ng-hide");
            angular.element(".new-quote-form").addClass("ng-hide");
        }

        $scope.submit = function(newItem) {
            $http.post("/bookmarks", newItem).success(function (newItem, status) {
                $http.get("/bookmarks").success(function(response) {
                    $scope.bookmarks = response;
                });
            });
        }

    }]);

bookmarkControllers.controller('ShowBookmarkCtrl', [
    '$scope', '$routeParams', '$http', '$location',
    function($scope, $routeParams, $http, $location) {
        $http.get("/bookmarks/" + $routeParams.id).success(function(response) {
            $scope.bookmark = response;
        }).error( function(response){
            alert("you can't go here!")
            $location.path("/bookmarks");
        });

        $scope.deleteForm = function() {
            angular.element(".layer").removeClass("ng-hide");
            angular.element(".delete-form").removeClass("ng-hide");
        }

        $scope.hideForm = function() {
            // this doesn't work...
            //$route.reload();
            $location.path("bookmarks" + $routeParams.id)
            angular.element(".layer").addClass("ng-hide");
            // angular.element(".new-quote-form").addClass("ng-hide");
        }

        $scope.sendDelete = function() {
            $http.delete("/bookmarks/" + $routeParams.id).success(function(success) {
                $location.path("/bookmarks");
            })
        }

    }]);

bookmarkControllers.controller('EditBookmarkCtrl', [
    '$scope', '$routeParams', '$http', '$location',
    function($scope, $routeParams, $http, $location) {
        $http.get("/bookmarks/" + $routeParams.id).success(function(response) {
            $scope.bookmark = response;
            $scope.bookmark.tagList = response.tagList.toString();
        });

        $scope.updateQuote = function(item) {
            $http.put("/bookmarks/edit/" + $routeParams.id, item).success(function() {
                $location.path("/bookmarks/" + $routeParams.id);
            });
        }

    }]);

bookmarkControllers.controller("LoginCtrl", ["$scope", "$location", "$window", "AuthService",function ($scope, $location, $window, AuthService) {
    $scope.userInfo = null;
    $scope.login = function () {
        AuthService.login($scope.userName, $scope.password)
            .then(function (result) {
                $scope.userInfo = result;
                $location.path("/");
            }, function (error) {
                $window.alert("Invalid credentials");
                console.log(error);
            });
    };

    $scope.cancel = function () {
        $scope.userName = "";
        $scope.password = "";
    };
}]);

bookmarkControllers.controller("HomeCtrl", ["$scope", "$location", "AuthService",function ($scope, $location, AuthService) {


    $scope.logout = function () {

        AuthService.logout()
            .then(function (result) {
                $scope.userInfo = null;
                $location.path("/login");
            }, function (error) {
                console.log(error);
            });
    };
}]);