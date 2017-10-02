require 'rails_helper'

RSpec.describe TokensSyncJob, type: :job do

  describe '.is_already_queued' do
    it 'should recognise when the job is already queued' do
      expect(TokensSyncJob.is_already_queued).to be false

      TokensSyncJob.perform_later

      expect(TokensSyncJob.is_already_queued).to be true
    end
  end

  describe '.perform' do

    context 'with kubernetes_tokens feature flag enabled' do
      before do
        FeatureFlagService.create_or_update(:kubernetes_tokens, true)
        create(:kubernetes_cluster)
      end

      before do
        KubernetesCluster.names.each do |cluster_name|
          expect(Kubernetes::TokenSyncService).to receive(:sync_tokens).with(cluster_name)

          expect(AuditService).to receive(:log).with(
            action: 'sync_kubernetes_tokens',
            data: { background_job: true, cluster: cluster_name },
            comment: "Kubernetes tokens synced to `#{cluster_name}` cluster via background job."
          )
        end
      end

      it 'should call the token sync service with all the clusters and register an audit' do
        TokensSyncJob.new.perform
      end
    end

    context 'with kubernetes_tokens feature flag disabled' do
      it 'should not do anything' do
        expect(KubernetesCluster).to receive(:names).never
        expect(Kubernetes::TokenSyncService).to receive(:sync_tokens).never
        expect(AuditService).to receive(:log).never
      end
    end

  end

end
