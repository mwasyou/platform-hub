require 'rails_helper'

RSpec.describe CostsReportsController, type: :routing do
  describe 'routing' do

    it 'routes to #available_data_files' do
      expect(:get => '/costs_reports/available_data_files').to route_to('costs_reports#available_data_files')
    end

    it 'routes to #index' do
      expect(:get => '/costs_reports').to route_to('costs_reports#index')
    end

    it 'routes to #show' do
      expect(:get => '/costs_reports/2017-01').to route_to('costs_reports#show', :id => '2017-01')
    end

    it 'routes to #prepare' do
      expect(:post => '/costs_reports/prepare').to route_to('costs_reports#prepare')
    end

    it 'routes to #create' do
      expect(:post => '/costs_reports').to route_to('costs_reports#create')
    end

    it 'routes to #destroy' do
      expect(:delete => '/costs_reports/2017-01').to route_to('costs_reports#destroy', :id => '2017-01')
    end

    it 'routes to #publish' do
      expect(:post => '/costs_reports/2017-01/publish').to route_to('costs_reports#publish', :id => '2017-01')
    end

    it 'routes to #last_published_config' do
      expect(:get => '/costs_reports/last_published_config').to route_to('costs_reports#last_published_config')
    end

    it 'doesn\'t route an invalid ID' do
      expect(:get => '/costs_reports/1').not_to be_routable
      expect(:get => '/costs_reports/foo').not_to be_routable
    end

  end
end
