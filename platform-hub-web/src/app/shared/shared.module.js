import angular from 'angular';

import {AuthModule} from './auth/auth.module';
import {HubApiModule} from './hub-api/hub-api.module';
import {IdentitiesModule} from './identities/identities.module';
import {ModelModule} from './model/model.module';
import {UiModule} from './ui/ui.module';
import {UtilModule} from './util/util.module';

import {AllocationsListingComponent} from './allocations-listing.component';
import {apiInterceptorService} from './api-interceptor.service';
import {events} from './events.factory';
import {homeEndpoints} from './home-endpoints.factory';
import {icons} from './icons.factory';
import {KubeConfigHelperPopupController} from './kube-config-helper-popup.controller';
import {kubeConfigHelperPopupService} from './kube-config-helper-popup.service';
import {KubernetesIdentityTokensPopupController} from './kubernetes-identity-tokens-popup.controller';
import {kubernetesIdentityTokensPopupService} from './kubernetes-identity-tokens-popup.service';
import {KubernetesTokenCardComponent} from './kubernetes-token-card.component';
import {KubernetesTokenValueComponent} from './kubernetes-token-value.component';
import {onboardingTrigger} from './onboarding-trigger.factory';
import {ProjectBillBreakdownComponent} from './project-bill-breakdown.component';
import {roleCheckerService} from './role-checker.service';

export const SharedModule = angular
  .module('app.shared', [
    AuthModule,
    HubApiModule,
    IdentitiesModule,
    ModelModule,
    UiModule,
    UtilModule
  ])
  .component('allocationsListing', AllocationsListingComponent)
  .service('apiInterceptorService', apiInterceptorService)
  .factory('events', events)
  .factory('homeEndpoints', homeEndpoints)
  .factory('icons', icons)
  .controller('KubeConfigHelperPopupController', KubeConfigHelperPopupController)
  .service('kubeConfigHelperPopupService', kubeConfigHelperPopupService)
  .controller('KubernetesIdentityTokensPopupController', KubernetesIdentityTokensPopupController)
  .component('kubernetesTokenCard', KubernetesTokenCardComponent)
  .component('kubernetesTokenValue', KubernetesTokenValueComponent)
  .service('kubernetesIdentityTokensPopupService', kubernetesIdentityTokensPopupService)
  .factory('onboardingTrigger', onboardingTrigger)
  .component('projectBillBreakdown', ProjectBillBreakdownComponent)
  .service('roleCheckerService', roleCheckerService)
  .name;
