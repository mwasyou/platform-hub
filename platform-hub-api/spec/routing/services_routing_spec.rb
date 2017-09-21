require 'rails_helper'

RSpec.describe ServicesController, type: :routing do
  describe 'routing' do

    context 'with projects feature flag enabled' do

      before do
        FeatureFlagService.create_or_update(:projects, true)
      end

      it 'routes to #index' do
        expect(:get => '/projects/foo/services').to route_to('services#index', :project_id => 'foo')
      end

      it 'routes to #show' do
        expect(:get => '/projects/foo/services/1').to route_to('services#show', :project_id => 'foo', :id => '1')
      end

      it 'routes to #create' do
        expect(:post => '/projects/foo/services').to route_to('services#create', :project_id => 'foo')
      end

      it 'routes to #update via PUT' do
        expect(:put => '/projects/foo/services/1').to route_to('services#update', :project_id => 'foo', :id => '1')
      end

      it 'routes to #update via PATCH' do
        expect(:patch => '/projects/foo/services/1').to route_to('services#update', :project_id => 'foo', :id => '1')
      end

      it 'routes to #destroy' do
        expect(:delete => '/projects/foo/services/1').to route_to('services#destroy', :project_id => 'foo', :id => '1')
      end

    end

    context 'with projects/foo feature flag disabled' do

      before do
        FeatureFlagService.create_or_update(:projects, false)
      end

      it 'route to #index is not routable' do
        expect(:get => '/projects/foo/services').to_not be_routable
      end

      it 'route to #show is not routable' do
        expect(:get => '/projects/foo/services/1').to_not be_routable
      end

      it 'route to #create is not routable' do
        expect(:post => '/projects/foo/services').to_not be_routable
      end

      it 'route to #update via PUT is not routable' do
        expect(:put => '/projects/foo/services/1').to_not be_routable
      end

      it 'route to #update via PATCH is not routable' do
        expect(:patch => '/projects/foo/services/1').to_not be_routable
      end

      it 'route to #destroy is not routable' do
        expect(:delete => '/projects/foo/services/1').to_not be_routable
      end

    end

  end
end
