/**
 * Created by jacshen on 11/25/14.
 */
'use strict';

var bookmarkServices = angular.module('bookmarkServices', []);

bookmarkServices.factory("AuthService", ["$http","$q","$window",function ($http, $q, $window) {
    var userInfo;

    function login(userName, password) {
        var deferred = $q.defer();

        $http.post("/login", { userName: userName, password: password })
            .then(function (result) {
                userInfo = result.data;
                console.log(result)
                $window.sessionStorage["userInfo"] = userInfo;
                deferred.resolve(userInfo);
                console.log($window.sessionStorage["userInfo"]);
                console.log(userInfo);
            }, function (error) {
                deferred.reject(error);
            });

        return deferred.promise;
    }

    function logout() {
        var deferred = $q.defer();

        $http({
            method: "POST",
            url: "/logout",
            headers: {
                "access_token": userInfo.accessToken
            }
        }).then(function (result) {
            userInfo = null;
            $window.sessionStorage["userInfo"] = null;
            deferred.resolve(result);
        }, function (error) {
            deferred.reject(error);
        });

        return deferred.promise;
    }

    function getUserInfo() {
        return userInfo;
    }

    function init() {

        if (userInfo) {
            userInfo = JSON.parse(userInfo);
        }
    }
    init();

    return {
        login: login,
        logout: logout,
        getUserInfo: getUserInfo
    };
}]);