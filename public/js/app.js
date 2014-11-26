'use strict';

var bookmarkApp = angular.module('bookmarkApp', [
    'ngRoute',
    'bookmarkControllers',
    'bookmarkServices'
]);

bookmarkApp.config(['$routeProvider',
    function($routeProvider) {
        $routeProvider.
            when("/login", {
                templateUrl: "views/partials/login.html",
                controller: "LoginCtrl"
            }).
            when("/logout", {
                templateUrl: "views/partials/login.html",
                controller: "LoginCtrl"
            }).
            when('/bookmarks', {
                templateUrl: 'views/partials/show-all.html',
                controller: 'ShowAllCtrl',
                resolve: {
                    auth: function ($q, AuthService) {
                        var userInfo = AuthService.getUserInfo();
                        console.log(userInfo);
                        if (userInfo) {
                            return $q.when(userInfo);
                        } else {
                            return $q.reject({ authenticated: false });
                        }
                    }
                }
            }).
            when('/bookmarks/:id', {
                templateUrl: 'views/partials/show-bookmark.html',
                controller: 'ShowBookmarkCtrl',
                resolve: {
                    auth: function ($q, AuthService) {
                        var userInfo = AuthService.getUserInfo();
                        if (userInfo) {
                            return $q.when(userInfo);
                        } else {
                            return $q.reject({ authenticated: false });
                        }
                    }
                }
            }).
            when('/bookmarks/edit/:id', {
                templateUrl: 'views/partials/edit-bookmark.html',
                controller: 'EditBookmarkCtrl',
                resolve: {
                    auth: function ($q, AuthService) {
                        var userInfo = AuthService.getUserInfo();
                        if (userInfo) {
                            return $q.when(userInfo);
                        } else {
                            return $q.reject({ authenticated: false });
                        }
                    }
                }
            }).
            when('/authors', {
                templateUrl: 'app/partials/show-authors.html',
                controller: 'ShowAuthorsCtrl'
            }).
            when('/authors/:id', {
                templateUrl: 'app/partials/show-author.html',
                controller: 'ShowAuthorCtrl'
            }).
            when('/authors/edit/:id', {
                templateUrl: 'app/partials/edit-author.html',
                controller: 'EditAuthorCtrl'
            }).
            when('/jobs', {
                templateUrl: 'app/partials/show-jobs.html',
                controller: 'ShowJobsCtrl'
            }).
            otherwise({
                redirectTo: '/bookmarks'
            });
    }]);


bookmarkApp.run(["$rootScope", "$location", function ($rootScope, $location) {

    $rootScope.$on("$routeChangeSuccess", function (userInfo) {
        console.log(userInfo);
    });

    $rootScope.$on("$routeChangeError", function (event, current, previous, eventObj) {
        if (eventObj.authenticated === false) {
            $location.path("/login");
        }
    });
}]);