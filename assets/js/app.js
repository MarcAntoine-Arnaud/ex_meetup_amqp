// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

module = angular.module('MyApp', [
  'ngResource'
]);


module.factory('JobFactory', JobFactory);

JobFactory.$inject = ['$resource'];

function JobFactory($resource) {
  return $resource('/api/jobs', {}, {
    getJobs: {
      method: 'GET',
    },
    newJob: {
      method: 'POST',
    },
    getJob: {
      method: 'GET',
      url: '/api/jobs/:id',
      params: {id: '@id'}
    },
    deleteJob: {
      method: 'DELETE',
      url: '/api/jobs/:id',
      params: {id: '@id'}
    },
  });
}

module.factory('JobService', JobService);

JobService.$inject = [
  '$http',
  'JobFactory'
];
function JobService(
  $http,
  JobFactory
) {
  function Service() {
  }

  Service.prototype = {
    getJobs: getJobs,
    getJob: getJob,
    newJob: newJob,
    deleteJob: deleteJob,
  }

  return new Service();

  function getJobs(params){
    return JobFactory.getJobs(params).$promise;
  }

  function getJob(id){
    return JobFactory.getJob({id: id}).$promise;
  }
  function newJob(params){
    return JobFactory.newJob({job: params}).$promise;
  }
  function deleteJob(id){
    return JobFactory.deleteJob({id: id}).$promise;
  }
}


module.controller('JobController', JobController);

JobController.$inject = [
  '$http',
  '$rootScope',
  'JobService'
];

function JobController(
  $http,
  $rootScope,
  JobService)
{
  var vm = this;
  vm.start = start;
  vm.deleteJob = deleteJob;
  vm.deleteAllJobs = deleteAllJobs;

  (function initController() {
    updateJobs();
  })();

  function start() {
    var params = vm.job;
    params.params = {};
    JobService.newJob(params).then(
    function(response) {
      console.log("done");
      updateJobs();
    },
    function(message) {
      console.log("error", message);
    });
  }

  function deleteJob(job_id) {
    JobService.deleteJob(job_id);
    updateJobs();
  }

  function deleteAllJobs(job_id) {
    for (var i = vm.jobs.length - 1; i >= 0; i--) {
      JobService.deleteJob(vm.jobs[i].id).then(
      function(response) {
        updateJobs();
      });
    }
  }

  function updateJobs(){
    JobService.getJobs().then(
    function(response) {
      vm.jobs = response.data;
    },
    function(message) {
      console.log("error", message);
    });
  }
}

