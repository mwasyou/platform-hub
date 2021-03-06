export const CostsReportsDetailComponent = {
  bindings: {
    transition: '<'
  },
  template: require('./costs-reports-detail.html'),
  controller: CostsReportsDetailController
};

function CostsReportsDetailController($mdDialog, $state, $filter, CostsReports, Projects, roleCheckerService, objectRollupService, treeDataHelper, logger, _) {
  'ngInject';

  const formatCurrencyUnitsFilter = $filter('formatCurrencyUnits');

  const valueFormatter = v => {
    if (_.isFinite(v)) {
      return formatCurrencyUnitsFilter(v, '$');
    }
    return v;
  };

  const ctrl = this;

  const id = ctrl.transition.params().id;

  ctrl.loading = true;
  ctrl.isAdmin = false;
  ctrl.report = null;
  ctrl.projectBills = null;
  ctrl.totals = null;
  ctrl.configTreeData = null;
  ctrl.sharedCostsBreakdownTreeData = null;
  ctrl.expanded = false;

  ctrl.handleProjectBillTotals = handleProjectBillTotals;
  ctrl.deleteReport = deleteReport;

  init();

  function init() {
    loadAdminStatus()
      .then(loadCostReport);
  }

  function loadAdminStatus() {
    return roleCheckerService
      .hasHubRole('admin')
      .then(hasRole => {
        ctrl.isAdmin = hasRole;
      });
  }

  function loadCostReport() {
    return CostsReports
      .get(id)
      .then(report => {
        ctrl.report = report;

        ctrl.projectBills = _.sortBy(
          _.values(report.results.project_bills),
          ['name']
        );

        ctrl.configTreeData = treeDataHelper.objectToTreeData(report.config);

        ctrl.sharedCostsBreakdownTreeData = treeDataHelper.objectToTreeData(
          report.results.shared_costs_breakdown,
          valueFormatter
        );
      })
      .finally(() => {
        ctrl.loading = false;
      });
  }

  function handleProjectBillTotals(totals) {
    ctrl.totals = objectRollupService.rollup(totals, ctrl.totals);
  }

  function deleteReport(targetEvent) {
    if (!ctrl.isAdmin) {
      return;
    }

    const confirm = $mdDialog.confirm()
      .title('Are you sure?')
      .textContent(`This will delete the costs report '${id}'. You can still recreate it later as long as the source data is still available.`)
      .ariaLabel('Confirm deletion of costs report')
      .targetEvent(targetEvent)
      .ok('Do it')
      .cancel('Cancel');

    $mdDialog
      .show(confirm)
      .then(() => {
        ctrl.loading = true;

        CostsReports
          .delete(ctrl.report.id)
          .then(() => {
            logger.success('Costs report deleted');
            $state.go('costs-reports.list');
          })
          .finally(() => {
            ctrl.loading = false;
          });
      });
  }
}
