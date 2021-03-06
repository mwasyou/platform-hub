export const loginDialogService = function ($document, $mdDialog) {
  'ngInject';

  const service = {};

  service.run = function (targetEvent) {
    return $mdDialog.show({
      template: require('./login-dialog.html'),
      controller: 'LoginDialogController',
      controllerAs: '$ctrl',
      bindToController: true,
      parent: angular.element($document.body),
      targetEvent: targetEvent,  // eslint-disable-line object-shorthand
      clickOutsideToClose: false,
      escapeToClose: false,
      fullscreen: true
    });
  };

  return service;
};
